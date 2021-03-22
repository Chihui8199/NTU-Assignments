# ==========================================================
# Purpose: RScript for demo in BA1 Week 2 class.
# Author:  Neumann Chew
# DOC:     20-08-2017
#===========================================================

# Create a vector of baby's age in months.
age <- c(1,3,5,2,11,9,3,9,12,3)

# Create a corresponding vector of baby's weight in kg.
weight <- c(4.4,5.3,7.2,5.2,8.5,7.3,6.0,10.4,10.2,6.1)

# Calculate the average weight of all babies.
mean(weight)
## 7.06

# Calculate the std dev of weight of all babies.
sd(weight)
## 2.077498

# Calculate the correlation between age and weight.
cor(age,weight)
## 0.9075655

# Scatterplot with x-axis = age, y-axis = weight.
plot(age,weight, col = "red",main = "Plot of Baby's Weight vs Age")


id <- seq(1,10)

# Create a dataset with 3 columns.
baby_data <- data.frame(id, age, weight)

# Create variable names for the three columns in baby_data.
names(baby_data) <- c("ID","Age","Weight")

# Export the R dataset into a CSV file. This file will be saved in your working directory.
write.csv(baby_data, file = "baby.csv")
## R added row names by default.

# Prevents R from adding row names to each row.
write.csv(baby_data, file = "baby.csv", row.names=FALSE)
