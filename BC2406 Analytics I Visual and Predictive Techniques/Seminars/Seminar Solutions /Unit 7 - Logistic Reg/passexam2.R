# ========================================================================================================
# Purpose:      Demo of Binary Logistic Regression model for perfect separable data
# Author:       Neumann Chew
# DOC:          17-09-2019
# Topics:       perfect separable data
# Data Source:  passexam2.csv
# Packages:     data.table  
#=========================================================================================================
library(data.table)

setwd('C:/Users/neumann.chew/Dropbox/Datasets/AAD1/7_Logistic_Reg')

passexam2.dt <- fread("passexam2.csv")
passexam2.dt$Outcome <- factor(passexam2.dt$Outcome)

summary(passexam2.dt)

pass2.m1 <- glm(Outcome ~ Hours , family = binomial, data = passexam2.dt)
## Warning message due to perfect separable data (See plot below to verify).
## Do not use logistic regression.

plot(y=passexam2.dt$Outcome, x=passexam2.dt$Hours)
## Shows data can be perfectly separated. Thus, no need for logistic function.
