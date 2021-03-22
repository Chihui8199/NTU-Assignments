# ========================================================================================================
# Purpose:      Understanding Dummy Variables
# Author:       Chew C.H.
# DOC:          14 Sep 2020
# Topics:       Categorical X, Dummy Variables, Baseline.
# Packages:     data.table
# Data:         occupation.csv
#=========================================================================================================

setwd("C:/Users/neumann.chew/Dropbox/Schools/NBS/BC2406 Analytics 1/BC2406 Course Materials/Unit 6 - Linear Reg/Extra")

data1 <- data.table::fread("occupation.csv", stringsAsFactors = T)

summary(data1)

# We can choose to use either Occ or Occ Code as the X variable,
# Occ is more convenient as already factored with descriptive names.
# If you choose to use Occ Code, remember to factor as it is currently integer.

levels(data1$Occ)
## Shows that CEO is the default baseline ref as it is the first category.

# Set baseline reference level to be Manager.
data1$Occ <- relevel(data1$Occ, ref = "Manager")

levels(data1$Occ)
## Verfied Manager is now the baseline ref as it is the first category.

m1 <- lm(Salary ~ Occ, data = data1)
summary(m1)
## Observe results are the same as in Excel Solution but faster to obtain as dummy variables auto-created.

testcases <- data.frame(Occ = c("Clerk", "Manager", "Director", "CEO"))
Salary.hat <- predict(m1, newdata = testcases)
Results <- data.frame(testcases, Salary.hat)
## Estimated salaries are the same as in Excel Solution.

# ============ END ====================================================