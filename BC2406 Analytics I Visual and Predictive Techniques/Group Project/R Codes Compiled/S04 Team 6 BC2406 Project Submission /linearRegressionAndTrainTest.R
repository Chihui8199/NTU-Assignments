library(data.table)
data1<- fread("final_data.csv")

#2. Data Cleaning
data1$Country <- factor(data1$Country)
data1$Gender <- factor(data1$Gender)
data1$Married <- factor(data1$Married)
data1$HasCrCard <- factor(data1$HasCrCard)
data1$Mortgage <- factor(data1$Mortgage)
data1$BusinessOwner <- factor(data1$BusinessOwner)
data1$LifeInsurance <- factor(data1$LifeInsurance)
data1$Churn <- factor(data1$Churn)


data1[ ,`:=`(RowNumber = NULL, Surname = NULL, CustomerID = NULL, Retention = NULL, CLV = NULL)]

View(data1)

#-----------------------------------------------------------------------------------------------------

library(caTools)
library(car)


techlm_all <- lm(ETFTech ~ . , data = data1)
summary(techlm_all)
vif(techlm_all)

#Dropping all GVIF > 10
techlm <- lm(ETFTech ~ . -CorpBonds -EmergingMarketFund -PrivateEquity -GovtBonds -NetAssets, data = data1)
summary(techlm)
vif(techlm) #check GVIF again

techlm_final <- lm(ETFTech ~ Age + Gold + PortfolioReturn, data = data1) #only take statistically significant variables
summary(techlm_final) 


scatterplot(data1$Age, data1$ETFTech, main='ETFTech against Age')
cor(data1$ETFTech, data1$Age)

scatterplot(data1$Gold, data1$ETFTech, main='ETFTech against Gold')
cor(data1$ETFTech, data1$Gold)

scatterplot(data1$PortfolioReturn, data1$ETFTech, main='ETFTech against PortfolioReturn')
cor(data1$ETFTech, data1$PortfolioReturn)

#-----------------------------------------------------------------------------------------------------

goldlm_all <- lm(Gold ~ ., data = data1)
summary(goldlm_all)
vif(goldlm_all)


#Dropping all GVIF > 10
goldlm <- lm(Gold ~ . -CorpBonds -PrivateEquity -GovtBonds -NetAssets, data = data1)
summary(goldlm)
vif(goldlm) #check GVIF again

goldlm_final <- lm(Gold ~ Married + Age + ETFTech, data = data1) #only take statistically significant variables
summary(goldlm_final) 

plot(jitter(as.numeric(data1$Married)), data1$Gold,  main='Gold against Married')

scatterplot(data1$Age, data1$Gold, main='Gold against Age')
cor(data1$Age, data1$Gold)SS

scatterplot(data1$ETFTech, data1$Gold, main='Gold against ETFTech')
cor(data1$ETFTech, data1$Gold)


#-----------------------------------------------------------------------------------------------------

corpbondlm_all <- lm(CorpBonds ~ ., data = data1)
summary(corpbondlm_all)
vif(corpbondlm_all)


#Dropping all GVIF > 10
corpbondlm <- lm(CorpBonds ~ . -PrivateEquity -GovtBonds -NetAssets, data = data1)
summary(corpbondlm)
vif(corpbondlm) #check GVIF again


corpbondlm_final <- lm(CorpBonds ~ Country + Gender + BusinessOwner, data = data1) 
summary(corpbondlm_final) #Spain, Male and being BusinessOwner are statistically significant

plot(data1$Country, data1$CorpBonds,  main='CorpBonds against Country')

plot(jitter(as.numeric(data1$Gender)), data1$CorpBonds, main='CorpBonds against Gender')

plot(jitter(as.numeric(data1$BusinessOwner)), data1$CorpBonds, main='CorpBonds against BusinessOwner')

#-----------------------------------------------------------------------------------------------------

emflm_all <- lm(EmergingMarketFund ~ ., data = data1)
summary(emflm_all)
vif(emflm_all)


#Dropping all GVIF > 10
emflm <- lm(EmergingMarketFund ~ . -PrivateEquity -GovtBonds -NetAssets, data = data1)
summary(emflm)
vif(emflm ) #check GVIF again


emflm_final <- lm(EmergingMarketFund ~ Gender, data = data1) 
summary(emflm_final)

#Female is the data points on the left 
plot(jitter(as.numeric(data1$Gender)), data1$EmergingMarketFund, main='EmergingMarketFund against Gender')



#-----------------------------------------------------------------------------------------------------


pelm_all <- lm(PrivateEquity ~ ., data = data1)
summary(pelm_all)
vif(pelm_all)


#Dropping other instruments causing perfect fit
pelm <- lm(PrivateEquity ~ . -ETFTech - Gold - CorpBonds - EmergingMarketFund - GovtBonds , data = data1)
summary(pelm)
vif(pelm ) #check GVIF again


pelm_final <- lm(PrivateEquity ~ Dependents + EstimatedSalary + NetAssets + BusinessOwner, data = data1) 
summary(pelm_final) #using top 4 statistically significant

plot(data1$Dependents, data1$PrivateEquity,  main='PrivateEquity against Dependents')

scatterplot(data1$EstimatedSalary, data1$PrivateEquity,  main='PrivateEquity against EstimatedSalary')

plot(data1$NetAssets, data1$PrivateEquity,  main='PrivateEquity against NetAssets')

plot(jitter(as.numeric(data1$BusinessOwner)), data1$PrivateEquity,  main='PrivateEquity against BusinessOwner')




#-----------------------------------------------------------------------------------------------------

govtbondlm_all <- lm(GovtBonds ~ ., data = data1)
summary(govtbondlm_all)
vif(govtbondlm_all)

#Dropping GVIF > 10
govtbondlm <- lm(GovtBonds ~ . -PrivateEquity, data = data1)
summary(govtbondlm)
vif(govtbondlm ) #check GVIF again


govtbondlm_final <- lm(GovtBonds ~ Dependents + NetAssets, data = data1) 
summary(govtbondlm_final) 

plot(data1$Dependents, data1$GovtBonds,  main='GovtBonds against Dependents')

scatterplot(data1$NetAssets, data1$GovtBonds,  main='GovtBonds against NetAssets')
cor(data1$NetAssets, data1$GovtBonds)




#-----------------------------------------------------------------------------------------------------

set.seed(2004)

# 70% trainset
train <- sample.split(Y = data1$ETFTech, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)


# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$ETFTech)
summary(testset$ETFTech)

# Develop model on trainset for ETFTech
etftech_model <- lm(ETFTech ~ Age + Gold + PortfolioReturn, data = trainset)
summary(etftech_model)
residuals(etftech_model)


RMSE.etftech_model.train <- sqrt(mean(residuals(etftech_model)^2))
summary(abs(residuals(etftech_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.etftech_model.test <- predict(etftech_model, newdata = testset)
etftech_model.testset.error <- testset$ETFTech - predict.etftech_model.test

# Testset Errors
RMSE.etftech_model.test <- sqrt(mean(etftech_model.testset.error^2))
summary(abs(etftech_model.testset.error))

RMSE.etftech_model.train 
RMSE.etftech_model.test 

#-----------------------------------------------------------------------------------------------------
# 70% trainset
train <- sample.split(Y = data1$Gold, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)

# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$Gold)
summary(testset$Gold)

# Develop model on trainset for Gold
gold_model <- lm(Gold ~ Married + Age + ETFTech, data = trainset)
summary(gold_model)
residuals(gold_model)


RMSE.gold_model.train <- sqrt(mean(residuals(gold_model)^2))  
summary(abs(residuals(gold_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.gold_model.test <- predict(gold_model, newdata = testset)
gold_model.testset.error <- testset$Gold - predict.gold_model.test

# Testset Errors
RMSE.gold_model.test <- sqrt(mean(gold_model.testset.error^2))
summary(abs(gold_model.testset.error))

RMSE.gold_model.train 
RMSE.gold_model.test 

#-----------------------------------------------------------------------------------------------------
# 70% trainset
train <- sample.split(Y = data1$CorpBonds, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)

# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$CorpBonds)
summary(testset$CorpBonds)

# Develop model on trainset for CorpBonds
corpbonds_model <- lm(CorpBonds ~ Country + Gender + BusinessOwner, data = trainset)
summary(corpbonds_model)
residuals(corpbonds_model)


RMSE.corpbonds_model.train <- sqrt(mean(residuals(corpbonds_model)^2))  
summary(abs(residuals(corpbonds_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.corpbonds_model.test <- predict(corpbonds_model, newdata = testset)
corpbonds_model.testset.error <- testset$CorpBonds - predict.corpbonds_model.test

# Testset Errors
RMSE.corpbonds_model.test <- sqrt(mean(corpbonds_model.testset.error^2))
summary(abs(corpbonds_model.testset.error))

RMSE.corpbonds_model.train 
RMSE.corpbonds_model.test 



#-----------------------------------------------------------------------------------------------------
# 70% trainset
train <- sample.split(Y = data1$EmergingMarketFund, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)

# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$EmergingMarketFund)
summary(testset$EmergingMarketFund)

# Develop model on trainset for EmergingMarketFund
emf_model <- lm(EmergingMarketFund ~ Gender, data = trainset)
summary(emf_model)
residuals(emf_model)


RMSE.emf_model.train <- sqrt(mean(residuals(emf_model)^2))  
summary(abs(residuals(emf_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.emf_model.test <- predict(emf_model, newdata = testset)
emf_model.testset.error <- testset$EmergingMarketFund - predict.emf_model.test

# Testset Errors
RMSE.emf_model.test <- sqrt(mean(emf_model.testset.error^2))
summary(abs(emf_model.testset.error))

RMSE.emf_model.train 
RMSE.emf_model.test 

#-----------------------------------------------------------------------------------------------------
# 70% trainset
train <- sample.split(Y = data1$PrivateEquity, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)

# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$PrivateEquity)
summary(testset$PrivateEquity)

# Develop model on trainset for PrivateEquity
pe_model <- lm(PrivateEquity ~ Dependents + EstimatedSalary + NetAssets + BusinessOwner, data = trainset)
summary(pe_model)
residuals(pe_model)


RMSE.pe_model.train <- sqrt(mean(residuals(pe_model)^2))  
summary(abs(residuals(pe_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.pe_model.test <- predict(pe_model, newdata = testset)
pe_model.testset.error <- testset$PrivateEquity- predict.pe_model.test

# Testset Errors
RMSE.pe_model.test <- sqrt(mean(pe_model.testset.error^2))
summary(abs(pe_model.testset.error))

RMSE.pe_model.train 
RMSE.pe_model.test 

#-----------------------------------------------------------------------------------------------------
# 70% trainset
train <- sample.split(Y = data1$GovtBonds, SplitRatio = 0.7)
trainset <- subset(data1, train == T)
testset <- subset(data1, train == F)
# Checking the distribution of Y is similar in trainset vs testset.
summary(trainset$GovtBonds)
summary(testset$GovtBonds)

# Develop model on trainset for GovtBonds
gb_model <- lm(GovtBonds ~ Dependents + NetAssets, data = trainset)
summary(gb_model)
residuals(gb_model)


RMSE.gb_model.train <- sqrt(mean(residuals(gb_model)^2))  
summary(abs(residuals(gb_model)))  # Check Min Abs Error and Max Abs Error.

# Apply model from trainset to predict on testset.
predict.gb_model.test <- predict(gb_model, newdata = testset)
gb_model.testset.error <- testset$GovtBonds - predict.gb_model.test

# Testset Errors
RMSE.gb_model.test <- sqrt(mean(gb_model.testset.error^2))
summary(abs(gb_model.testset.error))

RMSE.gb_model.train 
RMSE.gb_model.test 



#-----------------------------------------------------------------------------------------------------


#investigate Age on ETFTech, keeping all else constant
etftech.practical = data.frame(Age = c(25,50,70), Gold = c(2000,2000,2000), PortfolioReturn = c(0.1,0.1,0.1))
etftech.predicted = predict(techlm_final, newdata = etftech.practical)
data.frame(Age = c(25,50, 70),etftech.predicted)
data.frame(Age = c(50,70), 'Percentage difference vs Age 25' 
           = c(etftech.predicted[1]/etftech.predicted[2]-1, etftech.predicted[1]/etftech.predicted[3]-1))
#Age 25 invest 16% more in ETFTech than Age 50, 34% more than Age 70


#investigate Age on Gold, keeping all else constant
gold.practical = data.frame(Married = factor(c(1,1,1)), Age = c(25,50,70), ETFTech = c(2000,2000,2000))
gold.predicted = predict(goldlm_final, newdata = gold.practical)
data.frame(Age = c(25,50, 70),gold.predicted)
data.frame(Age = c(25,50), 'Percentage difference vs Age 70' 
           = c(gold.predicted[3]/gold.predicted[1]-1, gold.predicted[3]/gold.predicted[2]-1))
#Age 70 invest 67% more in Gold than Age 25, 21% more than Age 25



#investigate Gender on CorpBonds, keeping all else constant
corpbond.practical = data.frame(Country = factor(c("Spain","Spain")), Gender = factor(c("Female", "Male")), BusinessOwner = factor(c(0,0)))
corpbond.predicted = predict(corpbondlm_final, newdata = corpbond.practical)
data.frame(Gender = c("Female", "Male"),corpbond.predicted)
data.frame(Gender = "Male", 'Percentage difference vs Female' 
           = c(corpbond.predicted[1]/corpbond.predicted[2]-1))
#Female invest 80% more in CorpBonds than Male


#investigate Gender on EMF, keeping all else constant
emf.practical = data.frame( Gender = factor(c("Female", "Male")))
emf.predicted = predict(emflm_final, newdata = emf.practical)
data.frame(Gender = c("Female", "Male"),emf.predicted)
data.frame(Gender = "Female", 'Percentage difference vs Male' 
           = c(emf.predicted[2]/emf.predicted[1]-1))
#Male invest 94% more in EMF than Female



#investigate Dependents on PrivateEquity, keeping all else constant
pe.practical = data.frame(Dependents = c(1, 3, 5), EstimatedSalary 
                          = c(rep(100000, 3)), NetAssets = c(rep(130000, 3)), BusinessOwner = factor(rep(0,3)))
pe.predicted = predict(pelm_final, newdata = pe.practical)
data.frame(Dependents = c(1,3,5),pe.predicted)
data.frame(Dependents = c(1, 3), 'Percentage difference vs 5 Dependents' 
           = c(pe.predicted[3]/pe.predicted[1] - 1, pe.predicted[3]/pe.predicted[2] - 1))
#5 Dependents invest 36% more in PrivateEquity than 1 Dependent,  15% more than 3 Dependents 



#investigate Dependents on GovtBonds, keeping all else constant
gb.practical = data.frame(Dependents = c(1, 3, 5), NetAssets = c(rep(130000, 3)))
gb.predicted = predict(govtbondlm_final, newdata = gb.practical)
data.frame(Dependents = c(1,3,5),gb.predicted)
data.frame(Dependents = c(3, 5), 'Percentage difference vs 1 Dependent' 
           = c(gb.predicted[1]/gb.predicted[2] - 1, gb.predicted[1]/gb.predicted[3] - 1))
#1 Dependent invest 86% more in GovtBond than 3 Dependents,  1236% more than 5 Dependents 




