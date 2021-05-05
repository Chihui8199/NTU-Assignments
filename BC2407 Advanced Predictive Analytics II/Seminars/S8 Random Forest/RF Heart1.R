# Purpose: Random Forest on Heart.csv
# Author: Chew C. H.
# Data Source: https://archive.ics.uci.edu/ml/datasets/Heart+Disease

library(randomForest)
library(rstudioapi)

# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))
print( getwd() )



heart.df <- read.csv("Heart.csv", stringsAsFactors = T)

sum(is.na(heart.df))
## 6 missing values. Need to explicitly handle these in randomForest().
## Options: na.action = na.omit or na.action =  na.roughfix

set.seed(1)  # for Bootstrap sampling & RSF selection.

m.RF.1 <- randomForest(AHD ~ . , data = heart.df, 
                       na.action = na.omit, 
                       importance = T)

m.RF.1  ## shows defaults are B = 500, RSF size = int(sqrt(m)) = 3

var.impt <- importance(m.RF.1)

par("mar")
par(mar=c(1,1,1,1))
varImpPlot(m.RF.1, type = 1)


