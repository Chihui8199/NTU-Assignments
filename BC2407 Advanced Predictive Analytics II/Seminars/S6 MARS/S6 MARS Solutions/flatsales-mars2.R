# ========================================================================================================
# Purpose:      Single variate Adaptive Regression Splines demo.
# Author:       Neumann Chew
# DOC:          17-02-2020
# Topics:       MARS, Hinge Function, non-linear trend, Single X
# Data:         5 room flat resale applications.csv from Housing & Dev Board.
#=========================================================================================================

library(earth)   # MARS

setwd("C:/Users/ngjun/OneDrive/Desktop/Y3S2/BC2407/Classes/S6 MARS Solutions")

data.sales <- read.csv("5 room flat resale applications.csv")

# Create an integer time step to rep time sequence
data.sales$t <- seq(1:nrow(data.sales))

plot(y=data.sales$Sales.5rm, x=data.sales$t,
     xlab = "t (2007 Q1 to 2019 Q4)",
     ylab = "Sales (in units of flat)",
     main = "Sales of 5 Room Resale Flat",
     sub = "Source: HDB")
  

m.sales.lin1 <- lm(Sales.5rm ~ t, data = data.sales)

summary(m.sales.lin1)

RMSE.sales.lin1 <- round(sqrt(mean(m.sales.lin1$residuals^2)))

# To consolidate and report RMSE for various models 
Model <- c("Linear Reg degree 1"); RMSE <- RMSE.sales.lin1;


m.sales.lin2 <- lm(Sales.5rm ~ t + I(t^2), data = data.sales)

summary(m.sales.lin2)

RMSE.sales.lin2 <- round(sqrt(mean(m.sales.lin2$residuals^2)))

# To consolidate and report RMSE for various models 
Model <- c(Model, "Linear Reg degree 2"); RMSE <- c(RMSE, RMSE.sales.lin2);


m.sales.lin3 <- lm(Sales.5rm ~ t + I(t^2) + I(t^3), data = data.sales)


summary(m.sales.lin3)

RMSE.sales.lin3 <- round(sqrt(mean(m.sales.lin3$residuals^2)))

# To consolidate and report RMSE for various models 
Model <- c(Model, "Linear Reg degree 3"); RMSE <- c(RMSE, RMSE.sales.lin3);


# Plot the linear, quad and cubic curves on scatterplot.
abline(m.sales.lin1, col = "blue")
lines(x = data.sales$t, y=predict(m.sales.lin2), col='green')
lines(x = data.sales$t, y=predict(m.sales.lin3), col='orange')


# MARS Degree = 1 ------------------------------------------
m.mars1 <- earth(Sales.5rm ~ t, degree = 1, data=data.sales)

summary(m.mars1)

m.mars1.yhat <- predict(m.mars1)
## Alternatively get yhat from m.mars1$fitted.values

RMSE.mars1 <- round(sqrt(mean((data.sales$Sales.5rm - m.mars1.yhat)^2)))
## Alternatively get RMSE from sqrt((m.mars1$rss)/nrow(data.sales))

# To consolidate and report RMSE for various models 
Model <- c(Model, "MARS degree 1"); RMSE <- c(RMSE, RMSE.mars1);

# Superimpose MARS prediction line on scatterplot
lines(x = data.sales$t, y=predict(m.mars1), col='red')


# MARS Degree = 2 -----------------------------------------
m.mars2 <- earth(Sales.5rm ~ t, degree = 2, data=data.sales)
summary(m.mars2)
## No interaction effects as only one X in data


# Consolidate RMSE results in a data frame table
RMSE.results <- data.frame(Model = Model, RMSE = RMSE)


# trace = 3 to view the MARS growing and pruning sequence
earth(Sales.5rm ~ t, degree = 1, trace = 3, data=data.sales)


# Using 10-fold CV one vs five times to prune instead of GRsq ----------------
set.seed(2)
m.mars3 <- earth(Sales.5rm ~ t, degree = 1, pmethod = "cv", nfold = 10, ncross = 1, data=data.sales)

summary(m.mars3)

RMSE.mars3 <- round(sqrt((m.mars3$rss)/nrow(data.sales)))
## ncross = 1 is more unstable as RMSE is more variable under different seed.


