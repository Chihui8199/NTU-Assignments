
setwd("~/Desktop/Y2S1/BC2406/Unit 4 - Data Structures and Visualization")
library(data.table)
lawsuit.dt <- fread("Lawsuit.csv")
states.df <- fread("states_ins_sub_dt.csv")
lawsuit.dt$Gender = factor(lawsuit.dt$Gender)
lawsuit.dt$Clin = factor(lawsuit.dt$Clin)
lawsuit.dt$Cert = factor(lawsuit.dt$Cert)
lawsuit.dt$Rank = factor(lawsuit.dt$Rank)v