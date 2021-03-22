setwd("~/Desktop/Y2S1/BC2406/Unit 6 - Linear Reg")
Prepaid <-read.csv("StarbucksPrepaid.csv")


#Q1
x <- lm(Amount~., data = Prepaid)
summary(x)
#The prepaid card varai


#Q2
y <- lm(Days~Age + Income + Cups, data = Prepaid)
summary(y)
#Most promising is the number of cups of coffee

#RQ3 ownwards use this dataset
Growth <- read.csv("StarbucksGrowth.csv")
z <-lm(Revenue ~.-Year,data = Growth) # Fit all other variable except Year
summary(z)
#Key Predictor is Ave weekly earnings. Due to strange negative coefficient in startbuck drinks
vif(z)

#multicollinear x variables -> High VIF
#multicollinear effect doesnt affect the precision/accuracy. However it will affect how you interpret the data
#Rj in VIF is calculated by plotting X1 against all other Xs in the regression eqn