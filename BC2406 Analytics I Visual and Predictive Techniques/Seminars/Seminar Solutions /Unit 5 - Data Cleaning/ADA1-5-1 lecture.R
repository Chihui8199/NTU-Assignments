# ========================================================================================================
# Purpose:      Rscript for Data Cleaning demo
# Author:       Neumann Chew
# DOC:          10-09-2017
# Topics:       Data Cleaning; Data Preparation.
# Packages:     data.table
# Data Sources:  
#  1. Example dataset "children.csv"
#=========================================================================================================


library(data.table)
setwd("D:/Dropbox/NTU Business School/Teaching/BC2406 AY20/5 Data Cleaning and Preparation")

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


# End of Rscript =====================================================================