# ========================================================================================================
# Purpose:      Rscript for Quantile Regression demo.
# Author:       Neumann Chew
# DOC:          15-09-2017
# Topics:       Quantile Regression
# Data Sources: Engel in package quantreg.
#=========================================================================================================

setwd('/Users/Jingwen/Documents/Y2S2/BC2407 Analytics 2/S4 Quantile Regression/S4 Quantile Reg Solutions')

library(quantreg)
data(engel)
write.csv(engel, "engel.csv", row.names = F, col.names = T)


# Read or write data in other software format e.g. SAS, SPSS, Stata etc..
# library(foreign)
# write.foreign(engel, "engel.csv", "engel.sas", package = "SAS", dataname = "rdata")

# explore write.xport() with xpt file name extension

# Linear Regression is inadequate -----------------------------------------

summary(engel$income)
fit.lm <- lm(engel$foodexp ~ engel$income)
summary(fit.lm)
plot(engel$income, engel$foodexp, main = 'Regressions on Engel Food Expenditure Data', xlab = 'Household Income', ylab = 'Food Expenditure')
abline(fit.lm,lty=2,col="red")

par(mfrow=c(2,2))
plot(fit.lm)
par(mfrow=c(1,1))

library(quantreg)
# Fit 50th Percentile Line (i.e. Median)
fit.p.5 <- rq(engel$foodexp ~ engel$income, tau=.5) #tau: percentile level. 0.5 is the 50th percentile (aka median).
abline(fit.p.5, col="blue")

fit.p.5
summary(fit.p.5)
summary(fit.p.5, se = "nid")

c.5 <- coef(fit.p.5)
r.5 <- resid(fit.p.5) 

# 5th, 10th, 25th, 75th, 90th, 95th percentiles.
taus <- c(.05, .1, .25, .75, .90, .95)

table <- data.frame("Tau" = 1:6, "beta0" = 1:6, "beta_Income" = 1:6)

# Plot the 6 percentile grey lines
for( i in 1:length(taus)){
  fit <- rq(engel$foodexp~engel$income,tau=taus[i])
  coef <- coef(fit)
  table$Tau[i] = taus[i]
  table$beta0[i] = coef[1]
  table$beta_Income[i] = coef[2]
  abline(fit, col = "grey")
}

print("Quantile Regression models at Various Percentiles")
table


