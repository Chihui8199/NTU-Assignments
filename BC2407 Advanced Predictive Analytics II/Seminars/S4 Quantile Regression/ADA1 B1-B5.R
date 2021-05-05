# ========================================================================================================
# Purpose:      Rscript for Quantile Regression demo.
# Author:       Chew C.H.
# DOC:          15-09-2017
# Topics:       Quantile Regression
# Data Sources: Engel in package quantreg.
#=========================================================================================================

setwd("~/Desktop/Y2S2/BC2407/S4 Quantile Regression")
library(quantreg)
as.data.frame(data(engel))

summary(engel$income)
fit.lm <- lm(engel$foodexp ~ engel$income)
summary(fit.lm)
plot(engel$income, engel$foodexp, main = 'Regressions on Engel Food Expenditure Data', xlab = 'Household Income', ylab = 'Food Expenditure')
abline(fit.lm,lty=2,col="red")

library(quantreg)
# Fit 50th Percentile Line (i.e. Median)
fit.p.5 <- rq(engel$foodexp ~ engel$income, tau=.5) #tau: percentile level. 0.5 is the 50th percentile (aka median).
abline(fit.p.5, col="blue")

fit.p.5
summary(fit.p.5)
summary(fit.p.5, se = "nid")

# 5th, 10th, 25th, 75th, 90th, 95th percentiles.
taus <- c(.05, .1, .25, .75, .90, .95)

# Plot the 6 percentile grey lines
for( i in 1:length(taus)){
   abline(rq(engel$foodexp~engel$income,tau=taus[i]), col = "grey")
}

table <- data.frame("Tau" = 1:6, "beta0" = 1:6, "beta_Income" = 1:6)
for( i in 1:length(taus)){
  fit <- rq(engel$foodexp~engel$income,tau=taus[i])
  coef <- coef(fit)
  table$Tau[i] = taus[i]
  table$beta0[i] = coef[1]
  table$beta_Income[i] = coef[2]
  abline(fit, col = "grey")
}

table


library(ggplot2)
p <- ggplot(data = engel, aes(x = income, y = foodexp)) +
  geom_quantile(quantiles = taus)+
  geom_point()
p
