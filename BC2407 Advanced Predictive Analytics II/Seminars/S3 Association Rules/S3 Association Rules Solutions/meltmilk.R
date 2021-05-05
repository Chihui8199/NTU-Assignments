# Purpose: Reshape milk.csv into long format via melt()
# Author: Chew C. H.

library(reshape2)

setwd("D:/Dropbox/Schools/NBS/BC2407 Analytics 2/S3 Association Rules")
widedata <- read.csv("milk.csv")
longdata <- melt(data = widedata, id.vars = "ID")
longdata2 <- subset(longdata, value != 0)
longdata2 <- longdata2[, 1:2]  # Keep only first 2 columns.

# Export the long format as csv file.
write.csv(longdata2, "longdatamilk.csv", row.names = F)
