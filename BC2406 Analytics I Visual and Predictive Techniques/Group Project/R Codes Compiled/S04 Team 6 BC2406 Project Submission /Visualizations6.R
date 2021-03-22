library(ggplot2)
library(dplyr)
library(tidyr)

#running color library for use below
library(RColorBrewer)

#Step 1. Analyzing Existing Customer Segment

#Data Preparation - Data Cleaning
library(data.table)
data1<- fread("final_data.csv")

# Get summary statistics of all columns in dataset.
# Quick way to see range, categories and missing values.
summary(data1)
View(data1)

#How many rows and columns in the dataset?
dim(data1)
## 199 rows of data (excl. header) and 37 columns.

#-----------------------------------------------------------------------------------------------------

#Factor all categorical variable
data1$Gender <- factor(data1$Gender)
data1$Married <- factor(data1$Married)
data1$HasCrCard <- factor(data1$HasCrCard)
data1$Mortgage <- factor(data1$Mortgage)
data1$BusinessOwner <- factor(data1$BusinessOwner)
data1$LifeInsurance <- factor(data1$LifeInsurance)
data1$Churn <- factor(data1$Churn)

#-----------------------------------------------------------------------------------------------------

#To drop columns which are insignificant
data1[ ,`:=`(RowNumber = NULL, Surname = NULL, CustomerID = NULL, Retention = NULL, CLV = NULL)]

#View to check that columns stated have been dropped
dim(data1)
View(data1)
## 199 rows of data (excl. header) and 28 columns.

#Exploratory Analysis - To observe the trend between various variables
#-----------------------------------------------------------------------------------------------------
#Distribution of Credit Score
CreditScore <- ggplot(data1, aes(CreditScore)) + 
  geom_density(color = 'black', fill="gray") + 
                       geom_vline(aes(xintercept=mean(CreditScore)),
                          color="blue", linetype="dashed", size=1) +
                labs(title = "Credit Score Distribution") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of number of Bank Accounts
Bankacchist <- ggplot(data = data1, aes(x = factor(NumBankAccts), 
                        y = prop.table(stat(count)), 
                        fill = factor(NumBankAccts), 
                        label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 5) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Number of Bank Accounts', y = 'pct',
       title = "Percentage of Bank Accounts per customer") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of those with Credit Cards
cc <- ggplot(data = data1, aes(x = factor(HasCrCard), 
                     y = prop.table(stat(count)), 
                      fill = factor(HasCrCard), 
                      label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE)  + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 5) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Credit Card Status', y = 'pct', 
       title = "Percentage of customers having credit card") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Combining the charts of creditscore, numbankaccounts, creditcards
gridExtra::grid.arrange(CreditScore,Bankacchist,cc, ncol = 3,  nrow = 1)

#-----------------------------------------------------------------------------------------------------
#Distribution of Countries
country <- ggplot(data = data1, aes(x = factor(Country), 
                               y = prop.table(stat(count)), 
                               fill = factor(Country), 
                               label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE)  + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 3.5) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Country', y = 'pct', 
       title = "Percentage of customers from all countries") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of Gender
genderbar <- ggplot(data = data1, aes(x = factor(Gender), 
                                    y = prop.table(stat(count)), 
                                    fill = factor(Gender), 
                                    label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE)  + 
  geom_text(stat = 'count',
            position = position_dodge(.8), 
            vjust = -0.5, 
            size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Gender', y = 'pct', 
       title = "Percentage of customers from all genders") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of Married or not
marriedbar <- ggplot(data = data1, aes(x = factor(Married), 
                                      y = prop.table(stat(count)), 
                                      fill = factor(Married), 
                                      label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE)  + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Married', y = 'pct', 
       title = "Percentage of Married") +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of Dependents
Dep<- ggplot(data = data1, aes(x = factor(Dependents), 
                               y = prop.table(stat(count)), 
                               fill = factor(Dependents), 
                               label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Number of Dependents', y = 'pct',
       title = "Percentage of Dependents", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Creating a new dt with pe, age only
sdt = data1[, c("Age", "PrivateEquity")]
sdt

#Creating new column containing age group
sdt[, agegroup := ifelse(Age <= 30,'30 and below',
                         ifelse(Age <= 40, '40 and below',
                                ifelse(Age <= 50, '50 and below',
                                       ifelse(Age <= 60, '60 and below',
                                              '61 and above'
                                       )
                                )               
                         )
)
]

#Distribution of Age
Age<- ggplot(data = sdt, aes(x = factor(agegroup), 
                               y = prop.table(stat(count)), 
                               fill = factor(agegroup), 
                               label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.9), 
            vjust = -0.5, 
            size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Age', y = 'pct',
       title = "Distribution of Age(%)", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 7),
        axis.text.y = element_text(size = 10)) 

#Combining the charts of Age, country, Gender, married status, no of dependents
gridExtra::grid.arrange(Age, country, genderbar, marriedbar, Dep, ncol = 3,  nrow = 2)

#-----------------------------------------------------------------------------------------------------
#Distribution of those with Estimated Salaries
estsalary <- ggplot(data1, aes(EstimatedSalary)) + 
  geom_density(color = 'black', fill="gray") + 
  geom_vline(aes(xintercept=mean(EstimatedSalary)),
                                          color="blue", linetype="dashed", size=1)                                                      
#Distribution of those with Mortgage
Mortgage<- ggplot(data = data1, aes(x = factor(Mortgage), 
                               y = prop.table(stat(count)), 
                               fill = factor(Mortgage), 
                               label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(1), 
            vjust = 3, 
            size = 4) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Has Mortgage or not', y = 'pct',
       title = "Percentage of Mortgage", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of those with Debt
debt <- ggplot(data1, aes(Debt)) + 
  geom_density(color = 'black', fill="gray")+
  geom_vline(aes(xintercept=mean(Debt)),
  color="blue", linetype="dashed", size=1)

#Distribution of those with NetAssets
netasset<- ggplot(data1, aes(NetAssets)) + 
  geom_density(color = 'black', fill="gray")+
  geom_vline(aes(xintercept=mean(NetAssets)),
  color="blue", linetype="dashed", size=1)

#Distribution of Business Owner
ownbiz<- ggplot(data = data1, aes(x = factor(BusinessOwner), 
                                    y = prop.table(stat(count)), 
                                    fill = factor(BusinessOwner), 
                                    label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.7), 
            vjust = 3, 
            size = 4) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = "Owns Business owner or not", y = 'pct',
       title = "Percentage of Business owners", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of Life Insurance
LifeInsurance<- ggplot(data = data1, aes(x = factor(LifeInsurance), 
                                  y = prop.table(stat(count)), 
                                  fill = factor(LifeInsurance), 
                                  label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.7), 
            vjust = 3, 
            size = 4) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Has Life Insurance or not', y = 'pct',
       title = "Percentage who has life insurance", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Distribution of those with foreign asset
foreignasset<- ggplot(data1, aes(ForeignAssets)) + 
  geom_density(color = 'black', fill="gray") +
  geom_vline(aes(xintercept=mean(ForeignAssets)),
                                                                              color="blue", linetype="dashed", size=1)
#Combining the charts of Estimated Salary, Mortgage, Business Ownner, Foreign Asset, debt
gridExtra::grid.arrange(estsalary, Mortgage,debt,netasset,ownbiz,LifeInsurance,foreignasset,ncol = 3,  nrow = 3)

#-----------------------------------------------------------------------------------------------------

#Distribution of Risk profiles
risk <- ggplot(data1, aes(RiskProfile)) +
  geom_density(color = 'black', fill="gray") + 
  geom_vline(aes(xintercept=mean(RiskProfile)),color="blue", linetype="dashed", size=1) +
  labs(title = "RiskProfile Distribution", position = position_dodge(.9))

#Distribution of  Portfolio Return
pfreturn<- ggplot(data1, aes(PortfolioReturn)) + 
  geom_density(color = 'black', fill="gray")+
  geom_vline(aes(xintercept=mean(PortfolioReturn)),
             color="blue", linetype="dashed", size=1) +
  labs(title = "PortfolioReturn Distribution", position = position_dodge(.9))

#Distribution of Diversification
div <- ggplot(data1, aes(Diversification)) + 
  geom_density(color = 'black', fill="gray") + 
  geom_vline(aes(xintercept=mean(Diversification)),
             color="blue", linetype="dashed", size=1)+
  labs(title = "Diversification Distribution", position = position_dodge(.9))

#Combining the charts of Risk profiles, Portfolio Return, Diversification
gridExtra::grid.arrange(risk, pfreturn, div,ncol = 1,  nrow = 3)

#Distribution of Revenue
Rev <- ggplot(data1, aes(Revenue)) + 
  geom_density(color = 'black', fill="gray") + 
  geom_vline(aes(xintercept=mean(Revenue)),color="blue", 
             linetype="dashed", size=1)

#Distribution of Margin
margin <- ggplot(data1, aes(Margin)) + 
  geom_density(color = 'black', fill="gray") + 
  geom_vline(aes(xintercept=mean(Margin)),color="blue", 
             linetype="dashed", size=1)

#Distribution of NumTransactions
NumTransactions<- ggplot(data = data1, aes(x = factor(NumTransactions), 
                                  y = prop.table(stat(count)), 
                                  fill = factor(NumTransactions), 
                                  label = scales::percent(prop.table(stat(count))))) +
  geom_bar(position = "dodge", show.legend = FALSE) + 
  geom_text(stat = 'count',
            position = position_dodge(.7), 
            vjust = 5, 
            size = 4) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = 'Number of Transactions', y = 'pct',
       title = "Percentage of NumTransactions", position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20)) 

#Combining the charts of Revenue, Margin, Number of Transcations
gridExtra::grid.arrange(Rev, margin, NumTransactions,ncol = 1,  nrow = 3)

#-----------------------------------------------------------------------------------------------------

#Trying to find if we are able to find out the relationship in continuous variables.
#Estimated salary and dependents and Revenue and margins has high correlation. Not a particularly helpful information to us
data1 %>%
  select_if(is.numeric) %>%
  cor() %>%
  heatmap(scale="column", col = cm.colors(256))

#-----------------------------------------------------------------------------------------------------

#Visualization of Bivariate Distribution
#To see the relationship between Age and all the various asset classes
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund,PrivateEquity,GovtBonds, key = "var", value = "value") %>%
  ggplot(aes(x = Age, y =value )) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE) +
  facet_wrap(~var, scales = "free") +
  theme_bw()

#To see the relationship between EstimatedSalary and the various asset classes
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund,PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = EstimatedSalary, y = Assets_Types)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE) +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#To see the relationship between Risk Profile and the asset classes
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund,PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = RiskProfile, y = Assets_Types)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE) +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#To see the relationship between Gender and the asset classes
#Jittered so that the distribution can be seen more clearly for each asset class
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund, PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = Gender, y = Assets_Types)) +
  geom_boxplot()+
  geom_point(position = "jitter", color = "light blue") +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#To see the relationship between Married and the asset classes
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund, PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = Married, y = Assets_Types)) +
  geom_boxplot()+
  geom_point(position = "jitter", color = "light blue") +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#To see the relationship between dependents and the asset classes
#Jittered so that the distribution can be seen more clearly for each asset class
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund, PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = Dependents, y = Assets_Types)) +
  geom_point(position  ="jitter") +
  geom_smooth(method = 'lm', se = FALSE) +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#To see the relationship between Mortgage and the asset classes
#Jittered so that the distribution can be seen more clearly for each asset class
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund, PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = Mortgage, y = Assets_Types)) +
  geom_boxplot()+
  geom_point(position = "jitter", color = "light blue") +
  facet_wrap(~ var, scales = "free") +
  theme_bw()


#To see the relationship between business owner and the asset classes
#Jittered so that the distribution can be seen more clearly for each asset class
data1 %>%
  gather (ETFTech,Gold,CorpBonds,EmergingMarketFund, PrivateEquity,GovtBonds, key = "var", value = "Assets_Types") %>%
  ggplot(aes(x = BusinessOwner, y = Assets_Types)) +
  geom_boxplot()+
  geom_point(position = "jitter", color = "light blue") +
  facet_wrap(~ var, scales = "free") +
  theme_bw()

#-----------------------------------------------------------------------------------------------------

#Scatterplot relationship between age and privateequity
v1 <- ggplot(sdt, aes(x = Age, y = PrivateEquity, colour = agegroup))  + 
  geom_point(size = 5) +
  labs(x = 'Age', y = 'Amount',
       title = "Relationship between Age and PrivateEquity", 
       position = position_dodge(.9)) +
  theme(axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        legend.title = element_text(size=15),
        legend.text = element_text(size = 15))
v1

