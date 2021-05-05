# ========================================================================================================
# Purpose:      Multivariate Adaptive Regression Splines (MARS) demo.
# Author:       Neumann Chew
# DOC:          17-02-2020
# Topics:       MARS, Hinge Function, Effect of categorical X variable.
# Data:         resale-flat-prices-2019.csv from Housing & Dev Board.
#=========================================================================================================

library(earth)   # MARS

setwd("C:/Users/neumann.chew/Dropbox/Schools/NBS/BC2407 Analytics 2/S6 MARS")

data1 <- read.csv("resale-flat-prices-2019.csv")

summary(data1)

# Compute remaining_lease_years and remove two columns ------------------------
data1$remaining_lease_years = 99 - (2019 - data1$lease_commence_date)
data1$lease_commence_date <- NULL
data1$remaining_lease <- NULL


# Change the Baseline Reference level for Town to Yishun instead of default.
data1$town <- relevel(data1$town, ref = "YISHUN")
levels(data1$town)   # Verifies "YISHUN" is now first factor i.e. baseline ref.


# MARS on the 4 main variables degree 1 ----------------------------------------------
m.mars1 <- earth(resale_price ~ 
                  floor_area_sqm + 
                  remaining_lease_years + 
                  town + 
                  storey_range , degree=1, data=data1)

summary(m.mars1)

m.mars1.yhat <- predict(m.mars1)

RMSE.mars1 <- round(sqrt(mean((data1$resale_price - m.mars1.yhat)^2)))


m.mars2 <- earth(resale_price ~ 
                  floor_area_sqm + 
                  remaining_lease_years + 
                  town + 
                  storey_range , degree=2, data=data1)

summary(m.mars2)

m.mars2.yhat <- predict(m.mars2)

RMSE.mars2 <- round(sqrt(mean((data1$resale_price - m.mars2.yhat)^2)))

# MARS Prediction for Flat in Clementi, 100 sq metres, 19-21 storey, 80 yrs lease remaining --
testcase <- data.frame(town = "CLEMENTI",
                       floor_area_sqm = 100,
                       storey_range = "19 TO 21",
                       remaining_lease_years = 80)

m.mars1.yhat.test <-  predict(m.mars1, newdata = testcase)

m.mars2.yhat.test <-  predict(m.mars2, newdata = testcase)


# Estimated Variable Importance in degree 2 MARS
varimpt <- evimp(m.mars2)
print(varimpt)
## Floor Area is relatively most impt, followed by remaining lease.

