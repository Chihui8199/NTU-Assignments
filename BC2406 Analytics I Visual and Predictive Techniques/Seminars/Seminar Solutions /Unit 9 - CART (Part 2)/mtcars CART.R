# ==============================================================================================================
# Purpose:      Demo of CART for Continuous Y
# Author:       Neumann Chew
# DOC:          15-10-2017
# Topics:       Decision Trees, Decision Rules, CP, CV Error, Surrogates.
# Data Source:  mtcars
# Packages:     rpart, rpart.plot
#===============================================================================================================

# Loads a standard dataset mtcars from a base package in R.
# To predict mpg using CART on all Xs.
data(mtcars)

library(rpart)
library(rpart.plot)			# For Enhanced tree plots

set.seed(2014)

# Continuous Y: Set method = 'anova'
cart1 <- rpart(mpg ~ ., data = mtcars, method = 'anova', control = rpart.control(minsplit = 2, cp = 0))

printcp(cart1)
## Caution: printcp() shows that if you forgot to change the default CP from 0.01 to 0,
## It would have stopped the tree growing process too early. A lot of further growth at CP < 0.01.

plotcp(cart1)

print(cart1)


# 7th tree is optimal. Choose any CP value betw the 6th and 7th tree CP values.
cp1 <- sqrt(1.2149e-02*1.2488e-02)


# [Optional] Extract the Optimal Tree via code instead of eye power ------------
# Compute min CVerror + 1SE in maximal tree cart1.
CVerror.cap <- cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xerror"] + cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xstd"]

# Find the optimal CP region whose CV error is just below CVerror.cap in maximal tree cart1.
i <- 1; j<- 4
while (cart1$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}

# Get geometric mean of the two identified CP values in the optimal region if optimal tree has at least one split.
cp.opt = ifelse(i > 1, sqrt(cart1$cptable[i,1] * cart1$cptable[i-1,1]), 1)
# ------------------------------------------------------------------------------

## i = 7 shows that the 7th tree is optimal based on 1 SE rule.
## cp.opt is the same as cp1 (difference due to rounding off error.)


# Prune the max tree using a particular CP value
cart2 <- prune(cart1, cp = cp1)
printcp(cart2, digits = 3)
## --- Trainset Error & CV Error --------------------------
## Root node error: 1126/32 = 35.2
## cart2 trainset MSE = 0.0458 * 35.2 = 1.6
## cart2 CV MSE = 0.358 * 35.2 = 12.6

print(cart2)

rpart.plot(cart2, nn = T, main = "Optimal Tree in mtcars")
## The number inside each node represent the mean value of Y.

cart2$variable.importance
## Weight has the highest importance, disp is second impt.


# Surrogates shown in summary() ----------------------------
summary(cart2)

# Create missing values in first two rows
mtcars2 <- mtcars
mtcars2[1,6] <- NA   # first row, 6th col. wt is the 6th col.
mtcars2[2,6] <- NA
mtcars2[2,3] <- NA   # 3rd column is disp.

cart3 <- rpart(mpg ~ ., data = mtcars2, method = 'anova', control = rpart.control(minsplit = 2, cp = 0))

summary(cart3)
