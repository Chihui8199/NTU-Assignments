# ========================================================================================================
# Purpose:      RF on Resale Flat Price
# Author:       Neumann Chew
# DOC:          12-03-2020
# Topics:       Random Forest
# Data:         resale-flat-prices-2019.csv from Housing & Dev Board.
#=========================================================================================================

library(caTools)            # Train-Test Split
library(earth)              # MARS
library(randomForest)       # Random Forest

setwd("C:/NC/Datasets/HDB")

data1 <- read.csv("resale-flat-prices-2019.csv", stringsAsFactors = T)

sum(is.na(data1))
## verifies no missing values


# Compute remaining_lease_years and remove two columns ------------------------
data1$remaining_lease_years = 99 - (2019 - data1$lease_commence_date)
data1$lease_commence_date <- NULL
data1$remaining_lease <- NULL
data1$street_name <- NULL
data1$block <- NULL


# Change the Baseline Reference level for Town to Yishun instead of default.
data1$town <- relevel(data1$town, ref = "YISHUN")
levels(data1$town)   # Verifies "YISHUN" is now first factor i.e. baseline ref.


# Train-test split ---------------------------------------------------------
set.seed(2)
train <- sample.split(Y=data1$resale_price, SplitRatio = 0.7)
trainset <- subset(data1, train==T)
testset <- subset(data1, train==F)


# MARS degree 2 -------------------------------------------------------------
m.mars2 <- earth(resale_price ~ ., degree=2, data=trainset)

m.mars2.yhat <- predict(m.mars2, newdata = testset)

RMSE.test.mars2 <- round(sqrt(mean((testset$resale_price - m.mars2.yhat)^2)))

# Estimated Variable Importance in degree 2 MARS
var.impt.mars <- evimp(m.mars2)
print(var.impt.mars)
## Floor Area is relatively most impt, followed by remaining lease.
## Town is not grouped into one category but shows dummy variables.


# RF at default settings of B & RSF size -------------------------------------
