# =====================  Download Libraries to run code =========================================
if(!require("skimr"))install.packages("skimr")

# ================================ Load Data =========================================
library(tidyverse)
library(data.table)
library(dplyr)
library(modeest)
library(neuralnet)
library(fastDummies)
library(caTools)
library(boot)

set.seed(420.69)
# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

data1 = fread("austin_diabetes.csv",  na.strings = c(""), 
              stringsAsFactors = T, header = T)

neuraldata1 <- data1
summary(neuraldata1)

# ========================= Neural network ====================================

# Converting diabetes status to 1/0
neuraldata1$DiabetesStatus <- ifelse(neuraldata1$DiabetesStatus == "Yes", 1, 0)
#scaling continuous variable "Age" so that it is significant.
neuraldata1$Age1 <- (neuraldata1$Age - min(neuraldata1$Age))/(max(neuraldata1$Age)-min(neuraldata1$Age))
#see distribution of age
hist(neuraldata1$Age1)

# Create dummy variables
dum_col <- c("TobaccoUse","HeartDisease","PreviousDiabetesEducation", "HighBloodPressure", 
             "Gender", "DiabetesKnowledge", "EducationLevel", "FoodMeasurement", 
             "CarboCount", "SugarBevConsumption", "FruitsVegetableConsumption", "InsuranceCategory",
             "Exercise", "MedicalHomeCategory", "Income", "Gender", "RaceEthnicity")

neuraldata1 <- dummy_cols(neuraldata1, select_columns = dum_col)

# Converting column names into standard convention
names(neuraldata1) <- make.names(names(neuraldata1))

# Dropping useless columns
neuraldata1 <- subset(neuraldata1, 
                      select = -c(TobaccoUse,HeartDisease,PreviousDiabetesEducation, HighBloodPressure, 
                                  Gender, DiabetesKnowledge, EducationLevel, 
                                  FoodMeasurement, CarboCount, SugarBevConsumption, 
                                  FruitsVegetableConsumption, InsuranceCategory,
                                  Exercise, MedicalHomeCategory, Income, Gender,
                                  ClassLanguage, Year, RaceEthnicity, Age))

# =============== Initial Train Test split ================================

# To find if number of hidden layers and network affect model accuracy

train <- sample.split(Y = neuraldata1$DiabetesStatus, SplitRatio = 0.7)
trainset <- subset(neuraldata1, train == T)
testset <- subset(neuraldata1, train == F)

# Optimizing hidden layers

layer1 = c(1,2,3,4,5,6)
layer2 = c(1,2,3)
layer3 = c(1,2)

length1 <- length(layer1)
length2 <- length(layer2)
length3 <- length(layer3)
totallength <- length1 + (length1 * length2) + (length1 * length2 * length3)

table1 <- data.frame('Layers_Nodes' = 1:totallength, 'Accuracy' = 1:totallength, 
                     'FalsePositive' = 1:totallength, 'FalseNegative' = 1:totallength)
table1[] <- lapply(table1, as.character)
table1$Accuracy <- NA
table1$FalsePositive <- NA
table1$FalseNegative <- NA

# Function to test neural model and store accuracy in table1
neuraltest <- function(model, dataset, df, rownumber) {
  neuralresults1 <- compute(model, dataset)
  results <- data.frame(actual = dataset$DiabetesStatus, prediction = neuralresults1$net.result)
  roundedresults <- sapply(results,round,digits=0)
  roundedresultsdf <- data.frame(roundedresults)
  attach(roundedresultsdf)
  cfmatrix <- table(actual,prediction)
  
  accuracy <- round((cfmatrix[1] + cfmatrix [4]) / (cfmatrix[1] + cfmatrix[2] + cfmatrix[3] + cfmatrix[4]),2)
  falsenegative <- round((cfmatrix[2]) / (cfmatrix[2] + cfmatrix[4]),2)
  falsepostitive <- round((cfmatrix[3]) / (cfmatrix[1] + cfmatrix[3]),2)
  df[rownumber,2] <- accuracy
  df[rownumber,3] <- falsepostitive
  df[rownumber,4] <- falsenegative
  return(df)
}


# Do not need to tune learning rate since we are using resilient backprogagation

# Threshold tuning
thresholdtime <- 0.01

# 1 layer model   
time1 <- system.time(
  for (i in layer1){
    neural1 <- neuralnet(DiabetesStatus ~ . , data = trainset, hidden = c(i), threshold = thresholdtime,
                         stepmax = 1e20, err.fct="ce", linear.output=FALSE)
    table1[i, 1] <- paste(i)
    table1 <- neuraltest(neural1, testset, table1, i)
    print(table1)
  })

# 2 layer model 
counter <- 0
time2 <- system.time(
  for (j in layer2){
    for (i in layer1){
      counter <- counter + 1
      neural1 <- neuralnet(DiabetesStatus ~ . , data = trainset, hidden = c(i, j), threshold = thresholdtime, 
                           stepmax = 1e20, err.fct="ce", linear.output=FALSE)
      table1[(length1 + counter), 1] <- paste(i, ",", j)
      table1 <- neuraltest(neural1, testset, table1, (length1 + counter))
      print(table1)
    }
  })

# 3 layer model
counter <- 0 
time3 <- system.time(
  for (k in layer3){
    for (j in layer2){
      for (i in layer1){
        counter <- counter + 1
        neural1 <- neuralnet(DiabetesStatus ~ . , data = trainset, hidden = c(i, j, k), threshold = thresholdtime,
                             stepmax = 1e20, err.fct="ce", linear.output=FALSE)
        table1[(length1 + (length1 * length2) + counter), 1] <- paste(i, ",", j, ",", k)
        table1 <- neuraltest(neural1, testset, table1, (length1 + (length1 * length2) + counter))
        print(table1)
      }
    }
  })

# Not significant change in model accuracy between a 1-layer, 2-layer and 3-layer neural network

# ==================== 10-fold CV ======================

# Since number of hidden layers does not affect model accuracy, let's drop the 3rd layer
# Neuralnet uses random initial weights to train the model, resulting in changing weights and model accuracy
# Replace train-test split with 10-fold CV to get a more stable model accuracy

# Optimizing hidden layers

layer1 = c(1,2,3,4,5,6)
layer2 = c(1,2,3)

length1 <- length(layer1)
length2 <- length(layer2)
totallength <- length1 + (length1 * length2)

table1 <- data.frame('Layers_Nodes' = 1:totallength, 'Accuracy' = 1:totallength, 
                     'FalsePositive' = 1:totallength, 'FalseNegative' = 1:totallength)
table1[] <- lapply(table1, as.character)
table1$Layers_Nodes <- NA
table1$Accuracy <- NA
table1$FalsePositive <- NA
table1$FalseNegative <- NA

# Threshold tuning
thresholdtime <- 0.01

# 10-fold CV
neuraldata1 <- neuraldata1[sample(nrow(neuraldata1)),]
# Create 10 equally size folds
folds <- cut(seq(1,nrow(neuraldata1)),breaks=10,labels=FALSE)
# table to store CV results
table2 <- data.frame('Accuracy' = 1:10, 
                     'FalsePositive' = 1:10, 'FalseNegative' = 1:10)
table2$Accuracy <- NA
table2$FalsePositive <- NA
table2$FalseNegative <- NA

# Function to store CV results and return mean results
neuraltest_cv <- function(model, dataset, df, rownumber) {
  neuralresults1 <- compute(model, dataset)
  results <- data.frame(actual = dataset$DiabetesStatus, prediction = neuralresults1$net.result)
  roundedresults <- sapply(results,round,digits=0)
  roundedresultsdf <- data.frame(roundedresults)
  attach(roundedresultsdf)
  cfmatrix <- table(actual,prediction)
  
  accuracy <- round((cfmatrix[1] + cfmatrix [4]) / (cfmatrix[1] + cfmatrix[2] + cfmatrix[3] + cfmatrix[4]),2)
  falsenegative <- round((cfmatrix[2]) / (cfmatrix[2] + cfmatrix[4]),2)
  falsepostitive <- round((cfmatrix[3]) / (cfmatrix[1] + cfmatrix[3]),2)
  df[rownumber,1] <- accuracy
  df[rownumber,2] <- falsepostitive
  df[rownumber,] <- falsenegative
  return(df)
}

# 1 layer model
for (i in layer1){
  #Perform 10 fold cross validation
  for(j in 1:10){
    #Segement your data by fold using the which() function 
    testIndexes <- which(folds==j,arr.ind=TRUE)
    testset <- neuraldata1[testIndexes, ]
    trainset <- neuraldata1[-testIndexes, ]
    # Training the model
    neural1 <- neuralnet(DiabetesStatus ~ . , data = trainset, hidden = c(i), threshold = thresholdtime,
                         stepmax = 1e20, err.fct="ce", linear.output=FALSE)
    # Testing the model
    table2 <- neuraltest_cv(neural1, testset, table2, j)
  }
  table1[i, 1] <- paste(i)
  table1[i, 2] <- mean(table2$Accuracy)
  table1[i, 3] <- mean(table2$FalsePositive)
  table1[i, 4] <- mean(table2$FalseNegative)
  print(table1)
}


# 2 layer model 
counter <- 0
for (j in 1:3){
  for (i in 1:6){
    counter <- counter + 1
    for (k in 1:10){
      #Segement your data by fold using the which() function 
      testIndexes <- which(folds==j,arr.ind=TRUE)
      testset <- neuraldata1[testIndexes, ]
      trainset <- neuraldata1[-testIndexes, ]
      # Training the model
      neural1 <- neuralnet(DiabetesStatus ~ . , data = trainset, hidden = c(i, j), threshold = 0.1, 
                           stepmax = 1e20, err.fct="ce", linear.output=FALSE)
      # Testing the model
      table2 <- neuraltest_cv(neural1, testset, table2, k)
    }

    table1[(length1 + counter), 1] <- paste(i, ",", j)
    table1[(length1 + counter), 2] <- mean(table2$Accuracy)
    table1[(length1 + counter), 3] <- mean(table2$FalsePositive)
    table1[(length1 + counter), 4] <- mean(table2$FalseNegative)    
    print(table1)
  }
}




