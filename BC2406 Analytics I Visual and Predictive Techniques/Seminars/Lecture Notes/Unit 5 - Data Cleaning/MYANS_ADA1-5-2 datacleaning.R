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
setwd("~/Desktop/Y2S1/BC2406/Unit 5 - Data Cleaning")
custdata.dt <- fread("health_ins_cust.csv")
?is.na()
# Get summary statistics of all columns in dataset.
# Quick way to see range, categories and missing values.
summary(custdata.dt)
# Value = Missing may be self-employed, students, retirees, not in active workforce,...
# Create a new column employment. Temporary recode NA as missing in employment column.
custdata.dt[is.na(is.employed), employment:='missing']
#if employed is missing, generate employment and assign Text missing
custdata.dt[is.employed == T, employment:='employed']
#if employed is missing, generate employment and assign employed
custdata.dt[is.employed == F, employment:='unemployed']
#if employed is missing, generate employment and assign Text unemployed

class(custdata.dt$employment)
custdata.dt$employment <- factor(custdata.dt$employment, levels = c('unemployed', 'employed', 'missing'))
#there are 3 values
custdata.dt.isemployed<-custdata.dt[is.na(is.employed)]
custdata.dt.employed<-custdata.dt[employment=="missing"]
identical(custdata.dt.isemployed,custdata.dt.employed)

custdata.dt$employment.mode()
# summary check on new column
summary(custdata.dt$employment)


# RQ1: ---------------------------------------------------------------------------------------------------
# In the above code, we created a new column "employment" to hold the recoded missing values.
# Why can't we overwrite NA to 'missing' in the is.employed column so that we don't need to create column?
# IS employed is a logical column that contains true and false. 
# Safety Practice: The NA values could be overwritten and cleaned incorrectly which leads to wrongly recorded data
class(custdata.dt$is.employed)
# IS employed is a logical column that contains true and false cannot hold a text value



#cannot assign text missing into the original column. 
# RQ2: -----------------------------------------------------------------
# Verify that the employment column was correctly created as intended.
#-----------------------------------------------------------------------
#Note: is there's a NA the model will not take into account the entire row.
#Maybe able to use CART model to clean the NAs.
table(custdata.dt$employment, custdata.dt$is.employed, useNA = 'ifany',depends)


# R will take "missing" as categorical  variable which will be represented in the boxplot but if NA is used R will ignore \
?par()
#one represents the number of rows and the second represents the number of plots
#par(mfrow)-number of rows and number of columns
library(datasets)
#options(device='windows') <- This doesn't work for me :(
options(device = "RStudioGD")
# 2 row 2 columns 4 charts in one diagram
par(mfrow = c(2,2)) 
# Resetting margin for plotting
par(mar=c(4,3,3,4))
boxplot(age ~ is.employed, data = custdata.dt, xlab = "is.employed", ylab = "Age")
boxplot(income ~ is.employed, data = custdata.dt, xlab = "is.employed", ylab = "Income")
boxplot(age ~ employment, data = custdata.dt, xlab = "Employment", ylab = "Age")
boxplot(income ~ employment, data = custdata.dt, xlab = "Employment", ylab = "Income")
par(mfrow = c(1,1))



# Examine then clean negative income --------------------------------------------------------------
# Assumption: Income is never negative. In the real world, you will need to check the datadictionary. 
#For e.g can have two columns wages and income. Income is b4 tax thus perhaps can be -ve
custdata.dt[income < 0, .N]
## Only 1 case of negative income.

custdata.dt[income < 0]
## custid = 971703, unemployed, aged 60, with Health Insurance, married, have 3 cars, income = -$8700.

# Would positive $8700 be a more accurate value than negative $8700? i.e. a typo error.
# Check actual paper records and if not avail, to find more statistical evidence.
#?ecdf(), basically finds empirical(meaning prob from actual dataset) cdf. the other cdf function we use is base on maths theory
# Examine the distribution of income among the unemployed and find the rank of $8700 income
subgroup1 <- custdata.dt[is.employed==F & marital.stat == 'Married' & age > 50]
summary(subgroup1$income)
percentile <- ecdf(subgroup1$income)
plot(percentile)
percentile(8700)
## 0.26. $8700 would be the 26th percentile income among the unemployed, married, and age >50.
## More confident, though not 100% certain, that -$8700 can be replaced by $8700.


# RQ3: ---------------------------------------------------------------------------------------------------
# In the above code, we created a subgroup1 based on 3 criteria.
# Why didn't we use more criteria that would be closer to custid 971703 profile?
# e.g. to also include num.of.vehicles, state.of.res, housing.type,...
#want to know how likely income of $8700 falls under married female employees above 50. This has more relevance to income as compared to housing type etc.
# There would be insufficient sample size for a rea;istic estimate of percentilee
#This is entirely subjective, as to how we choose the factors to analyze 




# RQ4: ------------------------------------------------------------------------------------------
# Instead of subjectively choosing the criterias for subgroup1, is there a more objective method?
#1.use linear regression model, model income by using other available information. 
#After getting linear regression result, identify which variable is significantly related to income. choose the 3 criteria to generate the subgroup. 
#Calculate correlation using the cor() function/ R square where R square is just the square of the correlation
#2. Use clustering,e.g K means clustering

# Replace wrong value with estimated value.
# := special assignment symbol
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
#To make dataviewing clearer
zeroincome = custdata.dt[income==0, .N, by = .(employment, age<18, age>65)]
setnames(zeroincome, "age", "age<18")
setnames(zeroincome, "age.1", "age>65")
zeroincome

# RQ5: ------------------------------------------------------------------------------------------
# Based on the results above, how would you clean the zero income?
# In terms of both the value to be replaced and the execution [overwrite?].
#------------------------------------------------------------------------------------------------
# 1. Create a new column called income_fix,by duplicating the column in the original data table
#we learn not to overwrite data in the earlier part of this exercise
custdata.dt[,income_fix:=income]
# Replace the missing values of income with NA
custdata.dt[income == 0 & employment=="missing", income_fix:=NA]
#To check if you have correctly  replaces those with income = 0 and employment as missing to 0
custdata.dt[income_fix==0, .N, by = .(employment, age<18, age>65)]
#Replace those values that is labelled as NA with mean value of income
# mean might not be a good. Might have v big outliers like millionares 
meanincome <-mean(custdata.dt[,as.numeric(income),])
custdata.dt[(is.na(income_fix) == TRUE), income_fix:= meanincome]
custdata.dt[]


# RQ6: ---------------------------------------------------------------------------------------------------------
# Create an income bracket variable based on the cutoffs $0, 5000, 20000, 50000, 100000, 200000, 500000, 1000000
#---------------------------------------------------------------------------------------------------------------
#Method 1: To use the Cut function
custdata.dt$income <- factor(custdata.dt$income, levels = c(0,5000,20000,50000,100000,200000,500000,1000000))
#generate a discretize - use the function cut
?cut
cut.off<-c(0,5000,20000,50000,100000,200000,500000,1000000)
as.numeric(custdata.dt$income.fix)
#include lowest is T [0,5000]. Overide default is F
custdata.dt[,income.bracket1:=cut(income.fix,breaks=cut.off,include.lowest = T)]
custdata.dt[,income.bracket2:=cut(income.fix,breaks=cut.off,include.lowest = F)]
summary(custdata.dt$income.bracket2)
summary(custdata.dt$income.bracket1)
summary(custdata.dt$income.fix)

# Method 2: Use if-else statements


# RQ7: -------------------------------------------------------------------------
# Clean the age variable. Explain your decision in your comments.
#-------------------------------------------------------------------------------

summary(custdata.dt$age)
#How many cases are very young or very old
## 8 cases of above 99 yrs old, 3 cases of less than 10 yrs old 
custdata.dt[age > 100, .N]
custdata.dt[age > 100]


#how to come up with a dataset that is suitable for cleaning??
# End of Rscript =====================================================================