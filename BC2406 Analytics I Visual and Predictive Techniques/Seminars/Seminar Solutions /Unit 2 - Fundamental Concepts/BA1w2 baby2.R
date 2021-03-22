# ==========================================================
# Purpose: RScript for Team Challenge in BA1 Week 2 class.
# Author:  Neumann Chew
# DOC:     20-08-2017
#===========================================================

# Set a working directory to store all the related datasets and files for a specific project.
setwd("D:\Dropbox\NTU Business School\Teaching\BC2406 AY19\2 Fundamental Concepts and Principles")

# Import a data file and store as R object baby2_data in R.
baby2_data <- read.csv("baby2")


# Calculate the average weight of all babies.

mean(weight)


# Calculate the std dev of weight of all babies.
sd(weight)


# Calculate the correlation between age and weight.
cor(age, weight)


# Scatterplot with x-axis = age, y-axis = weight.
plot(baby2_data$Age, baby2_data$Weight)


# Q: Is there a better and faster way to get summary statistics
#    of all the variables in the dataset, instead of one variable at a time?



