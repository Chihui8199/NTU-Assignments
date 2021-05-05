library(data.table)

setwd("~/Desktop/Y2S2/BC2407/S2 Review of Basic Analytics and Software")
data1 <- fread("resale-flat-prices-2019.csv", stringsAsFactors=T, header = T)




data1$remaining_lease_years <-copy(data1$remaining_lease)
data1$remaining_lease_years <- substr(data1$remaining_lease_years, 1, 8)
View(data1)

data1$town <- factor(data1$town)
levels(factor(data1$town)) 
relevel(data1$town, ref = "YISHUN")

m1 <- lm(resale_price ~ floor_area_sqm + remaining_lease_years + town + storey_range, data = data1)

summary(m1)
RMSE <- sq(data1$resale_price,m1)