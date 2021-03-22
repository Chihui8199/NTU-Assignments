# -----------------------------------------------------------
# Author: Neumann Chew
# Date: 23 Sep 2016
# Purpose: R Script for Service Ratings Analytics
# ----------------------------------------------------------

library(nnet)

ratings.df <- read.csv("rating.csv", stringsAsFactors = T)

# Report summary statistics for each variable.
summary(ratings.df)

# Check and set baseline to Rating = Neutral
levels(ratings.df$Rating)  # Default baseline is Rating = Bad
ratings.df$Rating <- relevel(ratings.df$Rating, ref = "Neutral")
levels(ratings.df$Rating)  # Baseline is now changed to "Neutral"


# Logistic Regression with 3 categorical Y values.
ratings.fit <- multinom(Rating ~ . -Cust, data = ratings.df)
summary(ratings.fit)

OR <- exp(coef(ratings.fit))
OR

# Use OR CI to conclude on statistical significance of X variables.
OR.CI <- exp(confint(ratings.fit))
OR.CI


# Multinom function does not include p-value calculation.
# Calculate p-values using Z test.
# Optional as OR CI provides the same conclusion.
z <- summary(ratings.fit)$coefficients/summary(ratings.fit)$standard.errors
pvalue <- (1 - pnorm(abs(z), 0, 1))*2  # 2-tailed test p-values
pvalue


# Keep only statistically sig X in the model.
m.final <- multinom(Rating ~ WTQ, data = ratings.df)


# Output the logistic function prob for all cases from the final model.
prob <- predict(m.final, type = 'prob')
prob


# Model predicted service rating based on max prob among the 3 Y categories.
predicted_class <- predict(m.final)
predicted_class


# Create a confusion matrix with actuals on rows and predictions on columns based on the entire dataset.
table(Trainset.Actuals = ratings.df$Rating, Model.Predict = predicted_class, deparse.level = 2)

# Overall Accuracy
mean(predicted_class == ratings.df$Rating)

