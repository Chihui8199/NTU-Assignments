# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# =====================  Download Libraries to run code =========================================
if (!require('xgboost')) install.packages('xgboost')
if (!require('ParBayesianOptimization')) install.packages('ParBayesianOptimization')

library(xgboost)
require(xgboost)
library(tidyverse)
library(rstudioapi)
library(caTools)
library(ranger)
library(readr)
library(stringr)
library(caret)
library(car)
library(Matrix)

library(data.table)
data1 = fread("austin_diabetes.csv", na.strings = c(""), stringsAsFactors = T, header = T)
dataxg = subset(data1, select = -c(V1))


# ============================== 70:30 Train Test Split ==============================
set.seed(234)
trainindex <- createDataPartition(dataxg$DiabetesStatus, p = .7,
                                  list = FALSE,
                                  times = 1)
trainxg <- dataxg[ trainindex,]
testxg <- dataxg[-trainindex,]

# ============================== Convert dataframe to Matrix ==============================
set.seed(123)

sparsetrain = sparse.model.matrix(DiabetesStatus ~ .-1, data = trainxg)
train_label = as.integer(trainxg$DiabetesStatus)-1
train_matrix = xgb.DMatrix(data=as.matrix(sparsetrain), label=train_label)

sparsetest = sparse.model.matrix(DiabetesStatus ~ .-1, data = testxg)
test_label = as.integer(testxg$DiabetesStatus)-1
test_matrix = xgb.DMatrix(data=as.matrix(sparsetest), label=test_label)

# ============================ Setting Parameters ============================
nc = length(unique(train_label))
xgb_params = list("objective"="multi:softprob", "eval_metric" = "mlogloss", "num_class"=nc)

watchlist = list(train = train_matrix, test=test_matrix)

# ============================ xgboost model 1 ============================
set.seed(123)
bst_model = xgb.train(params = xgb_params, 
                      data = train_matrix, 
                      nrounds = 100, 
                      watchlist = watchlist)

# ========================== training and test error plot 1 ==========================

e = data.frame(bst_model$evaluation_log)
plot(e$iter, e$train_mlogloss, col = 'blue')
lines(e$iter, e$test_mlogloss, col = 'red')

# ============================ smallest test set error 1 ============================
min(e$test_mlogloss) #0.584073 (smallest test set error)
e[e$test_mlogloss == 0.584073,] #iter 10

# ==================== prediction & confusion matrix - test data 1 ====================
set.seed(123)
ptrain = predict(bst_model, newdata = train_matrix)
pred = matrix(ptrain, nrow = nc, ncol = length(ptrain)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = train_label, max_prob = max.col(., "last")-1)

cfmatrixtrain = table(Prediction = pred$max_prob, Actual = pred$label)

confusionMatrix(cfmatrixtrain)

# Accuracy : 0.9342     
# 95% CI : (0.9166, 0.9491)
# Sensitivity : 0.9632          
# Specificity : 0.8961  

ptest = predict(bst_model, newdata = test_matrix)
pred = matrix(ptest, nrow = nc, ncol = length(ptest)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = test_label, max_prob = max.col(., "last")-1)

cfmatrixtest = table(Prediction = pred$max_prob, Actual = pred$label)

confusionMatrix(cfmatrixtest)

# Accuracy : 0.6683    
# 95% CI : (0.6204, 0.7137)
# Sensitivity : 0.6910           
# Specificity : 0.6384

# ======================= xgboost model 2 =========================
# change parameters
set.seed(345)
bst_model <- xgb.train(params = xgb_params, data = train_matrix, 
                       nrounds = 400, 
                       watchlist = watchlist, 
                       eta = 0.01,
                       max.depth = 10,
                       gamma = 0,
                       subsample = 0.5,
                       colsample_bytree = 0.5)

# ========================== training and test error plot 2 ==========================
e = data.frame(bst_model$evaluation_log)
plot(e$iter, e$train_mlogloss, col = 'blue')
lines(e$iter, e$test_mlogloss, col = 'red')

# ============================ smallest test set error 2 ============================
min(e$test_mlogloss) #0.56892 (smallest test set error)
e[e$test_mlogloss == 0.56892,] #iter 351

# ==================== prediction & confusion matrix - test data ====================
p = predict(bst_model, newdata = test_matrix)
pred = matrix(p, nrow = nc, ncol = length(p)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = test_label, max_prob = max.col(., "last")-1)

cfmatrix = table(Prediction = pred$max_prob, Actual = pred$label)

confusionMatrix(cfmatrix)

# Accuracy : 0.7024 
# Sensitivity : 0.7597          
# Specificity : 0.6271 

# ===================== finding the best parameters =======================
# =========== create a folds object to be used in the scoring function ==========
set.seed(4)

Folds <- list(
  Fold1 = as.integer(seq(1,nrow(train_matrix),by = 3))
  , Fold2 = as.integer(seq(2,nrow(train_matrix),by = 3))
  , Fold3 = as.integer(seq(3,nrow(train_matrix),by = 3))
)

# define the scoring function ======

set.seed(87)

scoringFunction <- function(max_depth, min_child_weight, subsample, colsample_bytree, nrounds) {
  sparsetrain = sparse.model.matrix(DiabetesStatus ~ .-1, data = trainxg)
  train_label = as.integer(trainxg$DiabetesStatus)-1
  train_matrix = xgb.DMatrix(data=as.matrix(sparsetrain), label=train_label)
  
  nc = length(unique(train_label))
  xgb_params = list("objective"="multi:softprob", "eval_metric" = "mlogloss", "num_class"=nc, 
                    "min_child_weight"=min_child_weight)
  
  watchlist = list(train = train_matrix, test=test_matrix)
  
  bst_model <- xgb.train(params = xgb_params, data = train_matrix, 
                         nrounds = nrounds, 
                         watchlist = watchlist, 
                         eta = 0.01,
                         max.depth = max_depth,
                         gamma = 0,
                         subsample = subsample,
                         colsample_bytree = colsample_bytree,
                         folds = Folds)
  
  return(
    list( 
      Score = max(bst_model$evaluation_log$test_mlogloss)
    )
  )
}

bounds <- list( 
  max_depth = c(2L, 10L)
  , min_child_weight = c(1, 25)
  , subsample = c(0.25, 1)
  , colsample_bytree = c(0.25, 1)
  , nrounds = c(400, 900)
)

library("ParBayesianOptimization")
set.seed(1)
optObj <- bayesOpt(
  FUN = scoringFunction
  , bounds = bounds
  , initPoints = 6
  , iters.n = 3
)

getBestPars(optObj)

#$max_depth
#[1] 7

#$min_child_weight
#[1] 14.62076

#$subsample
#[1] 0.4147561

#$colsample_bytree
#[1] 0.4664105

#$nrounds
#[1] 711.9362

# =========================== best xgboost model ===========================
set.seed(5667)

max_depth = 7
min_child_weight = 14.62076
subsample = 0.4147561
colsample_bytree = 0.4664105
nrounds = 711.9362

xgb_params = list("objective"="multi:softprob", "eval_metric" = "mlogloss", "num_class"=nc, 
                  "min_child_weight"=min_child_weight)

bst_model <- xgb.train(params = xgb_params, data = train_matrix, 
                       nrounds = nrounds, 
                       watchlist = watchlist, 
                       eta = 0.01,
                       max.depth = max_depth,
                       gamma = 0,
                       subsample = subsample,
                       colsample_bytree = colsample_bytree,
                       folds = Folds)

# ========================== final training and test error plot ==========================
e = data.frame(bst_model$evaluation_log)
plot(e$iter, e$train_mlogloss, col = 'blue')
lines(e$iter, e$test_mlogloss, col = 'red')

# ============================ final smallest test set error ============================
min(e$test_mlogloss) #0.571428
e[e$test_mlogloss == 0.571428,] # iter 708

# ==================== prediction & confusion matrix - test data ====================
set.seed(123)
ptrain = predict(bst_model, newdata = train_matrix)
pred = matrix(ptrain, nrow = nc, ncol = length(ptrain)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = train_label, max_prob = max.col(., "last")-1)

cfmatrixtrain = table(Prediction = pred$max_prob, Actual = pred$label)

confusionMatrix(cfmatrixtrain)

# Accuracy : 0.7704 
# 95% CI : (0.7424, 0.7966)
# Sensitivity : 0.8272          
# Specificity : 0.6957 --> false negative rate = 0.3043

ptest = predict(bst_model, newdata = test_matrix)
pred = matrix(ptest, nrow = nc, ncol = length(ptest)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = test_label, max_prob = max.col(., "last")-1)

cfmatrixtest = table(Prediction = pred$max_prob, Actual = pred$label)

confusionMatrix(cfmatrixtest)

# Accuracy : 0.7073         
# 95% CI : (0.6607, 0.7509)
# Sensitivity : 0.7511        
# Specificity : 0.6497 --> false negative rate = 0.3503

# ==== variable importance =====
imp = xgb.importance(colnames(train_matrix), model = bst_model)
print(imp)
xgb.plot.importance(imp)

