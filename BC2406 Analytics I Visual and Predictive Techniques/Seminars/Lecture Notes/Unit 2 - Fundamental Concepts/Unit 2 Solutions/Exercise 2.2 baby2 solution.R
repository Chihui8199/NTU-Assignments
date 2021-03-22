# ==========================================================
# Purpose: RScript for BA1 Week 2 class.
# Author:  Neumann Chew
# DOC:     20-08-2017
#===========================================================

# Set a working directory to store all the related datasets and files for a specific project.
# Correction: Use / instead of \ as the separator.
setwd("D:/Dropbox/Schools/NBS/BC2406 Analytics 1/BC2406 2017/Wk 2")

# Import a data file and store as R object baby2_data in R.
# Correction: add .csv to the filename.
baby2_data <- read.csv("baby2.csv")

# Summary() is a very helpful function to quickly get summary stats of all variables in dataset.
summary(baby2_data)
## Weight has a missing value.
## Max Age = 40 months seems wierd. Is it an outlier or normal?

# Boxplot to visualize distribution and detect outliers (if any).
boxplot(baby2_data$Age)
## Shows an outlier in Age.


boxplot(baby2_data$Weight)
## No outliers.
    
    
# Calculate the average weight of all babies.
# weight = 7.06 is the weight in baby1, not baby2, Wrong ans.
# Use dataset$variable syntax as there are two datasets with similar variable names, in the same R workspace.
# Exclude Missing Value in calculation.
# Can use T or TRUE in na.rm
mean(baby2_data$Weight, na.rm = T)
## 7.788088

summary(baby2_data)

# Calculate the std dev of all variables in the dataset.
sapply(baby2_data, sd, na.rm = T)


# Calculate the correlation between age and weight.
cor(baby2_data$Age, baby2_data$Weight, use = "complete.obs")


# Scatterplot with x-axis = age, y-axis = weight.
plot(x = baby2_data$Age, y = baby2_data$Weight)


# Q: Is there a better and faster way to get summary statistics
#    of all the variables in the dataset, instead of one variable at a time?
## Yes. Use summary() or sapply(),
## or find suitable user contributed packages such as stat.desc() in Package pastecs
summary(baby2_data)
sapply(baby2_data, sd, na.rm = T)


