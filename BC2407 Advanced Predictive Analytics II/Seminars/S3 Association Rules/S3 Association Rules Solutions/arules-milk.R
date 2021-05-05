# Purpose: Demo of arules Rpackage
# Author: Chew C. H.
# Dataset: milk.csv
# How to conversion to transactions datatype: https://rdrr.io/cran/arules/man/transactions-class.html



library(arules)

setwd("D:/Dropbox/Schools/NBS/BC2407 Analytics 2/S3 Association Rules")
widedata <- read.csv("milk.csv")

# Convert from data frame to transactions datatype for arules Rpackage -------------------------
widedata[] <- lapply(widedata, factor) # all columns to factor datatype instead of integer
summary(widedata)  # Check factor in each column.
widedata2 <- widedata[,2:5] # Remove ID column as each row is considered one transaction.

trans1 <- as(widedata2, "transactions")  # Convert to transactions datatype
inspect(trans1)
rules1 <- apriori(data = trans1, parameter = 
                       list(minlen = 2, supp=0.4, conf = 0.3, target = "rules"))
summary(rules1)  # 24 rules satisfy min supp = 0.4, min conf = 0.3. Why so many?
inspect(head(rules1, n = 3, by ="lift"))  # Top 3 rules by Lift.
rule.table1 <- inspect(sort(rules1, by ="lift")) # Export as a rule table
## Using data frame with factor columns, absent items also counted as an item and part of rules.
## Good to use if absence of a factor is considered as an item too e.g. No fever.
# ----------------------------------------------------------------------------------------------


# Convert from long format to transactions datatype --------------------------------------------
source("meltmilk.R")
trans2 <- read.transactions(file="longdatamilk.csv", format="single", sep =",",
                            header=T, cols = c("ID", "variable"))
inspect(trans2)
rules2 <- apriori(data = trans2, parameter = 
                    list(minlen = 2, supp=0.4, conf = 0.3, target = "rules"))
summary(rules2)  # 2 rules satisfy min supp = 0.4, min conf = 0.3.
inspect(head(rules2, n = 2, by ="lift"))  # Top 2 rules by Lift.
rule.table2 <-inspect(sort(rules2, by ="confidence"))  # Export Rule Table 2
## Reduce min Supp to get more rules
#----------------------------------------------------------------------------------
