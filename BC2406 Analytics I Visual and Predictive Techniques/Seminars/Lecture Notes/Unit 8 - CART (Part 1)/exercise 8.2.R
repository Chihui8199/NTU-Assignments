setwd("~/Desktop/Y2S1/BC2406/Unit 8 - CART (Part 1)")
library(data.table)
library(rpart)
library(rpart.plot) 
data1 <- fread("passexam.csv")
View(data1)                                                                                     
summary(data)

m2 <- rpart(Outcome ~ Hours, data = data1, method = 'class', control = rpart.control(minsplit = 2, cp = 0))
summary(m2)
print(m2)

#Look at node 4 and node 6, * = terminal node
#rpart.rules only for terminal nodes
rpart.rules(m2, nn = T, extra = 4, cover = T)


rpart.plot(m2, nn= T, main = "Maximal Tree in passexam.csv")

