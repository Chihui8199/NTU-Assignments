# ========================================================================================================
# Purpose:      CART model for passexam data
# Author:       Neumann Chew
# DOC:          30-09-2020
# Topics:       CART, cp.
# Data Source:  passexam.csv, passexam2.csv
# Packages:     data.table, rpart, rpart.plot  
#=========================================================================================================

library(data.table)
library(rpart)
library(rpart.plot)   

setwd('C:/Users/neumann.chew/Dropbox/Datasets/AAD1/7_Logistic_Reg')

passexam.dt <- fread("passexam.csv")
passexam.dt$Outcome <- factor(passexam.dt$Outcome)

summary(passexam.dt)

# Plot to see the cut-offs for failure and passing
plot(y=passexam.dt$Outcome, x=passexam.dt$Hours, pch = 19, col = "blue",
     main = "All students who study less than 1.625 hrs fail;
     All students who study more than 3.75 hrs pass.")
abline(v = 1.625, lty = 2, col = "red")
abline(v = 3.75, lty = 2, col = "green")
## Can CART detect the two cutoffs?

pass.cart1 <- rpart(Outcome ~ Hours, data = passexam.dt, method = 'class',
                    control = rpart.control(minsplit = 2, cp = 0))

printcp(pass.cart1)

#Display the pruning sequence and 10-fold CV errors, as a chart.
plotcp(pass.cart1, main = "Subtrees in passexam.csv")

cp1 <- 0.14

rpart.plot(pass.cart1, nn= T, main = "Maximal Tree for passexam.csv")
print(pass.cart1)
## Maximal Tree reveals that both cutoffs had been detected in the first and 2nd splits.

# To view reconciled rules
rpart.rules(pass.cart1, nn = T, extra = 4, cover = T)


# CART on perfectly separated data (where logistic reg fails) ------------------
passexam2.dt <- fread("passexam2.csv")
passexam2.dt$Outcome <- factor(passexam2.dt$Outcome)

# Plot to see the cut-offs for failure and passing
plot(y=passexam2.dt$Outcome, x=passexam2.dt$Hours, pch = 19, col = "blue",
     main = "All students who study less than 2.875 hrs fail;
     All students who study more than 2.875 hrs hrs pass.")
abline(v = 2.875, lty = 2, col = "red")
## Can CART detect the cut-off?

pass.cart2 <- rpart(Outcome ~ Hours, data = passexam2.dt, method = 'class',
                    control = rpart.control(minsplit = 2, cp = 0))

printcp(pass.cart2)

rpart.plot(pass.cart2, nn= T, main = "Maximal Tree for passexam2.csv")

print(pass.cart2)
## CART succeeds!

rpart.rules(pass.cart2, nn = T, extra = 4, cover = T)

#========= END =================================================================