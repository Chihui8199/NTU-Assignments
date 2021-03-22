# ========================================================================================================
# Purpose:      Rscript for Data Cleaning demo
# Author:       Neumann Chew
# DOC:          10-09-2017
# Topics:       Data Cleaning; Data Preparation.
# Packages:     data.table
# Data Sources:  
#  1. Example dataset "children.csv"
#  2. Derived Sample from USA Census PUMS Data for Health Insurance Coverage. Already used in wk 3.
#=========================================================================================================

library(data.table)
setwd("~/Desktop/Y2S1/BC2406/Unit 5 - Data Cleaning")
children.dt <- fread('children.csv')
children.dt
sum(is.na(children.dt))    ## only 1 NA in dataset
which(is.na(children.dt))  ## That one NA is in row 6 [i.e. value coded: NA]
## Source data has 9 different codes for missing value but only one code is auto-recognized by R.


# Use na.strings to define all human codes for missing values to be NA.
children2.dt <- fread('children.csv', na.strings = c("NA", "missing", "N/A", -99, "", "m", "M", "na", "."))
children2.dt  ## All the 9 ways to code missing value are now recoded as NA.
sum(is.na(children2.dt))    ## 9 NAs in dataset
#which(is.na(children2.dt))  
which(is.na(children2.dt$children))  # where are the NAs in children column.
which(is.na(children2.dt$Room))      # where are the NAs in Room column.



#----------------------------------------------------------------------------------------------

custdata.dt <- fread('health_ins_cust.csv')

# Get summary statistics of all columns in dataset.
# Quick way to see range, categories and missing values.
summary(custdata.dt)


# Value = Missing may be self-employed, students, retirees, not in active workforce,...
# Create a new column employment. Temporary recode NA as missing in employment column.
custdata.dt[is.na(is.employed), employment:='missing']
custdata.dt[is.employed == T, employment:='employed']
custdata.dt[is.employed == F, employment:='unemployed']
custdata.dt$employment <- factor(custdata.dt$employment, levels = c('unemployed', 'employed', 'missing'))
# summary check on new column
summary(custdata.dt$employment)


# RQ1: ---------------------------------------------------------------------------------------------------
# In the above code, we created a new column "employment" to hold the recoded missing values.
# Why can't we overwrite NA to 'missing' in the is.employed column so that we don't need to create column?
# Ans:
# is.employed column is a logical variable and cannot hold a text value. Only T/F/NA.
#---------------------------------------------------------------------------------------------------------


# RQ2: -----------------------------------------------------------------
# Verify that the employment column was correctly created as intended.

# Ans:
# df way using table():
table(custdata.dt$employment, custdata.dt$is.employed, useNA = 'ifany', deparse.level = 2)

# Better alternative using dt way:
custdata.dt[, .N, by = .(is.employed, employment)]
#-----------------------------------------------------------------------

#The par(mfrow) function is handy for creating a simple multi-paneled plot, while layout should be used for customized panel plots of varying sizes. 
#par(mfrow) mfrow – A vector of length 2, where the first argument specifies the number of rows and the second the number of columns of plots.
par(mfrow = c(2,2))
boxplot(age ~ is.employed, data = custdata.dt, xlab = "is.employed", ylab = "Age")
boxplot(income ~ is.employed, data = custdata.dt, xlab = "is.employed", ylab = "Income")
boxplot(age ~ employment, data = custdata.dt, xlab = "Employment", ylab = "Age")
boxplot(income ~ employment, data = custdata.dt, xlab = "Employment", ylab = "Income")
par(mfrow = c(1,1))



# Examine then clean negative income --------------------------------------------------------------
custdata.dt[income < 0, .N]
## Only 1 case of negative income.

custdata.dt[income < 0]
## custid = 971703, unemployed, aged 60, with Health Insurance, married, have 3 cars, income = -$8700.

# Would positive $8700 be a more accurate value than negative $8700? i.e. a typo error.
# Check actual paper records and if not avail, to find more statistical evidence.

# Examine the distribution of income among the unemployed and find the rank of $8700 income
subgroup1 <- custdata.dt[is.employed==F & marital.stat == 'Married' & age > 50]
subgroup1 <- custdata.dt[is.employed==F & marital.stat == 'Married' & age > 50,.N] # 19 cases
summary(subgroup1$income)
#?ecdf(), basically finds empirical(meaning prob from actual dataset) cdf. the other cdf function we use is base on maths theory
percentile <- ecdf(subgroup1$income)
percentile(8700)
## 0.26. $8700 would be the 26th percentile income among the unemployed, married, and age >50.
## More confident, though not 100% certain, that -$8700 can be replaced by $8700.


# RQ3: ---------------------------------------------------------------------------------------------------
# In the above code, we created a subgroup1 based on 3 criteria.
# Why didn't we use more criteria that would be closer to custid 971703 profile?
# e.g. to also include num.of.vehicles, state.of.res, housing.type,...
# Ans:
# There would be insufficient sample size for a realistic estimate of percentile.
#---------------------------------------------------------------------------------------------------------



# RQ4: ------------------------------------------------------------------------------------------
# Instead of subjectively choosing the criterias for subgroup1, is there a more objective method?
# Ans:
# Yes, one way is to use linear regression model to identify significant factors on income.
#------------------------------------------------------------------------------------------------


custdata.dt[income == -8700, income:= 8700]
summary(custdata.dt$income)
## Min income is no longer -8700

# Check the custid of those with income $8700.
custdata.dt[income == 8700, custid]
## Verified that changes are done correctly to CustID: 971703


# Examine then clean Zero income ------------------------------------------

custdata.dt[income==0, .N]
## 78 cases of zero income. Employed?

# Question: How many of such cases are children vs retirees? Based on age bracket.
custdata.dt[income==0, .N, by = .(employment, age<18, age>65)]

# RQ5: ------------------------------------------------------------------------------------------
# Based on the results above, how would you clean the zero income?
# In terms of both the value to be replaced and the execution [overwrite?].
# Ans:
# Tentative Decision: If unemployed, accept income = 0. If missing, set income = NA.
# Execution: Create a new column income.fix to hold the changes.

# Ans: Tentatively recode to NA in income if employment = missing and income = 0. Create a new column.
custdata.dt[, income.fix := income]  # create a copy of income column.
custdata.dt[income == 0 & employment == 'missing', income.fix := NA]
# Verify
custdata.dt[is.na(income.fix), .N, by = .(employment, income)]
#-------------------------------------------------------------------------------------


# If NAs in Income is Missing Randomly, replace with Mean Income
# custdata.dt[is.na(income.fix), income.fix := mean(income.fix, na.rm=T)]


# RQ6: ---------------------------------------------------------------------------------------------------------
# Create an income bracket variable based on the cutoffs 0, 5000, 20000, 50000, 100000, 200000, 500000, 1000000
# Ans:
# Discretize Income
# Ensure that income brackets will capture the min and max income value
summary(custdata.dt$income.fix)
cut.off <- c(0, 5000, 20000, 50000, 100000, 200000, 500000, 1000000)
custdata.dt[, income.bracket := cut(income.fix, breaks=cut.off, include.lowest=T)]
summary(custdata.dt$income.bracket)
## Overide the default option of include.lowest from F to T to ensure that the lowest income value of $0 is captured in the first income bracket [0, 5000].
## Otherwise, by default, the left open, right closed bracket structure will miss the zero income category.
#---------------------------------------------------------------------------------------------------------------


# RQ7: -------------------------------------------------------------------------
# Clean the age variable. Explain your decision in your comments.



#Ans:
summary(custdata.dt$age)

# How many cases are very young or very old?
custdata.dt[, .N, by = .(age < 16, nchar(age) > 2)]
## 8 cases of more than 2 characters in age, 3 cases of less than 16 years old.

# If age has more than 2 characters, code as NA. There are 8 cases.
custdata.dt[, age.fix := age]
custdata.dt[nchar(age.fix) > 2, age.fix := NA]
# verify
#custdata.dt[is.na(age.fix), .N, by = .(nchar(age) > 2)]
#-------------------------------------------------------------------------------


# End of Rscript =====================================================================