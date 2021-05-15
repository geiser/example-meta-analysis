#' ---
#' title: "Metanálise básio quando os resultados (outcomes) são dados continuos"
#' author: "Geiser Chalco <geiser@alumni.usp.br>"
#' date: "5/14/2021" 
#' 
#' 
#' Prerequisitos:
#' 
#'  - Instalar R: [https://vps.fmvz.usp.br/CRAN/](https://vps.fmvz.usp.br/CRAN/)
#'  - Instalar r-studio: [https://www.rstudio.com/products/rstudio/](https://www.rstudio.com/products/rstudio/)


#' # Instalar e carregar pacotes de R necessários
## ------------------------------------------------------------------------------------------------------
install.packages(setdiff(c('meta','metafor','esc','readxl','devtools'), rownames(installed.packages())))
if (!"dmetar" %in% rownames(installed.packages())) {
  devtools::install_github("MathiasHarrer/dmetar")
} 

library(readxl)
library(meta)
library(metafor)
library(dmetar)
library(esc)

#' # Step 1: Carregar os dados na variável madata
## ------------------------------------------------------------------------------------------------------
madata <- read_excel("raw-data.xlsx", sheet = "sheet")


#' # Step 2: Condução da metanálises sem remover outlier
## ------------------------------------------------------------------------------------------------------
(m.raw <- metacont(Ne, Me, Se, Nc, Mc, Sc, data = madata
                   , studlab = paste(Author)
                   , comb.fixed = F, comb.random = T
                   , sm = "SMD"))

#' # Step 3: Exclusão de outliers
## ------------------------------------------------------------------------------------------------------

#' ## Identificação de outliers mediante Método GOSH

#' Calculo de tamanho de efeito mediante a função `effsize`
effsize <- esc_mean_sd(madata$Me, madata$Se, madata$Ne,
                       madata$Mc, madata$Sc, madata$Nc, es.type = "g")
madata["TE"] <- effsize$es
madata["seTE"] <- effsize$se

#' Cálcular a metaregresión 
m.rma <- rma(yi = madata$TE, sei = madata$seTE)

#' Empregar a função `gosh`
dat.gosh <- gosh(m.rma)
(gda.out <- gosh.diagnostics(dat.gosh))

plot(gda.out$km.plot)
plot(gda.out$db.plot)
plot(gda.out$gmm.plot)

#' ## Efeituar metanálise sem outliers
(m <- metacont(Ne, Me, Se, Nc, Mc, Sc, data = madata
               , studlab = paste(Author)
               , exclude = c(15,6,18,4)
               , comb.fixed = F, comb.random = T
               , sm = "SMD"))

#' # Step 4: Forest plot da metanálise sem outliers
## ------------------------------------------------------------------------------------------------------
forest(m, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


#' # Step 5: Metanálises usando subgrupos
## ------------------------------------------------------------------------------------------------------
 
#' ## Metanálises agrupando estudos por: população
(m.sg4p <- update.meta(m, byvar=population, comb.random = T, comb.fixed = F))
forest(m.sg4p, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

#' ## Metanálises agrupando estudos por: contexto
(m.sg4ctx <- update.meta(m, byvar=context, comb.random = T, comb.fixed = F))
forest(m.sg4ctx, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

#' ## Metanálises agrupando estudos por: duração
(m.sg4d <- subgroup.analysis.mixed.effects(x = m, subgroups = madata$duration))
forest(m.sg4d, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

#' ## Metanálises agrupando estudos por: intervention
(m.sg4i <- update.meta(m, byvar=intervention, comb.random = T, comb.fixed = F))
forest(m.sg4i, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

#' ## Metanálises agrupando estudos por: control
(m.sg4c <- update.meta(m, byvar=control, comb.random = T, comb.fixed = F))
forest(m.sg4c, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

#' ## Metanálises agrupando estudos por: instrumento (usado para medir)
(m.sg4ins <- update.meta(m, byvar=instrument, comb.random = T, comb.fixed = F))
forest(m.sg4ins, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


#' # Step 6: Análises de viés de publicação usando Funel plot
## ------------------------------------------------------------------------------------------------------

funnel(m, xlab = "Hedges' g", studlab = T)

summary(eggers.test(x = m))

