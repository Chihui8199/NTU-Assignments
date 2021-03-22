# ========================================================================================================
# Purpose:      Rscript for Startbucks Linear Regression Exercise.
# Author:       Neumann Chew
# DOC:          11-09-2017
# Topics:       Linear Regression; VIFs.
# Data Source:  StarbucksPrepaid.csv; StarbucksGrowth.csv.
# Packages:     car
#=========================================================================================================

setwd("D/6 Linear Regression/Linear Reg for Starbucks")

data1 <- read.csv("StarbucksPrepaid.csv")

# Q1
m1 <- lm(Amount ~ ., data = data1)  # fit all other variables
summary(m1)
## Most promising is income.


# Q2
m2 <- lm(Days ~ Age + Income + Cups, data = data1)
summary(m2)
## Most promising is Number of Cups of Coffee per day.


# Q3
data2 <- read.csv(file="StarbucksGrowth.csv")
m3 <- lm(Revenue ~ . -Year, data = data2)  # fit all other variables except Year.
summary(m3)
## Key Predictor is Ave Weekly Earnings. Due to strange negative coef in Stores and Drinks, check VIF.


library(car) # for vif function.
vif(m3)
## VIFs are all > 10.

m4 <- lm(Revenue ~ Stores + Drinks, data = data2)  # Removed Ave Weekly Earnings as it has highest VIF.
summary(m4)


vif(m4)
## now their VIFs < 10.
