# ========================================================================================================
# Purpose:      Rscript for cd4 demo.
# Author:       Neumann Chew
# DOC:          01-03-2018
# Topics:       Summary statistics, CI, Bootstrap
# Rpackages:    boot
# Data Source:  cd4.csv
#=========================================================================================================

setwd("~/Desktop/Y2S2/BC2407/S7 Bootstrap")
data1 <- read.csv('cd4.csv')

# Prop Normal Range = Proportion of Subjects with cd4 count in normal range of 500 to 1500.
table1 <- data.frame('Baseline Standard Statistic' = 1:6, 'Baseline Bootstrap Statistic' = 1:6, 'Year1 Standard Statistic' = 1:6, 'Year1 Bootstrap Statistic' = 1:6)
rownames(table1) <- c('Mean', '95% CI for Mean', 'SD', '95% CI for SD', 'Prop Normal Range', '95% CI for Prop N.R.')
# Convert all column to string as CI is a confidence interval and not one number.
table1[] <- lapply(table1, as.character)
table1$Baseline.Bootstrap.Statistic <- NA
table1$Year1.Bootstrap.Statistic <- NA

# Standard Mean formula and CI
table1[1, 1] <- mean(data1$Baseline); table1[1,3] <- mean(data1$Year1)
t.test.baseline <- t.test(data1$Baseline, conf.level = 0.95)
table1[2, 1] <- paste(round(t.test.baseline$conf.int[1],2),' to ', round(t.test.baseline$conf.int[2],2))
t.test.year1 <- t.test(data1$Year1, conf.level = 0.95)
table1[2, 3] <- paste(round(t.test.year1$conf.int[1],2),' to ', round(t.test.year1$conf.int[2],2))
remove(list = c('t.test.baseline', 't.test.year1'))

# Standard unbiased SD formula and CI
table1[3, 1] <- round(sd(data1$Baseline),2); table1[3,3] <- round(sd(data1$Year1),2)
# R seems to has no in-built function for the CI of a variance or SD. Let me know if you found one.
df = length(data1$Baseline) - 1
lower = var(data1$Baseline) * df / qchisq(0.05/2, df, lower.tail = F)
upper = var(data1$Baseline) * df / qchisq(1 - 0.05/2, df, lower.tail = F)
table1[4, 1] <- paste(round(sqrt(lower),2),' to ', round(sqrt(upper),2))
df = length(data1$Year1) - 1
lower = var(data1$Year1) * df / qchisq(0.05/2, df, lower.tail = F)
upper = var(data1$Year1) * df / qchisq(1 - 0.05/2, df, lower.tail = F)
table1[4, 3] <- paste(round(sqrt(lower),2),' to ', round(sqrt(upper),2))
remove(list = c('df', 'lower', 'upper'))

# Standard Proportion calculation of subjects with Normal Range cd4 count
table1[5, 1] <- sum(data1$Baseline >= 500 & data1$Baseline <= 1500)/length(data1$Baseline)
table1[5, 3] <- sum(data1$Year1 >= 500 & data1$Year1 <= 1500)/length(data1$Year1)
# Since np < 5, assumption for using normal approx is not satisfied. Use R in-built prop.test().
p.test <- prop.test(x = sum(data1$Baseline >= 500 & data1$Baseline <= 1500), n = length(data1$Baseline), conf.level = 0.95)
table1[6, 1] <- paste(round(p.test$conf.int[1],3),' to ', round(p.test$conf.int[2],3))
p.test <- prop.test(x = sum(data1$Year1 >= 500 & data1$Year1 <= 1500), n = length(data1$Year1), conf.level = 0.95)
table1[6, 3] <- paste(round(p.test$conf.int[1],3),' to ', round(p.test$conf.int[2],3))
remove(p.test)

library(boot)
set.seed(2014)
# Bootstrap the mean
samplemean <- function(data, indices) {
  return(mean(data[indices], na.rm = T))
}
boot.Baseline <- boot(data=data1$Baseline, statistic=samplemean, R=10000)
# view results of bootstrap
boot.Baseline
plot(boot.Baseline)
# 95% BCA confidence interval from Bootstrap of Mean
bci <- boot.ci(boot.Baseline, type="bca", conf = 0.95)
table1[1, 2] <- mean(boot.Baseline$t) # avg of the bootstrap samples
table1[2, 2] <- paste(round(bci$bca[4],2),' to ', round(bci$bca[5],2))

boot.Year1 <- boot(data=data1$Year1, statistic=samplemean, R=10000)
boot.Year1
plot(boot.Year1)
bci <- boot.ci(boot.Year1, type="bca", conf = 0.95)
table1[1, 4] <- mean(boot.Year1$t) # avg of the bootstrap samples
table1[2, 4] <- paste(round(bci$bca[4],2),' to ', round(bci$bca[5],2))

# Bootstrap the SD
sample.sd <- function(data, indices) {
  return(sd(data[indices], na.rm = T))
}
boot.Baseline <- boot(data=data1$Baseline, statistic=sample.sd, R=10000)
# view results of bootstrap
boot.Baseline
plot(boot.Baseline)
# 95% BCA confidence interval from Bootstrap of SD
bci <- boot.ci(boot.Baseline, type="bca", conf = 0.95)
table1[3, 2] <- round(mean(boot.Baseline$t),2) # avg of the bootstrap samples
table1[4, 2] <- paste(round(bci$bca[4],2),' to ', round(bci$bca[5],2))

boot.Year1 <- boot(data=data1$Year1, statistic=sample.sd, R=10000)
boot.Year1
plot(boot.Year1)
bci <- boot.ci(boot.Year1, type="bca", conf = 0.95)
table1[3, 4] <- mean(boot.Year1$t) # avg of the bootstrap samples
table1[4, 4] <- paste(round(bci$bca[4],2),' to ', round(bci$bca[5],2))

# Bootstrap the Proportion
sample.prop <- function(data, indices) {
  prop <- sum(data[indices] >= 500 & data[indices] <= 1500)/length(data[indices])
  return(prop)
}
boot.Baseline <- boot(data=data1$Baseline, statistic=sample.prop, R=10000)
# view results of bootstrap
boot.Baseline
plot(boot.Baseline)
# 95% BCA confidence interval from Bootstrap of SD
bci <- boot.ci(boot.Baseline, type="bca", conf = 0.95)
table1[5, 2] <- mean(boot.Baseline$t) # avg of the bootstrap samples
table1[6, 2] <- paste(round(bci$bca[4],2),' to ', round(bci$bca[5],2))

boot.Year1 <- boot(data=data1$Year1, statistic=sample.prop, R=10000)
boot.Year1
plot(boot.Year1)
bci <- boot.ci(boot.Year1, type="bca", conf = 0.95)
table1[5, 4] <- mean(boot.Year1$t) # avg of the bootstrap samples
table1[6, 4] <- paste(round(bci$bca[4],3),' to ', round(bci$bca[5],3))

remove(list = c('bci', 'boot.Baseline', 'boot.Year1'))
