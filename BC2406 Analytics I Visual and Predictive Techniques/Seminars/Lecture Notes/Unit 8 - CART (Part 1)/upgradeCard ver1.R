# ==============================================================================================================
# Purpose:      Demo of CART: Targeted Marketing
# Author:       Chew C.H.
# DOC:          10-10-2017
# Topics:       CART, Decision Rules, cp, CV Error.
# Data Source:  upgradeCard.csv
# Packages:     data.table, rpart, rpart.plot
#===============================================================================================================

library(data.table)
library(rpart)
library(rpart.plot)         # For Enhanced tree plots.

setwd('D:/Dropbox/Datasets/ADA1/8_CART')
custdata1.dt <- fread("upgradeCard.csv", stringsAsFactors=T)
summary(custdata1.dt)

set.seed(2004)          # For randomisation in 10-fold CV.

# rpart() completes phrase 1 & 2 automatically.
# Change two default settings in rpart: minsplit and cp.
m2 <- rpart(Upgrade ~ Spending + SuppCard, data = custdata1.dt, method = 'class',
            control = rpart.control(minsplit = 2, cp = 0))

# plots the maximal tree and results.
rpart.plot(m2, nn= T, main = "Maximal Tree in upgradeCard.csv")

# prints the maximal tree m2 onto the console.
print(m2)

# prints out the pruning sequence and 10-fold CV errors, as a table.
printcp(m2)

# Display the pruning sequence and 10-fold CV errors, as a chart.
plotcp(m2, main = "Subtrees in upgradeCard.csv")

# plotcp uses geometric mean of prune triggers to represent cp on x-axis.
sqrt(0.051282 * 0.615385)
sqrt(0.038462 * 0.051282)

cp1 <- 0.18

m3 <- prune(m2, cp = cp1)

printcp(m3)

# plots the tree m3 pruned using cp1.
rpart.plot(m3, nn= T, main = "Pruned Tree with cp = 0.18")

# Test CART model m3 predictions
testcases <- data.frame(Spending = c(8000, 10000, NA), SuppCard = c("Y", NA, NA))

cart.predict <- predict(m3, newdata = testcases, type = "class")

results <- data.frame(testcases, cart.predict)

# =============== END Of Version 1 =============================================