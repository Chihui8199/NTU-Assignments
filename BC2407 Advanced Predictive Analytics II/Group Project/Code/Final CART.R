# =====================  Download Libraries to run code =========================================
if(!require("skimr"))install.packages("skimr")

#========================Read Data===========================
library(tidyverse)
library(data.table)
library(dplyr)
library(modeest)
library(quantreg)


set.seed(420.69)
# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))


data1<- fread("austin_diabetes.csv",  
              na.strings = c(""), stringsAsFactors = T, header = T)


library(caTools)
train <- sample.split(Y = data1$DiabetesStatus, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)



#CART
library(rpart)
library(rpart.plot)

#plotting cart model with entire dataset
cart <- rpart(DiabetesStatus ~ ., data = data1, method = 'class',
              control = rpart.control(minsplit = 2, cp = 0))
rpart.plot(cart, nn= T, main = "Maximal Tree in Diabetes Status")
print(cart)
printcp(cart)
plotcp(cart, main = "Subtrees in Diabetes Status")

#pruning cart model for entire dataset
cp1 <- sqrt(0.24365482 *0.01466441)
cartprune <- prune(cart, cp=cp1)
print(cartprune)
printcp(cartprune)
rpart.plot(cartprune, nn= T, main = "Pruned Tree")

#TRAIN TEST CHOOOOO

#plotting cart maximum tree for train set
cart_train <- rpart(DiabetesStatus ~ ., data = trainset, method = 'class',
                    control = rpart.control(minsplit = 2, cp = 0))
rpart.plot(cart_train, nn= T, main = "Maximal Tree in Train Set")
print(cart_train)
printcp(cart_train)
plotcp(cart_train, main = "Subtrees in Test Set")

#pruning cart for train set
cp1_train <- sqrt(0.24396135*0.01932367)
cartprune_train <- prune(cart_train, cp=cp1_train)
print(cartprune_train)
printcp(cartprune_train)
rpart.plot(cartprune_train, nn= T, main = "Pruned Train Tree")



#TRAIN SET PREDICTION
threshold1 <- 0.5
prob.train <- predict(cartprune_train, type = 'class')

#confusion matrix for train set
cartprune_traintable <- table(Trainset.Actual = trainset$DiabetesStatus, prob.train, deparse.level = 2)
cartprune_traintable

#accuracy of train set
mean(prob.train == trainset$DiabetesStatus)


#TEST SET PREDICTION
prob.test <- predict(cartprune_train, newdata = testset, type = 'class')

#confusion matrix for test set
cartprune_testtable <- table(Testset.Actual = testset$DiabetesStatus, prob.test, deparse.level = 2)
cartprune_testtable

#accuracy of test set
mean(prob.test == testset$DiabetesStatus)

