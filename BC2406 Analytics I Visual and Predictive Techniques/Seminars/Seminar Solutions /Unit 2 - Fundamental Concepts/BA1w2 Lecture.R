# ==========================================================
# Purpose: RScript for demo in BA1 Week 2 class.
# Author:  Neumann Chew & Hyeokkoo Eric Kwon
# DOC:     07-08-2020
#===========================================================

## R Operators

1/200*30

(59+73+2)/3

sin(pi/2)

3^2

5%%2

5%/%2

5>2

5==2

5!=2

!TRUE


## Assignment Operator

x <- 3*4

x

x <- 10

x


## Object Naming Convention in R

sales_of_november <- 5

SalesOfNovember <- 5

sales.of.november <- 5

sales of november <- 5


## R is spelling and case sensitive

r_rocks <- 2^3

r_rocks

r_rock

R_rocks


## R functions

help(seq)

seq(1, 10)


## Text String

x <- hello world

x <- "hello world"

x


## Create Vectors with c function

a <- c(1,2,5.3,6,-2.4)
b <- c("one","Two","Three")
c <- c(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE)

a
b
c

class(a)
class(b)
class(c)

length(a)

a==1 # compare each element of vector a with 1

d <- c(a==1) # store whether each element of vector a is equal to 1 in a new vector d
d

