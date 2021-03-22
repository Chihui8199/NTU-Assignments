# ========================================================================================================
# Purpose:      Rscript for Data Cleaning demo
# Author:       Neumann Chew
# DOC:          10-09-2017
# Topics:       Data Cleaning; Data Preparation.
# Packages:     data.table
# Data Sources:  
#  1. Derived Sample from USA Census PUMS Data for Health Insurance Coverage. Already Used in wk 3.
#=========================================================================================================

#=========================================================================================================
#========================================================================================================
#
# Part 1: RQ1 - RQ4
#
#=========================================================================================================
#=========================================================================================================

library(data.table)
custdata.dt <- fread('D:/Dropbox/NTU Business School/Teaching/BC2406 AY20/3 Data Exploration and Statistics/health_ins_cust.csv')

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
#---------------------------------------------------------------------------------------------------------


# RQ2: -----------------------------------------------------------------
# Verify that the employment column was correctly created as intended.
#-----------------------------------------------------------------------

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
summary(subgroup1$income)
percentile <- ecdf(subgroup1$income)
percentile(8700)
## 0.26. $8700 would be the 26th percentile income among the unemployed, married, and age >50.
## More confident, though not 100% certain, that -$8700 can be replaced by $8700.


# RQ3: ---------------------------------------------------------------------------------------------------
# In the above code, we created a subgroup1 based on 3 criteria.
# Why didn't we use more criteria that would be closer to custid 971703 profile?
# e.g. to also include num.of.vehicles, state.of.res, housing.type,...
#---------------------------------------------------------------------------------------------------------


# RQ4: ------------------------------------------------------------------------------------------
# Instead of subjectively choosing the criterias for subgroup1, is there a more objective method?
#------------------------------------------------------------------------------------------------


# Replace wrong value with estimated value.
custdata.dt[income == -8700, income:= 8700]
summary(custdata.dt$income)
## Min income is no longer -8700



#=========================================================================================================
#========================================================================================================
#
# Part 2: RQ5 - RQ7
#
#=========================================================================================================
#=========================================================================================================


# Examine then clean Zero income ------------------------------------------

custdata.dt[income==0, .N]
## 78 cases of zero income. Employed?

# Question: How many of such cases are children vs retirees? Based on age bracket.
custdata.dt[income==0, .N, by = .(employment, age<18, age>65)]


# RQ5: ------------------------------------------------------------------------------------------
# Based on the results above, how would you clean the zero income?
# In terms of both the value to be replaced and the execution [overwrite?].
#------------------------------------------------------------------------------------------------


# RQ6: ---------------------------------------------------------------------------------------------------------
# Create an income bracket variable based on the cutoffs $0, 5000, 20000, 50000, 100000, 200000, 500000, 1000000
#---------------------------------------------------------------------------------------------------------------


# RQ7: -------------------------------------------------------------------------
# Clean the age variable. Explain your decision in your comments.
#-------------------------------------------------------------------------------

# End of Rscript =====================================================================