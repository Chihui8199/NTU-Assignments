# Continuous Variables
x<-5
class(x)
str(x)

y<-5L # Use the suffix L to treat as integer
class(y)
str(y)






# Nominal Variables

library(data.table)
setwd("D:/Dropbox/NTU Business School/Teaching/BC2406 AY20/3 Data Exploration and Statistics")
flights.dt <- fread("flights14.csv")

summary(flights.dt$month)
summary(flights.dt$day)

class(flights.dt$month)
class(flights.dt$day)


flights.dt$month <- factor(flights.dt$month)
flights.dt$day <- factor(flights.dt$day)

summary(flights.dt$month)
summary(flights.dt$day)

class(flights.dt$month)
class(flights.dt$day)






# Ordinal Variables
X <- c("S", "S", "L", "S", "M", "S", "XL")
class(X)
summary(X)
plot(X)   # plot character variable

X <- factor(X)  # convert X into categorical variable
class(X)

summary(X)
plot(X, main="Figure 4.1: Distribution of Shirt Size")

levels(X)


X <- factor(X, ordered=T, levels = c("S", "M", "L", "XL"))
class(X)
levels(X)
plot(X, main="Figure 4.1: Distribution of Shirt Size")







# ggplot2
# Set a working directory to store all the related datasets and files.
setwd("D:/Dropbox/NTU Business School/Teaching/BC2406 AY20/4 Data Structures and Visualizations")

# Import the CSV dataset into R as a standard data.frame in Base R.
# The target variable is HICOV, coded as Y or N to denote whether that individual have/do not have Health Insurance Coverage.
ins.dt <- fread("states_ins_sub_dt.csv")
summary(ins.dt)

install.packages("ggplot2")
library(ggplot2)


ggplot(data=ins.dt[STATE=="NY"], aes(x=EARNINGS, y=INCOME))
ggplot(data=ins.dt[STATE=="NY"], aes(x=EARNINGS, y=INCOME)) + geom_point()
ggplot(data=ins.dt[STATE=="NY"], aes(x=EARNINGS, y=INCOME)) + geom_point() + labs(title="Income vs Earnings in NY")


# add layers 

p <- ggplot(data=ins.dt[STATE=="NY"], aes(x=EARNINGS, y=INCOME))
p <- p + geom_point()
p <- p + labs(title="Income vs Earnings in NY")



ggplot(data=ins.dt, aes(x=EARNINGS, y=INCOME)) + geom_point() + labs(title="Income vs Earnings across 3 States")
ggplot(data=ins.dt, aes(x=EARNINGS, y=INCOME)) + geom_point() + labs(title="Income vs Earnings across 3 States") + facet_grid(.~STATE)

