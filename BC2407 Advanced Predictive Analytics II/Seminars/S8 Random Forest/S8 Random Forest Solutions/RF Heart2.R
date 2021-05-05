# Purpose: Random Forest on Heart.csv trying different combinations of B & RSF size.
# Author: Chew C. H.
# Data Source: https://archive.ics.uci.edu/ml/datasets/Heart+Disease

library(randomForest)

setwd("D:/NC/BC2407 Analytics 2/S8 Random Forest")

heart.df <- read.csv("Heart.csv")

B <- c(25, 25, 25, 100, 100, 100, 500, 500, 500)

RSF <- rep.int(c(1, floor(sqrt(ncol(heart.df)-1)), ncol(heart.df)-1), times=3)

OOB.error <- seq(1:9)

set.seed(1)  # for Bootstrap sampling & RSF selection.

for (i in 1:length(B)) {
  m.RF <- randomForest(AHD ~ . , data=heart.df,
                       mtry=RSF[i],
                       ntree=B[i],
                       na.action=na.omit)
  OOB.error[i] <- m.RF$err.rate[m.RF$ntree, 1]
}
## OOB Error across all trees stored in the last row in err.rate.

results <- data.frame(B, RSF, OOB.error)
## trying different seeds, OOB error is relatively low for B = 500, RSF = 3.
## these are default values in randomForest() function.

m.RF.final <- randomForest(AHD ~ . , data=heart.df, na.action=na.omit, importance=T)

m.RF.final  ## Confirms defaults are B = 500, RSF = int(sqrt(m)) = 3

var.impt <- importance(m.RF.final)

varImpPlot(m.RF.final)


