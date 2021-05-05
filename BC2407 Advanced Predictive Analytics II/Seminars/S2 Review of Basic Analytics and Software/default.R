
library(data.table)
library(caTools)

setwd("~/Desktop/Y2S2/BC2407/S2 Review of Basic Analytics and Software")
default.dt <- fread("default.csv", stringsAsFactors = T)


summary(default.dt)
cor(default.dt$AvgBal, default.dt$Income)
levels(default.dt$Default) # Baseline is Default = "No"

# LOGISTIC REGRESSION Train-Test split ---------------------------------------------------
threshold1 <- 0.5
set.seed(2)
train <- sample.split(Y = default.dt$Default, SplitRatio = 0.7)
trainset <- subset(default.dt, train == T)
testset <- subset(default.dt, train == F)

m4 <- glm(Default ~ . -Income, family = binomial, data = trainset)
summary(m4)
## P-value for Gender is much higher than in m2.
## Due to data sacrificed for testset.

OR <- exp(coef(m4))
OR

OR.CI <- exp(confint(m4))
OR.CI

# Confusion Matrix on Trainset
prob.train <- predict(m4, type = 'response')
m4.predict.train <- ifelse(prob.train > threshold1, "Yes", "No")
table3 <- table(Trainset.Actual = trainset$Default, m4.predict.train, deparse.level = 2)
table3
round(prop.table(table3),3)
# Overall Accuracy
mean(m4.predict.train == trainset$Default)

# Confusion Matrix on Testset
prob.test <- predict(m4, newdata = testset, type = 'response')
m4.predict.test <- ifelse(prob.test > threshold1, "Yes", "No")
table4 <- table(Testset.Actual = testset$Default, m4.predict.test, deparse.level = 2)
table4
round(prop.table(table4), 3)
# Overall Accuracy
mean(m4.predict.test == testset$Default)

# CART --------------------------------------------------------------------------------

library(rpart)
library(rpart.plot)			# For Enhanced tree plots

set.seed(2014)

# Cat Y: Set method = 'class', should use the same data, as the logistic regression testset to compare both logisitc and CART
cart1 <- rpart(Default ~ ., data = default.dt, method = 'class', control = rpart.control(minsplit = 2, cp = 0)) # method = class because default = factor

printcp(cart1)
## Caution: printcp() shows that if you forgot to change the default CP from 0.01 to 0,
## It would have stopped the tree growing process too early. A lot of further growth at CP < 0.01.

plotcp(cart1)

print(cart1)

#root node error = very skewed, the error is relatively very rare

# Compute min CVerror + 1SE in maximal tree cart1.
CVerror.cap <- cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xerror"] + cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xstd"]

# Find the optimal CP region whose CV error is just below CVerror.cap in maximal tree cart1.
i <- 1; j<- 4
while (cart1$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}

# Get geometric mean of the two identified CP values in the optimal region if optimal tree has at least one split.
cp.opt = ifelse(i > 1, sqrt(cart1$cptable[i,1] * cart1$cptable[i-1,1]), 1)
# ---------------------------------------------------------------------------------------------------------
# Prune the max tree using a particular CP value
cart2 <- prune(cart1, cp = cp.opt)
printcp(cart2, digits = 3)
## --- Trainset Error & CV Error --------------------------
## Root node error: 333/10000 = 0.0333

## cart2 trainset MSE = 0.0458 * 35.2 = 1.6
## cart2 CV MSE = 0.358 * 35.2 = 12.6

print(cart2)

rpart.plot(cart2, nn = T, main = "Optimal Tree in default")

cart2$variable.importance
#AvgBal is most impt, then Income then Gender

summary(cart2)

#97% chance will not default, 2 % miclassification error, will default

