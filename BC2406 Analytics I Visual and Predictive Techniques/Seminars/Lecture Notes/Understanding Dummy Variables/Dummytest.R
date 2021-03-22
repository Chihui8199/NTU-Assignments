 
setwd("~/Desktop/Y2S1/BC2406/Understanding Dummy Variables")



# if you choose to use occ code

data <- read.csv("Occupation.csv")
#CEO is the baseline here base on alphabetical order
levels(data$occ)

#IMPT:must remember to overwi=rite ti set the base line to manager
data$occ <-relevel(data$occ, ref - "Manager")

#Verified manager is now the baseline ref as it's first category
levels(data$occ)