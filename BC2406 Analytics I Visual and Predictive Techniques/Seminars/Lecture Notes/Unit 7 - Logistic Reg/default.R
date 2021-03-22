# ========================================================================================================
# Purpose:      Demo of Binary Logistic Regression model
# Author:       Neumann Chew
# DOC:          25-09-2017
# Topics:       Logistic Regression; Odds Ratios; OR Confidence Intervals.
# Data Source:  passexam.csv as in wikipedia
# Packages:     data.table  
#=========================================================================================================

library(data.table)
setwd("~/Desktop/Y2S1/BC2406/Unit 7 - Logistic Reg")
# use stringasfactor to set factor shortcut
data.dt <- fread("default.csv", stringsAsFactors = T)

# 2. Execute logistic regression on default.csv dataset to predict default:
# IMPT: a. Verify the baseline reference level for (i,e what is Y =0) default. 
# Why must we verify is y = 0 yes or no or vice versa?
# In the software itself it will go by the alphabetical order so you must know whether u are predict y = 0 or y = 1?
summary(data.dt)
cor(data.dt$AvgBal1, data.dt$Income)
levels(data.dt$Default) # Baseline is Default is NO 

#2b.Which variables are statistically insignificant?
x <- glm(factor(Default) ~ factor(Gender), AvgBal, Income, family = binomial, data = data.dt)
summary(x)

#c. Keeping only statistically significant variables, show the confusion matrix.
#d. Using set.seed(2) with 70-30 train-test splt, and keeping only statistically significant variables, show the trainset confusion matrix and testset confusion matrix.
#IMPT: e. An analyst commented that AvgBal is a weak predictor of Default. Do you agree? Explain.




