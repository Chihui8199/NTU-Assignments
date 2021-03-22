# ========================================================================================================
# Purpose:      Demo of Binary Logistic Regression model with multiple X
# Author:       Neumann Chew
# DOC:          25-09-2017
# Topics:       Logistic Regression; Odds Ratios; OR Confidence Intervals.
# Data Source:  default.csv as in ISLR Rpackage
# Packages:     data.table, caTools
#=========================================================================================================
library(data.table)
library(caTools)

setwd('C:/Users/neumann.chew/Dropbox/Datasets/AAD1/7_Logistic_Reg')

default.dt <- fread("default.csv", stringsAsFactors = T)

summary(default.dt)
cor(default.dt$AvgBal, default.dt$Income)

levels(default.dt$Default) # Baseline is Default = "No"

m1 <- glm(Default ~ . , family = binomial, data = default.dt)

summary(m1)
## Income is not sig in the presence of Avg balance and gender.
## To remove Income


m2 <- glm(Default ~ . -Income, family = binomial, data = default.dt)
summary(m2)

OR.m2 <- exp(coef(m2))
OR.m2

OR.CI.m2 <- exp(confint(m2))
OR.CI.m2


# Output the probability from the logistic function for all cases in the data.
prob <- predict(m2, type = 'response')

# If Threshold = 0.5 ---------------------------------------------
threshold1 <- 0.5
       
m2.predict <- ifelse(prob > threshold1, "Yes", "No")
                 
table1 <- table(Actual = default.dt$Default, m2.predict, deparse.level = 2)
table1
round(prop.table(table1),3)

# Overall Accuracy
mean(m2.predict == default.dt$Default)
#-------------------------------------------------------------------


# Train-Test split ---------------------------------------------------
set.seed(2)
train <- sample.split(Y = default.dt$Default, SplitRatio = 0.7)
trainset <- subset(default.dt, train == T)
testset <- subset(default.dt, train == F)

m3 <- glm(Default ~ . , family = binomial, data = trainset)
summary(m3)
## P-value for Gender is much higher than in m1.
## Due to data sacrificed for testset.

m4 <- glm(Default ~ . -Income, family = binomial, data = trainset)
summary(m4)
## P-value for Gender is much higher than in m2.
## Due to data sacrificed for testset.

OR <- exp(coef(m4))
OR

OR.CI <- exp(confint(m4))
OR.CI

# Confusion Matrix on Trainset
prob.train <- predict(m4, type = 'response')
m4.predict.train <- ifelse(prob.train > threshold1, "Yes", "No")
table3 <- table(Trainset.Actual = trainset$Default, m4.predict.train, deparse.level = 2)
table3
round(prop.table(table3),3)
# Overall Accuracy
mean(m4.predict.train == trainset$Default)

# Confusion Matrix on Testset
prob.test <- predict(m4, newdata = testset, type = 'response')
m4.predict.test <- ifelse(prob.test > threshold1, "Yes", "No")
table4 <- table(Testset.Actual = testset$Default, m4.predict.test, deparse.level = 2)
table4
round(prop.table(table4), 3)
# Overall Accuracy
mean(m4.predict.test == testset$Default)
# ---------------------------------------------------------------------------------


# What if we analyze balance in terms of a $500 increase instead of a $1 increase? -------
# What would be the odds ratio?

options(scipen=100)  # suppress scientific notation by using penalty
summary(default.dt$AvgBal)
sd(default.dt$AvgBal)
default2.dt <- default.dt
default2.dt[, bal500 := AvgBal/500]  # a 1 unit increase in bal500 is a $500 increase in balance
m5 <- glm(Default ~ Gender + bal500, family = binomial, data = default2.dt)
summary(m5)
OR.m5 <- exp(coef(m5))
OR.m5

OR.CI.m5 <- exp(confint(m5))
OR.CI.m5

# Alternative by modifying the OR equation to multiply the coef by the number to be incremented:
exp(500*5.738e-03)

## Whereas the OR for $1 increase in balance is very small [see m2],
## OR for $500 increase in balance is very big [see m5].
#---------------------------------------------------------------------------------------