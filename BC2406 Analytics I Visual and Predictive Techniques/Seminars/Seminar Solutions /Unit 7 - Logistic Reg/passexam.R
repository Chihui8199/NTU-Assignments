# ========================================================================================================
# Purpose:      Demo of Binary Logistic Regression model
# Author:       Neumann Chew
# DOC:          25-09-2017
# Topics:       Logistic Regression; Odds Ratios; OR Confidence Intervals.
# Data Source:  passexam.csv as in wikipedia
# Packages:     data.table  
#=========================================================================================================

library(data.table)

setwd('C:/Users/neumann.chew/Dropbox/Datasets/AAD1/7_Logistic_Reg')

passexam.dt <- fread("passexam.csv")
passexam.dt$Outcome <- factor(passexam.dt$Outcome)

summary(passexam.dt)

pass.m1 <- glm(Outcome ~ Hours , family = binomial, data = passexam.dt)

summary(pass.m1)
## Z = -4.0777 + 1.5046(Hours)

OR <- exp(coef(pass.m1))
OR

OR.CI <- exp(confint(pass.m1))
OR.CI


# Output the probability from the logistic function for all cases in the data.
prob <- predict(pass.m1, type = 'response')
# See the S curve
plot(x = passexam.dt$Hours, y = prob, type = "l", main = 'Logistic Regression Probability of Passing Exam')

# Set the threshold for predicting Y = 1 based on probability.
threshold <- 0.5
                 
# If probability > threshold, then predict Y = 1, else predict Y = 0.
y.hat <- ifelse(prob > threshold, 1, 0)
                 
# Create a confusion matrix with actuals on rows and predictions on columns.
table(passexam.dt$Outcome, y.hat, deparse.level = 2)

# Overall Accuracy
mean(y.hat == passexam.dt$Outcome)
