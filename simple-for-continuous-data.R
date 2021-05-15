# Instalar e carregar paquetes e librarias necessárias

install.packages(setdiff(c('meta','metafor','esc','readxl','devtools'), rownames(installed.packages())))
if (!"dmetar" %in% rownames(installed.packages())) {
  devtools::install_github("MathiasHarrer/dmetar")
} 

library(readxl)
library(meta)
library(metafor)
library(dmetar)
library(esc)

# Step 1: Carregar os dados na variável madata

madata <- read_excel("raw-data.xlsx", sheet = "sheet")

(m.raw <- metacont(Ne, Me, Se, Nc, Mc, Sc, data = madata
                   , studlab = paste(Author)
                   , comb.fixed = F, comb.random = T
                   , sm = "SMD"))

# Step 3: Exclusão de outliers

## identificação de outliers usando boxplot - valido para fixed-model
(m.ro <- find.outliers(m.raw)) 

## identificação de outliers usando analises de influencia - valido para random-model
(ia.m <- InfluenceAnalysis(x = m.raw, random = T))
plot(ia.m, "es")
plot(ia.m, "influence")
plot(ia.m, "baujat")

## Graphic Display of Heterogeneity (GOSH)  - valido para random-model
## (usa todas as comb. possíveis dos 'k' estudos)

### calculo de tamanho de efeito 

effsize <- esc_mean_sd(madata$Me, madata$Se, madata$Ne,
                       madata$Mc, madata$Sc, madata$Nc, es.type = "g")
madata["TE"] <- effsize$es
madata["seTE"] <- effsize$se

m.gef <- metagen(TE, seTE, data = madata, studlab = paste(Author),
                 comb.fixed = F, comb.random = T)
m.rma <- rma(yi = m.gef$TE, sei = m.gef$seTE, method = m.gef$method.tau)

dat.gosh <- gosh(m.rma)
(gda.out <- gosh.diagnostics(dat.gosh))

plot(gda.out$km.plot)
plot(gda.out$db.plot)
plot(gda.out$gmm.plot)

(m <- metacont(Ne, Me, Se, Nc, Mc, Sc, data = madata
               , studlab = paste(Author)
               , exclude = c(15,6,18,4)
               , comb.fixed = F, comb.random = T
               , sm = "SMD"))

forest(m, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

# Step 5: Metanálises de Subgrupos por: população

#(m.sg4p <- subgroup.analysis.mixed.effects(x = m, subgroups = madata$population))
(m.sg4p <- update.meta(m, byvar=population, comb.random = T, comb.fixed = F))

forest(m.sg4p, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


# Step 5: Metanálises de Subgrupos por: contexto

(m.sg4ctx <- update.meta(m, byvar=context, comb.random = T, comb.fixed = F))

forest(m.sg4ctx, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


# Step 5: Metanálises de Subgrupos por: duração

(m.sg4d <- subgroup.analysis.mixed.effects(x = m, subgroups = madata$duration))

forest(m.sg4d, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


# Step 5: Metanálises de Subgrupos por: intervention

(m.sg4i <- update.meta(m, byvar=intervention, comb.random = T, comb.fixed = F))

forest(m.sg4i, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


# Step 5: Metanálises de Subgrupos por: control

(m.sg4c <- update.meta(m, byvar=control, comb.random = T, comb.fixed = F))

forest(m.sg4c, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")

# Step 5: Metanálises de Subgrupos por: instrument

(m.sg4ins <- update.meta(m, byvar=instrument, comb.random = T, comb.fixed = F))

forest(m.sg4ins, digits=2, digits.sd = 2, test.overall = T, lab.e = "Intervention")


# Step 6: Funel plot

funnel(m, xlab = "g")

funnel(m, xlab = "g", studlab = T)




