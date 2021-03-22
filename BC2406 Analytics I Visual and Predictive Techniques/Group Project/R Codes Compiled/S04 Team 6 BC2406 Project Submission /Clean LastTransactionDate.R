library(data.table)
data1<- fread("final_data.csv")

data1$Gender <- factor(data1$Gender)
data1$Married <- factor(data1$Married)
data1$HasCrCard <- factor(data1$HasCrCard)
data1$Mortgage <- factor(data1$Mortgage)
data1$BusinessOwner <- factor(data1$BusinessOwner)
data1$LifeInsurance <- factor(data1$LifeInsurance)
data1$Churn <- factor(data1$Churn)
data1[ ,`:=`(RowNumber = NULL, Surname = NULL, CustomerID = NULL,Retention = NULL, CLV = NULL)]

library(lubridate)
library(anytime)  
install.packages("anytime")
data1$date2 <- anydate(data1$LastTransactionDate)
todaydate <- anydate("2019-06-01") # we can assume any cut off date but don't choose one too current or it may not yield good results
data1$NumDaysSinceLastTxn <- difftime(todaydate, data1$date2, units = "days")
View(data1)