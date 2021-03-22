library(data.table)
data1<- fread("final_data.csv")

data1$Gender <- factor(data1$Gender)
data1$Married <- factor(data1$Married)
data1$HasCrCard <- factor(data1$HasCrCard)
data1$Mortgage <- factor(data1$Mortgage)
data1$BusinessOwner <- factor(data1$BusinessOwner)
data1$LifeInsurance <- factor(data1$LifeInsurance)
data1$Churn <- factor(data1$Churn)


data1[ ,`:=`(RowNumber = NULL, Surname = NULL, CustomerID = NULL,Retention = NULL, CLV = NULL, ETF_Med = NULL)]

library(anytime)
data1$date2 <- anydate(data1$LastTransactionDate)
todaydate <- anydate("2019-06-01") # we can assume any cut off date but don't choose one too current or it may not yield good results
data1$NumDaysSinceLastTxn <- difftime(todaydate, data1$date2, units = "days")
data1[ ,`:=`(LastTransactionDate = NULL, date2 = NULL)]
View(data1)

library(rpart)
library(rpart.plot)
set.seed(1)
cart1 <- rpart(Churn ~ ., data = data1, method = 'class', control = rpart.control(minsplit = 2, cp = 0))
printcp(cart1)
rpart.plot(cart1, nn= T, main = "MaxTree")
CVerror.cap <- cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xerror"] + cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xstd"]
i <- 1; j<- 4
while (cart1$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}
cp1 = ifelse(i > 1, sqrt(cart1$cptable[i,1] * cart1$cptable[i-1,1]), 1)
cart2 <- prune(cart1, cp = cp1)
printcp(cart2, digits = 3)
rpart.plot(cart2, nn= T, main = "FinalTree")

print(cart2)

cart2$variable.importance

summary(cart2)

