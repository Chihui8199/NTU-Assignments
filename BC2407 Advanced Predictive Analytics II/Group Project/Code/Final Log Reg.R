# =====================  Download Libraries to run code =========================================
if(!require("skimr"))install.packages("skimr")

# Import Excel===================================
library(tidyverse)
library(data.table)
library(dplyr)
library(modeest)
library(scales)
library(nnet)
library(ggplot2)
library(caTools)
library(rpart)
library(rpart.plot)	
library(ggcorrplot)
library(caret)
library(DMwR)
library(car)
library(pROC)


set.seed(420.69)
# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

data1<- fread("austin_diabetes.csv", stringsAsFactors = T, header = T)

summary (data1)
# 70/30 Train-test split =========================================================
round(prop.table(table(data1$DiabetesStatus)),3)
train <- sample.split(Y = data1$DiabetesStatus, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)
threshold1 <- 0.5

# log1 Logistic Regression with everything =======================================
log1 <- glm(DiabetesStatus ~ . , family = binomial, data = trainset)
summary(log1)    
vif(log1) #full logistic regression

#there are aliased coefficients in the model
attributes(alias(log1)$Complete)$dimnames[[1]] #income not Low

log1.new <- glm (DiabetesStatus ~ . - Income, family = binomial, data = trainset)
summary(log1.new)    
vif(log1.new) #full new logistic regression


OR <- exp(coef(log1.new))
OR

OR.CI <- exp(confint(log1.new))
OR.CI

# Confusion Matrix on Trainset
prob.train.log1.new<- predict(log1.new, type = 'response')
log1.new.predict.train <- ifelse(prob.train.log1.new > threshold1, "Yes", "No")
table1 <- table(Trainset.Actual = trainset$DiabetesStatus, log1.new.predict.train, deparse.level = 2)
table1
round(prop.table(table1),3)
# Overall Accuracy
mean(log1.new.predict.train == trainset$DiabetesStatus)

# Confusion Matrix on Testset
prob.test.log1.new <- predict(log1.new, newdata = testset, type = 'response')
log1.new.predict.test <- ifelse(prob.test.log1.new > threshold1, "Yes", "No")
table2 <- table(log1.new.predict.test, Testset.Actual = testset$DiabetesStatus, deparse.level = 2)
table2
round(prop.table(table2), 3)
# Overall Accuracy
mean(log1.new.predict.test == testset$DiabetesStatus)

# log2 Logistic Regression except those irrelevant =======================================
log2 <- glm(DiabetesStatus ~ 
              Age+ 
              Gender + 
              MedicalHomeCategory + 
              EducationLevel+
              HighBloodPressure+
              PreviousDiabetesEducation+
              SugarBevConsumption+
              CarboCount+
              Exercise, family = binomial, data = trainset)
vif(log2) #reduced logistic regression

summary(log2)

OR <- exp(coef(log2))
OR

OR.CI <- exp(confint(log2))
OR.CI

# Confusion Matrix on Trainset
threshold1 <- 0.5
prob.train.log2 <- predict(log2, type = 'response')
log2.predict.train <- ifelse(prob.train.log2 > threshold1, "Yes", "No")
table3 <- table(Trainset.Actual = trainset$DiabetesStatus, log2.predict.train, deparse.level = 2)
round(prop.table(table3),3)
# Overall Accuracy
mean(log2.predict.train == trainset$DiabetesStatus)

# Confusion Matrix on Testset
prob.test.log2 <- predict(log2, newdata = testset, type = 'response')
log2.predict.test <- ifelse(prob.test.log2 > threshold1, "Yes", "No")
table4 <- table(log2.predict.test, Testset.Actual = testset$DiabetesStatus, deparse.level = 2)
table4
round(prop.table(table4), 3)

# Overall Accuracy on testset
mean(log2.predict.test == testset$DiabetesStatus)

sensitivity(table4) #True Positive Rate
specificity(table4) #True Negative Rate
1-sensitivity(table4) #False Negative Rate
1-specificity(table4) #False Positive Rate






