# ========================================================================================================
# Purpose:      Rscript for Quantile Regression demo.
# Author:       Chew C.H.
# DOC:          15-09-2017
# Topics:       Quantile Regression
# Data Sources: Engel in package quantreg.
#=========================================================================================================

#setwd('D:/Dropbox/Schools/NBS/BC2407 Analytics 2/S4 Quantile Reg')

library(quantreg)
data(engel)

# Export a R dataset as a CSV file. Other software can then use this dataset. 
write.csv(engel, "engel.csv", row.names = F, col.names = T)

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

# 5th, 10th, 25th, 75th, 90th, 95th percentiles.
taus <- c(.05, .1, .25, .75, .90, .95)

# Plot the 6 percentile grey lines
for( i in 1:length(taus)){
   abline(rq(engel$foodexp~engel$income,tau=taus[i]), col = "grey")
}