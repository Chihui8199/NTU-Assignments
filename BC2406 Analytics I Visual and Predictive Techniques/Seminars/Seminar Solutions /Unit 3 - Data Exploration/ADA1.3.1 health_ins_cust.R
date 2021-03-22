# ================================================================
# Purpose:      Rscript for demo in ADA Vol 1, Chap 3.
# Author:       Neumann Chew
# DOC:          27-08-2017
# Updated:      25-08-2018
# Topics:       Data Exploration
# Data Source:  Derived Sample from USA Census PUMS Data
#=================================================================

# Set a working directory to store all the related datasets and files.
setwd("D:/Dropbox/NTU Business School/Teaching/BC2406 AY20/3 Data Exploration and Statistics")

# Import the CSV dataset into R as a standard data.frame in Base R.
## With the option ¡°stringsAsFactors = TRUE¡±, R treats a string vector as categorical variable. 
cust.df <- read.csv("health_ins_cust.csv", stringsAsFactors = TRUE)





# How many rows and columns in the dataset?
dim(cust.df)
## 1000 rows of data (excl. header) and 11 columns.


# To view the dataset saved in R Memory.
# Double click dataset name in Environment tab, or use View(cust_data) function to see all obs, or
head(cust.df)  # see first 6 rows







# Get summary statistics of all columns in dataset.
# Quick way to see range, categories and missing values.
summary(cust.df)


# Get full list of categorical values and their frequency
levels(cust.df$state.of.res)
table(cust.df$state.of.res)









# Check custID for the 56 NAs in the 3 different columns. 
# Are they the same set of customers?
# Syntax: subset(x, subset, select, drop = FALSE, ...)
?subset
HT.na <- subset(cust.df, is.na(housing.type), select = custid)
HT.na 
RM.na <- subset(cust.df, is.na(recent.move), select = custid)
RM.na 
NV.na <- subset(cust.df, is.na(num.vehicles), select = custid)
NV.na

identical(HT.na, RM.na)
## TRUE

identical(HT.na, NV.na)
## TRUE







# Density Plot to see distribution of continuous variable.
# Total area under curve = 1 (i.e. can be interpreted as probability density function)
# Google: density plot in R
plot(density(cust.df$age), xlab="Age", main = "Distribution of Age")





# Histogram to see distribution of continuous variable age after binning into age intervals.
# Intervals can be controlled by the breaks argument. 
# Note: Left open, right closed interval by default.
hist(cust.df$age, ylim=c(0,220), breaks = seq(-10, 150, by=10), xlab="Age", main = "Distribution of Age", labels=T, col ="light blue")





# Density Plot to see distribution of continuous variable.
# Total area under curve = 1 (i.e. can be interpreted as probability density function)
plot(density(cust.df$income), xlab="Income(US$)", main = "Distribution of Income")


# Remove Scientific Notation (exponential) from Plot and Result Outputs
# Scientific Notation Penalty
getOption("scipen")  # Default value = 0
options(scipen=100)
plot(density(cust.df$income), xlab="Income (US$)", main = "Distribution of Income")







# Boxplot with Y = Income, X = Employment Status (for continuous Y and categorical X)
boxplot(cust.df$income ~ cust.df$is.employed, xlab = "Is Employed", ylab = "Annual Income (US$)", main = "Distributions of Annual Income across Employment Status")
boxplot(cust.df$income ~ cust.df$is.employed, xlab = "Is Employed", ylab = "Annual Income (US$)", main = "Distributions of Annual Income across Employment Status")$stats







# Bar charts to see distribution of categorical variables - Marital Status.
barplot(table(cust.df$marital.stat),  main="Distribution of Marital Status", xlab="Marital Status", col = c("lightblue", "mistyrose", "lightcyan", "lavender"))






# For categorical variables with many values (e.g., state.of.res): horizontal bar chart
par(las=2) # make label text perpendicular to axis. Default is 0 (parallel).
par(mar=c(5,8,4,2)) # increase y-axis margin. Default is c(bottom, left, top, right) = c(5,4,4,2)+0.1.
?par

# cex.names to modify font size so that labels can fit in chart.
barplot(table(cust.df$state.of.res),  horiz = T, cex.names=0.5, main="Distribution of State of Residence")

# Reset plot margins to original settings
par(las=0)
par(mar= c(5,4,4,2)+0.1)

barplot(table(cust.df$state.of.res),  horiz = T, cex.names=0.5, main="Distribution of State of Residence")








# Scatterplot of income across Ag (for continuous X and Y)
plot(cust.df$age, cust.df$income, xlab="Age", ylab = "Income", main = "Income across Age")








# Scatterplot of Income across Age, with smooth curve. Default span = 0.75.
scatter.smooth(cust.df$age, cust.df$income, col="grey", xlab="Age", ylab = "Income", main = "Income across Age")








# Jittered scatterplot of age and health insurance (for continuous X and categorical Y)
plot(cust.df$age, cust.df$health.ins, xlab="Age", ylab = "Health Insurance Coverage", main = "Health Insurance Coverage across Age")
## Many overlapping points. Hard to see majority/minority.
plot(cust.df$age, jitter(cust.df$health.ins), xlab="Age", ylab = "Health Insurance Coverage", main = "Health Insurance Coverage across Age (with jittered Y)")
plot(cust.df$age, jitter(as.numeric(cust.df$health.ins)), xlab="Age", ylab = "Health Insurance Coverage", main = "Health Insurance Coverage across Age (with jittered Y)")

# Boxplot for continuous Y and categorical X
boxplot(cust.df$age ~ cust.df$health.ins, ylab="Age", xlab = "Health Insurance Coverage", main = "Health Insurance Coverage across Age ")










# Scatterplot matrix of 9 variables with smooth curve in each 5% window.
pairs(~ health.ins + age + sex + is.employed + income + marital.stat + housing.type + recent.move + num.vehicles, panel=panel.smooth, span=0.75, data = cust.df)
# panel.smooth = add smooth curve
# span = smoothing parameter (greater, more linear)








# Stacked Barchart
count1 <- table(cust.df$health.ins, cust.df$marital.stat)
count1
par(mar=c(5.1, 4.1, 4.1, 7.1), xpd=F) # set greater right margin 
barplot(count1,  main="Health Insurance Coverage by Marital Status", xlab="Marital Status", ylab="Frequency", col = c("red", "grey"))

# add legend
legend("topright",inset=c(0,0), fill=c("red", "grey"), legend=rownames(count1), border = "grey", cex = 0.6)
legend("topright",inset=c(0.1,0), fill=c("red", "grey"), legend=rownames(count1), border = "grey", cex = 0.6)
legend("topright",inset=c(0,0.1), fill=c("red", "grey"), legend=rownames(count1), border = "grey", cex = 0.6)





# Stacked Percentage Barchart
prop1 <- prop.table(count1, margin=2) # calculate proportion based on freq in column (margin=2)

prop.table(count1, margin=2)
prop.table(count1, margin=1)

par(mar=c(5.1, 4.1, 4.1, 7.1), xpd=T)
barplot(prop1,  main="Health Insurance Coverage by Marital Status", xlab="Marital Status", ylab="Proportion", col = c("red", "grey"))
legend("topright",inset=c(-0.1,0), fill=c("red", "grey"), legend=rownames(count1), border = "grey", cex = 0.6)

# Reset plot margins to original settings
par(mar= c(5,4,4,2)+0.1, xpd=F)





-------------------------------------------------------------





# Install external package "data.table"
install.packages("data.table")

# Load external package "data.table"
library(data.table)




# Import health_ins_cust.csv with read.csv and fread
## Base R
data1 <- read.csv('health_ins_cust.csv')

## Data.Table
data2 <- fread('health_ins_cust.csv')




# Use the class() function to compare data1 vs data2
class(data1)
## data frame

class(data2)
## data table and data frame


