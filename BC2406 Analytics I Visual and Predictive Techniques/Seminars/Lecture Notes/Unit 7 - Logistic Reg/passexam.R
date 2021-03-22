# ========================================================================================================
# Purpose:      Demo of Binary Logistic Regression model
# Author:       Neumann Chew
# DOC:          25-09-2017
# Topics:       Logistic Regression; Odds Ratios; OR Confidence Intervals.
# Data Source:  passexam.csv as in wikipedia
# Packages:     data.table  
#=========================================================================================================

library(data.table)

setwd("~/Desktop/Y2S1/BC2406/Unit 7 - Logistic Reg")

passexam.dt <- fread("passexam2.csv")
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
#q1) shows that the data can be perfectly separated. Each of the infinitely many points will give u the same ans
# if you have perfect serpartion you dont need a model and u dont even have a model.if u look at the summary the p value will look very weird 
# Set the threshold for predicting Y = 1 based on probability.
# if the number of var increase chances of persfect seperation increases too


threshold <- 0.5
                 
# If probability > threshold, then predict Y = 1, else predict Y = 0.
y.hat <- ifelse(prob > threshold, 1, 0)
                 
# Create a confusion matrix with actuals on rows and predictions on columns.
table(passexam.dt$Outcome, y.hat, deparse.level = 2)

# Overall Accuracy
mean(y.hat == passexam.dt$Outcome)
