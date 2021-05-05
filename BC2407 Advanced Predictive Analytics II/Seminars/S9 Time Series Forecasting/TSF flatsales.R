# Purpose: Time Series Forecasting of 5 room resale flat sales
# Author: Chew C. H.
# Data Source: HDB

library("TTR")               # For MA via SMA() 
library("forecast")          # To generate h-period ahead forecasts

setwd("C:/NC/Datasets/ML")

flatsales.df <- read.csv("5 room flat resale applications.csv")

# create time series object
flatsales.ts <- ts(flatsales.df$Sales.5rm, frequency = 4, start = c(2007,1))

flatsales.ts

plot.ts(flatsales.ts, ylab = "Flats Sold", xlab = "Quarter-Year",
        main = "Sales of 5 Room Resale Flats",
        sub = "Source: HDB")
## Non-constant fluctuations. Multiplicative Time Series.


# Moving Average -------------------------------------------------------------
m.ma3 <- SMA(flatsales.ts, n = 3)
plot(m.ma3, main = "Moving Avg Span 3", ylab = "MA3 Forecast")

m.ma7 <- SMA(flatsales.ts, n = 7)
plot(m.ma7, main = "Moving Avg Span 7", ylab = "MA7 Forecast")

# Classical Seasonal Decomposition by Moving Averages
m.ma.mul <- decompose(flatsales.ts, type = "multiplicative")
plot(m.ma.mul)


# Simple Exponential Smoothing ---------------------------------------------
m.ses <- HoltWinters(flatsales.ts, seasonal = "multiplicative", beta=F, gamma=F)

m.ses
## Optimal value of alpha = 0.5288797

plot(m.ses, main = "Simple Exp Smoothing with optimized alpha = 0.5288797")

m.ses$fitted

m.ses$alpha*1519 + (1-m.ses$alpha)*1485.8267
## verifying the meaning of coef = 1503.371 is L_{last t}

RMSE.ses <- round(sqrt(m.ses$SSE/nrow(m.ses$fitted)))
## 359

# Holt's method  --------------------------------------------------------------
m.holt <- HoltWinters(flatsales.ts, seasonal = "multiplicative", gamma=F)

m.holt
## Optimal value of alpha = 1, beta = 0.2414013

plot(m.holt, main = "Holt Smoothing with optimized alpha = 1, beta = 0.2414013")

RMSE.holt <- round(sqrt(m.holt$SSE/nrow(m.holt$fitted)))


# Winter's method -------------------------------------------------------------
m.winters <- HoltWinters(flatsales.ts, seasonal = "multiplicative")

m.winters
## Optimal value of alpha = 0.8981024, beta = 0, gamma = 1.

plot(m.winters, main = "Winters Smoothing with optimized alpha = 0.8981024, beta = 0, gamma = 1.")

RMSE.winters <- round(sqrt(m.winters$SSE/nrow(m.winters$fitted)))
## Winters method has the lowest RMSE

# Forecast 4 periods ahead -------------------------------------
m.winters.forecasts <- forecast(m.winters, h = 4)

m.winters.forecasts

plot(m.winters.forecasts)


# Some Other useful functions ----------------------------------------
accuracy(m.winters.forecasts)

# Num of days in each season
monthdays(flatsales.ts)

