# ========================================================================================================
# Purpose:      Compare Logistic Reg with CART, imbalanced vs balanced trainset. 
# Author:       Neumann Chew
# DOC:          05-10-2020
# Topics:       CART, unbalanced data.
# Data Source:  default.csv as in ISLR Rpackage
# Packages:     data.table, caTools, rpart, rpart.plot.
#=========================================================================================================
library(data.table)
library(caTools)
library(rpart)
library(rpart.plot)

setwd('C:/Dropbox/Datasets/AAD1/7_Logistic_Reg')

default.dt <- fread("default.csv", stringsAsFactors = T)

summary(default.dt)
cor(default.dt$AvgBal, default.dt$Income)

levels(default.dt$Default) # Baseline is Default = "No"


# Train-Test split ---------------------------------------------------
set.seed(2)
train <- sample.split(Y = default.dt$Default, SplitRatio = 0.7)
trainset <- subset(default.dt, train == T)
testset <- subset(default.dt, train == F)


# Logistic Reg excluding Income variable
m1 <- glm(Default ~ . -Income, family = binomial, data = trainset)
summary(m1)


# Logistic Reg Confusion Matrix on Testset
threshold1 <- 0.5
m1.prob <- predict(m1, newdata = testset, type = 'response')
m1.predict <- ifelse(m1.prob > threshold1, "Yes", "No")
table1 <- table(Testset.Actual = testset$Default, logreg.predict = m1.predict, deparse.level = 2)
table1
round(prop.table(table1), 3)
# Overall Accuracy
mean(m1.predict == testset$Default)
# ---------------------------------------------------------------------------------


# Optimal CART based on 1 SE rule
m2 <- rpart(Default ~ ., data = trainset, method = 'class',
            control = rpart.control(minsplit = 2, cp = 0))

printcp(m2)
## CV error consistently above 1 suggests problem due to imbalanced data.

plotcp(m2)
## 2nd tree is optimal

cp1 <- sqrt(0.0300429*0.1094421)

m3 <- prune(m2, cp = cp1)

print(m3)

m3$variable.importance
## Only AvgBal is important in optimal CART model m3.

cart.predict <- predict(m3, newdata = testset, type = "class")

table2 <- table(Testset.Actual = testset$Default, cart.predict, deparse.level = 2)
table2
round(prop.table(table2), 3)
# Overall Accuracy
mean(cart.predict == testset$Default)
## Comparable with logistic regression result.


# Sample the majority to address imbalanced data & use same testset to test ----
# Random sample from majority class Default = No and combine with Default = Yes to form new trainset -----
majority <- trainset[Default == "No"]

minority <- trainset[Default == "Yes"]

# Randomly sample the row numbers to be in trainset. Same sample size as minority cases. 
chosen <- sample(seq(1:nrow(majority)), size = nrow(minority))

# Subset the original trainset based on randomly chosen row numbers.
majority.chosen <- majority[chosen]

# Combine two data tables by appending the rows
trainset.bal <- rbind(majority.chosen, minority)
summary(trainset.bal)
## Check trainset is balanced.
# -------------------------------------------------------------------


# What do you think will happen if models train on balanced trainset, but test on original testset?

# Logistic Reg on balanced data --------------------------------------------------
m.log.bal <- glm(Default ~ . -Income, family = binomial, data = trainset.bal)
log.prob <- predict(m.log.bal, newdata = testset, type = 'response')
log.predict <- ifelse(log.prob > threshold1, "Yes", "No")
log.cm <- table(Testset.Actual = testset$Default, logisticReg.predict = log.predict, deparse.level = 2)
log.cm
round(prop.table(log.cm), 3)
## True positive increased but true negative decreased, as expected on balanced data.

# Overall Accuracy of Logistic Reg from balanced data
mean(log.predict == testset$Default)
## Overall accuracy decreased, as expected on balanced data.
# ---------------------------------------------------------------------------------

# CART on balanced data --------------------------------------------------
m.cart.bal <- rpart(Default ~ ., data = trainset.bal, method = 'class',
                   control = rpart.control(minsplit = 2, cp = 0))

printcp(m.cart.bal)
## CV errors below 1.

plotcp(m.cart.bal)
## 2nd tree is optimal

cp.bal <- sqrt(0.0064378*0.7768240)

m.cart.opt <- prune(m.cart.bal, cp = cp.bal)

cart.predict <- predict(m.cart.opt, newdata = testset, type = "class")

cart.cm <- table(Testset.Actual = testset$Default, cart.predict, deparse.level = 2)
cart.cm
round(prop.table(cart.cm), 3)
## True positive increased but true negative decreased, as expected on balanced data.

# Overall Accuracy
mean(cart.predict == testset$Default)
## Comparable with logistic regression result.
## Overall accuracy decreased, as expected on balanced data.

m.cart.opt$variable.importance
## AvgBal is still most impt while income shows usefulness only as a surrogate from balanced data. 
# ---------------------------------------------------------------------------------
