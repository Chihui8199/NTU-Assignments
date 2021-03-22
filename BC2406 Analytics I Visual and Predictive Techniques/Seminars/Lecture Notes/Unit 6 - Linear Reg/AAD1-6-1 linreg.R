# ========================================================================================================
# Purpose:      Rscript for Linear Regression demo.
# Author:       Neumann Chew
# Updated:      18-09-2018
# Topics:       Correlation; Linear Regression; Diagnostics; Train vs Test set
# Data Source:  mtcars
# Packages:     corrplot, caTools, car
#=========================================================================================================


# Loads the standard dataset mtcars from a base package in R.
data(mtcars)

# Correlation Matrix
cor(mtcars)
round(cor(mtcars), 2)

# Correlation Plot
install.packages("corrplot")
library(corrplot)
corrplot(cor(mtcars), type = "upper")


plot(mtcars$mpg, mtcars$wt)
cor(mtcars$mpg, mtcars$wt)
## -0.8676594


plot(mtcars$mpg, mtcars$hp)
cor(mtcars$mpg, mtcars$hp)
## -0.7761684

plot(mtcars$mpg, mtcars$qsec)
cor(mtcars$mpg, mtcars$qsec)
## 0.418684


plot(mtcars$drat, mtcars$qsec)
cor(mtcars$drat, mtcars$qsec)
## 0.09120476


plot(mtcars$hp, mtcars$cyl)
cor(mtcars$hp, mtcars$cyl)
## 0.8324475





# Outcome Variable: MPG as higher MPG means costs savings on petrol.

# m1 with wt only -------------------------------------------------------------------
m1 <- lm(mpg ~ wt, data = mtcars)
summary(m1) # See the PPT file
plot(x = mtcars$wt, y = mtcars$mpg, main = "Regression Line with wt as sole factor")
abline(m1, col = "red")
identify(x = mtcars$wt, y = mtcars$mpg) # Identify the cases selected in Plot.

par(mfrow = c(2,2))  # Plot 4 charts in one plot - 2 by 2.
plot(m1)  # Plot model 1 diagnostics, See the PPT file
par(mfrow = c(1,1))  # Reset plot options to 1 chart in one plot.
#-------------------------------------------------------------------------------------

# m2 with Wt and Wt^2 ----------------------------------------------------------------
m2 <- lm(mpg ~ wt + I(wt^2), data = mtcars)
summary(m2)

par(mfrow = c(2,2))  # Plot 4 charts in one plot - 2 by 2.
plot(m2)  # Plot model 2 diagnostics
par(mfrow = c(1,1))  # Reset plot options to 1 chart in one plot.
# -------------------------------------------------------------------------------------

# m3 with wt and cyl ----------------------------------------------------------------
str(mtcars$cyl)
mtcars <- mtcars  # create a copy to preserve the orignal dataset.
mtcars$cyl <- factor(mtcars$cyl)
str(mtcars$cyl)  # Check data structure is now factor
levels(mtcars$cyl)
m3 <- lm(mpg ~ wt + cyl, data = mtcars)
summary(m3)  # See the PPT file

par(mfrow = c(2,2))
plot(m3)  # Plot model 3 diagnostics
par(mfrow = c(1,1))
# -----------------------------------------------------------------------------------

# m.full and m4 from backward elimination -------------------------------------------
mtcars$vs <- factor(mtcars$vs)  # vs: V-shaped engine vs. Straight engine
mtcars$am <- factor(mtcars$am)  # am: automatic transmission vs. manual transmission
mtcars$gear <- factor(mtcars$gear)  # gear: number of forward gears
mtcars$carb <- factor(mtcars$carb)  # carb: number of carburetors 
m.full <- lm(mpg ~ . , data = mtcars)  # . means all other variables
m4 <- step(m.full)  # Akaike Information Criterion
summary(m4)

par(mfrow = c(2,2)) # Plot 4 charts in one plot - 2 by 2.
plot(m4)  # Plot model 4 diagnostics
par(mfrow = c(1,1)) # Reset plot options to 1 chart in one plot.
# ------------------------------------------------------------------------------------


# VIF --------------------------------------------------------------------------------------------------------------
summary(m.full)  #cyl 4 > cyl 6 < cyl 8
plot(x = mtcars$cyl, y = mtcars$mpg, main ="The higher the cyl, the lower the mpg", xlab = "cyl", ylab = "mpg")

install.packages("car")
library(car)
vif(m.full) # many variables have adjusted GVIF above 2, that for cyl is way above 2
vif(m4)     # adjusted GVIF around or less than 2, coefficients are much more stable
summary(m4)
vif(m3)     # adjusted GVIF below 2
summary(m3)
vif(m2)     # VIF greater than 10, not a serious concern since wt^2 and wt are supposed to be highly correlated
summary(m2)
#--------------------------------------------------------------------------------------------------------------------


# Train-Test Split and m5 --------------------------------------------------------
install.packages("caTools")
library(caTools)

# Generate a random number sequence that can be reproduced to verify results.
set.seed(2004)

# 70% trainset. Stratify on Y = mpg. Caution: Sample size only 32 in this example.
train <- sample.split(Y = mtcars$mpg, SplitRatio = 0.7)
trainset <- subset(mtcars, train == T)
testset <- subset(mtcars, train == F)

# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$mpg)
summary(testset$mpg)

# Develop model on trainset
m5 <- lm(mpg ~ wt + cyl, data = trainset)
summary(m5)
residuals(m5) 

# Residuals = Error = Actual mpg - Model Predicted mpg
RMSE.m5.train <- sqrt(mean(residuals(m5)^2))  # RMSE on trainset based on m5 model.
summary(abs(residuals(m5)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.m5.test <- predict(m5, newdata = testset)
testset.error <- testset$mpg - predict.m5.test

# Testset Errors
RMSE.m5.test <- sqrt(mean(testset.error^2))
summary(abs(testset.error))

RMSE.m5.train 
RMSE.m5.test 
#-----------------------------------------------------------------------------------

# End ==============================================================================