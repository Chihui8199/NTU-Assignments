# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# =====================  Download Libraries to run code =========================================
if(!require("skimr"))install.packages("skimr")

# ================================ Load Libaries =========================================
library(data.table)
library(randomForest)
library(rstudioapi)
library(caTools)
library(ranger)
library(ggplot2)
library(tidymodels)
library(caret)
library(themis)
library(vip)
library(pROC)

# ================================ Load Data =========================================
data1<- fread("austin_diabetes.csv", na.strings = c(""), stringsAsFactors = T, header = T)
data1
sum(is.na(data1)) # no n.a values

# ============================== Build Basic Model =========================================
set.seed(1)
m.RF.1 <- randomForest(DiabetesStatus ~ . , data = data1, 
                       na.action = na.omit, 
                       importance = T, proximity = T, type = "classification")
m.RF.1 

# To see if 500 tress is enough for optimal classification, we can plot the error rates
trees <- c(25, 25, 25, 100, 100, 100, 500, 500, 500, 1000, 1000, 1000)
RSF <- rep.int(c(1, floor(sqrt(ncol(data1)-1)), ncol(data1)-1), times=4)
## Current RSF used is 1, 4, 20
OOB.error <- seq(1:12)

for (i in 1:length(trees)) {
  m.RF <- randomForest(DiabetesStatus ~ . , data=data1,
                       mtry=RSF[i],
                       ntree=trees[i],
                       na.action=na.omit)
  OOB.error[i] <- m.RF$err.rate[m.RF$ntree, 1]
}

par(mar = c(5,5,3,1))
plot(m.RF, type = "l", title(main = "OOB Error Rates Against Number of Trees"), lwd =1.5 ,pch = 0.1)
legend("topright", inset=.02, title="Type",
       c("Yes","OOB","No"), fill = c("Green", "black", "red"), horiz=TRUE, cex=0.8)
results <- data.frame(trees, RSF, OOB.error)
results[results$OOB.error == min(results$OOB.error), ]
## Ideal number of trees B = 1000, RSF = 4 #OOB.error = 0.27

# ============================== Basic Model Accuracy =========================================
# Final Un-tuned Model: Using Accuracy as a measurement of performance
train <- sample.split(Y = data1$DiabetesStatus, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)
m.RF.2 <- randomForest(DiabetesStatus~ ., 
                      data= trainset,
                      ntree=1000, 
                      proximity=TRUE, 
                      mtry = 4)

# TRAIN SET PREDICTION
prob.train <- predict(m.RF.2, type = 'class')

# confusion matrix for train set
RF_traintable <- table(Trainset.Actual = trainset$DiabetesStatus, prob.train, deparse.level = 2)
RF_traintable
#                     prob.train
#   Trainset.Actual  No Yes
#                No  436 108
#                Yes 151 263

# accuracy of train set
mean(prob.train == trainset$DiabetesStatus)
## 0.7296451
cfmatrix <- RF_traintable
falsenegative <- round((cfmatrix[2]) / (cfmatrix[2] + cfmatrix[4]),2)
falsenegative
## 0.36
falsepostitive <- round((cfmatrix[3]) / (cfmatrix[1] + cfmatrix[3]),2)
falsepostitive
## 0.20

# TEST SET PREDICTION
prob.test <- predict(m.RF.2, newdata = testset, type = 'class')

# confusion matrix for test set
RF_testtable <- table(Testset.Actual = testset$DiabetesStatus, prob.test, deparse.level = 2)
RF_testtable
#                 prob.test
# Testset.Actual   No Yes
#             No  172  61
#             Yes  70 107

# accuracy of test set
mean(prob.test == testset$DiabetesStatus)
## 0.6804878
cfmatrix <- RF_testtable
falsenegative <- round((cfmatrix[2]) / (cfmatrix[1] + cfmatrix[2] + cfmatrix[3] + cfmatrix[4]),2)
falsenegative
## 0.17
falsepostitive <- round((cfmatrix[3]) / (cfmatrix[1] + cfmatrix[2] + cfmatrix[3] + cfmatrix[4]),2)
falsepostitive
## 0.15

# ========================== Tune Model Hyper Parameters =========================================
set.seed(123)
trees_split <- initial_split(data1, strata = DiabetesStatus)
trees_train <- training(trees_split)
trees_test <- testing(trees_split)
trees_split ## <Training/Testing/Total>

tune_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) %>%
  set_mode("classification") %>%
  set_engine("ranger")

# Preparing the data to be used (Pre-Processing)
tree_rec <- recipe(DiabetesStatus ~ ., data = trees_train) %>%
  step_dummy(all_nominal(), -DiabetesStatus) %>%
  step_corr(all_predictors()) %>% ## remove variables that have large absolute correlations with other variables.
  step_downsample(DiabetesStatus) ## Downsampling to solve slightly inbalanced dataset
tree_prep <- prep(tree_rec)
tree_prep
juiced <- juice(tree_prep)
juiced

tune_spec <- rand_forest(
  mtry = tune(),
  trees = 1000, # Best number of trees from above is 1000
  min_n = tune()
  ) %>%
  set_mode("classification") %>%
  set_engine("ranger")
tune_spec

tune_wf <- workflow() %>%
  add_recipe(tree_rec) %>%
  add_model(tune_spec)
tune_wf

# Train Hyper-parameters
set.seed(234)
# 10 Fold Cross Validation (Train 924 and test on 103 data points)
trees_folds <- vfold_cv(trees_train)

# Set up parallel processing so that the dataset could be trained faster
library(doParallel) 
doParallel::registerDoParallel()

set.seed(345)
# Tune mtry and min_n on a grid
tune_res <- tune_grid(
  tune_wf,  ## Tuning on this workflow
  resamples = trees_folds, ## Tuning on this dataset here
  grid = 20, ## number of candidate parameter sets to be created automatically
  metrics = metric_set(roc_auc)
)
tune_res

# To see the accuracy for each of the cross validation model created
tune_res %>%
  collect_metrics()

tune_res %>%
  select_best(tune_res, metric = "roc_auc")
## mtry = 8 and min_n = 35 # Trees = 1000

tune_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "AUC")
## Appears that lower values of mtry can try mtry < 20
## min_n appears to be jumping around - can try range 2 to 40

# Tune again using more appropriate parameters and smaller grid
rf_grid <- grid_regular(
  mtry(range = c(1, 20)),
  min_n(range = c(2, 40)),
  levels = 5
)
rf_grid

set.seed(456)
regular_res <- tune_grid(
  tune_wf,
  resamples = trees_folds,
  grid = rf_grid,
  metrics = metric_set(roc_auc)
)
regular_res

regular_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "AUC")

regular_res %>%
  select_best(tune_res, metric = "roc_auc")
## final mtry = 5 and min_n = 2

regular_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  mutate(min_n = factor(min_n)) %>%
  ggplot(aes(mtry, mean, color = min_n)) +
  geom_line(alpha = 0.5, size = 1.5) +
  geom_point() +
  labs(y = "AUC")

best_auc <- select_best(regular_res, "roc_auc")
best_auc

final_rf <- finalize_model(
  tune_spec,
  best_auc
)
final_rf
## mtry = 5 and min_n = 2

# Variable Importance of the factors

final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(DiabetesStatus ~ .,
      data = juice(tree_prep)
  ) %>%
  vip(geom = "point")

final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(DiabetesStatus ~ .,
      data = juice(tree_prep)
  ) %>%
  vip(geom = "point")

final_wf <- workflow() %>%
  add_recipe(tree_rec) %>%
  add_model(final_rf)

final_res <- final_wf %>%
  last_fit(trees_split)

# ============================== Basic Model Acuracies =========================================
final_res %>%
  collect_metrics()
## accuracy: 0.730
## roc_auc: 0.800

data<- as.data.frame(final_res %>%  
  collect_predictions())

final_res %>% 
  collect_predictions() %>%
  conf_mat(truth = DiabetesStatus, estimate = .pred_class)
##            Truth
#Prediction  No Yes
##       No  132  30
##      Yes  62 117
cfmatrix <- matrix(c(132, 30, 62, 117), ncol=2, byrow=TRUE)
colnames(cfmatrix) <- c("No","Yes")
rownames(cfmatrix) <- c("No", "Yes")
cfmatrix <- as.table(cfmatrix)
cfmatrix

falsenegative <- round((cfmatrix[3]) / (cfmatrix[3] + cfmatrix[1]),2)
falsenegative
## 0.19
falsepostitive <- round((cfmatrix[2]) / (cfmatrix[2] + cfmatrix[4]),2)
falsepostitive
## 0.35


