# ==================================  Get Path =========================================
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# =====================  Download Libraries to run code =========================================
if(!require("skimr"))install.packages("skimr")

# ================================ Load Data =========================================
library(tidyverse)
library(data.table)
library(dplyr)
library(modeest)
library(neuralnet)
library(fastDummies)
library(caTools)

set.seed(420.69)
data1<- fread("Austin_Public_Health_Diabetes_Self-Management_Education_Participant_Demographics_2015-2017.csv",  
              na.strings = c(""), stringsAsFactors = T, header = T)
# ========================= Renaming columns =========================================
data1 <- data1 %>% rename(
  DiabetesStatus = "Diabetes Status (Yes/No)" ,
  HeartDisease = "Heart Disease (Yes/No)" ,
  HighBloodPressure = "High Blood Pressure (Yes/No)" ,
  TobaccoUse = "Tobacco Use (Yes/No)" ,
  PreviousDiabetesEducation = "Previous Diabetes Education (Yes/No)" ,
  FruitsVegetableConsumption = "Fruits & Vegetable Consumption" ,
  ClassLanguage = "Class Language",
  InsuranceCategory = "Insurance Category",
  MedicalHomeCategory = "Medical Home Category",
  RaceEthnicity = "Race/Ethnicity",
  EducationLevel = "Education Level",
  SugarBevConsumption = "Sugar-Sweetened Beverage Consumption",
  FoodMeasurement = "Food Measurement",
  CarboCount = "Carbohydrate Counting",
  PAID = "Problem Area in Diabetes (PAID) Scale Score",
  DiabetesKnowledge = "Diabetes Knowledge"
)
#============================ data exploration =======================================
#How many rows and columns in the dataset?
dim(data1)
## 1688 rows of data (excl. header) and 21 columns.

# =========================== Cleaning vague responses ===============================
#1644 obs - removed all rows with diabetes = unknown or NA
data1 <- droplevels(data1[!data1$DiabetesStatus == 'Unknown',]) 
data1$Gender<-recode(data1$Gender, "f" = "F")
data1$FoodMeasurement<-recode(data1$FoodMeasurement, "Not Sure" = "I don't know how")
data1$FoodMeasurement<-recode(data1$FoodMeasurement, "0" = "0 days")
data1$CarboCount<-recode(data1$CarboCount, "Not Sure" = "I don't know how")
data1$EducationLevel<-recode(data1$EducationLevel, "Some College" = "College")
# Dropped the none
data1 <- droplevels(data1[!data1$EducationLevel == 'none',]) 
summary(data1)

data1[ ,`:=`(PAID = NULL)]
data1[ ,`:=`(Class = NULL)]

#================================ Clean NA's ====================================
#Self Function Model: Using mode to replace the NAs
mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

#================================ Clean Age ====================================
mode(data1$Age) #The most common value in the dataset for Age is 37, we can use this to replace the NA values
#================================ Replace with Mode ====================================
#Age
data1[is.na(Age), Age:= mode(data1$Age)]
#Verify that the values have been correctly replaced in the dataset
sapply(data1, function(x) sum(is.na(x))) #0 NAs remaining in Age

#Race/Ethicnity
sum(is.na(data1$`RaceEthnicity`)) #  37 out of 1688, % replacing is ok
data1[is.na(`RaceEthnicity`), `RaceEthnicity`:= mode(data1$`RaceEthnicity`)]


# ======================== Subsetting people based on race ==================================
data1_hispanic_clean <- subset(data1, data1$RaceEthnicity == "Hispanic/Latino")
data1_asian_clean <- subset(data1, data1$RaceEthnicity == "Asian")
data1_indian_clean <- subset(data1, data1$RaceEthnicity == "American Indian")
data1_white_clean <- subset(data1, data1$RaceEthnicity == "White")
data1_black_clean <- subset(data1, data1$RaceEthnicity == "Black/African American")

# ======================== Data Cleaning (All 2 Category Variables) ==================================
list_of_2Cat_var <- list("TobaccoUse","HeartDisease","PreviousDiabetesEducation", "HighBloodPressure", 
                         "DiabetesStatus", "Gender")

Clean_2CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2]), prob = c(test[1], test[2]), 
                       size = num, replace=TRUE)
  
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_2Cat_var){
  data1_hispanic_clean <-Clean_2CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_2CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_2CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_2CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_2CategoricalValues(data1_black_clean, i)
}

# ================================== Data Cleaning (All 3 Category Vairables) ==================================
list_of_3Cat_var <- ("DiabetesKnowledge")
Clean_3CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3]), prob = c(test[1], test[2], test[3]), 
                       size = num, replace=TRUE)
  
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_3Cat_var){
  data1_hispanic_clean <-Clean_3CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_3CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_3CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_3CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_3CategoricalValues(data1_black_clean, i)
}


# ================================== Data Cleaning (All 4 Category Vairables) ==================================
list_of_4Cat_var <- list("EducationLevel", "FoodMeasurement", "CarboCount")
Clean_4CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3], row_name[4]), prob = c(test[1], test[2], test[3], test[4]), 
                       size = num, replace=TRUE)
  
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_4Cat_var){
  data1_hispanic_clean <-Clean_4CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_4CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_4CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_4CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_4CategoricalValues(data1_black_clean, i)
}

# ================================== Data Cleaning (All 5 Category Vairables) ==================================
list_of_5Cat_var <- list("SugarBevConsumption", "FruitsVegetableConsumption")
Clean_5CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3], row_name[4], row_name[5]), 
                       prob = c(test[1], test[2], test[3], test[4], test[5]), 
                       size = num, replace=TRUE)
  
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}
for(i in list_of_5Cat_var){
  data1_hispanic_clean <-Clean_5CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_5CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_5CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_5CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_5CategoricalValues(data1_black_clean, i)
}

# ================================== Data Cleaning (All 6 Category Vairables) ==================================
list_of_6Cat_var <- list("InsuranceCategory")
Clean_6CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3], row_name[4], row_name[5], row_name[6]), 
                       prob = c(test[1], test[2], test[3], test[4], test[5], test[6]), 
                       size = num, replace=TRUE)
  
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_6Cat_var){
  data1_hispanic_clean <-Clean_6CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_6CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_6CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_6CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_6CategoricalValues(data1_black_clean, i)
}

# ================================== Data Cleaning (All 7 Category Vairables) ==================================
list_of_7Cat_var <- list("Exercise")
Clean_7CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3], row_name[4], row_name[5], row_name[6], row_name[7]), 
                              prob = c(test[1], test[2], test[3], test[4], test[5], test[6], test[7]), 
                              size = num, replace=TRUE)
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_7Cat_var){
  data1_hispanic_clean <-Clean_7CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_7CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_7CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_7CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_7CategoricalValues(data1_black_clean, i)
}


# ================================== Data Cleaning (All 9 Category Vairables) ==================================
list_of_9Cat_var <- list("MedicalHomeCategory")
Clean_9CategoricalValues <- function(data1_type, col) {
  # Original proportions
  test <- prop.table(table(data1_type[[col]]))
  row_name <- rownames(test)
  # Extracting NA rows
  df1 <- subset(data1_type, is.na(data1_type[[col]]))
  num <- as.integer(count(df1))
  
  # Deleting NA rows
  df2 <- subset(data1_type, !is.na(data1_type[[col]]))
  
  # Subbing in col proportion into NA cells
  df1[[col]] <- sample(x = c(row_name[1], row_name[2],row_name[3], row_name[4], row_name[5], row_name[6], row_name[7],row_name[8],row_name[9]), 
                       prob = c(test[1], test[2], test[3], test[4], test[5], test[6], test[7], test[8], test[9]), 
                       size = num, replace=TRUE)
  # Refactor the values
  df1[[col]] <- factor(df1[[col]])
  
  # Combining two datasets back together
  data1_type <- rbind(df1, df2)
  return(data1_type)
}

for(i in list_of_9Cat_var){
  data1_hispanic_clean <-Clean_9CategoricalValues(data1_hispanic_clean, i)
  data1_asian_clean <- Clean_9CategoricalValues(data1_asian_clean, i)
  data1_indian_clean <- Clean_9CategoricalValues(data1_indian_clean, i)
  data1_white_clean<- Clean_9CategoricalValues(data1_white_clean, i)
  data1_black_clean <-Clean_9CategoricalValues(data1_black_clean, i)
}

finalclean <- rbind(data1_hispanic_clean,data1_asian_clean,data1_indian_clean,data1_white_clean,data1_black_clean)  


# ========================== Approximating income from insurance ================================

finalclean[InsuranceCategory == "MAP" | InsuranceCategory == "Medicaid" | InsuranceCategory == "None" , 
           Income := "Low"]

finalclean[InsuranceCategory == "Private insurance" | InsuranceCategory == "Other" | InsuranceCategory == "MediCARE", 
           Income := "Not low"]

# ========================== Creating ordinal variables ================================

finalclean$DiabetesKnowledge <- factor(finalclean$DiabetesKnowledge, order = TRUE,
                                    levels = c("Poor", "Fair", "Good"))
finalclean$EducationLevel <- factor(finalclean$EducationLevel, order = TRUE,
                                levels = c("1-8", "9-11", "High School GED", "College"))
finalclean$Exercise <- factor(finalclean$Exercise, order = TRUE,
                         levels = c("Not Sure", "0 days", "1 day", "2 days", "3 days", "4 days", "5 or more days"))
finalclean$CarboCount <- factor(finalclean$CarboCount, order = TRUE,
                                      levels = c("I don't know how", "0 days", "1-3", "4 or more"))
finalclean$FoodMeasurement <- factor(finalclean$FoodMeasurement, order = TRUE,
                                levels = c("I don't know how", "0 days", "1-3", "4 or more"))
finalclean$SugarBevConsumption <- factor(finalclean$SugarBevConsumption, order = TRUE,
                                levels = c("Not Sure", "0", "1", "2", "3 or more"))
finalclean$FruitsVegetableConsumption <- factor(finalclean$FruitsVegetableConsumption, order = TRUE,
                                         levels = c("Not Sure", "0", "1-2", "3-4", "5 or more"))
finalclean$Income <- factor(finalclean$Income, order = TRUE,
                                                levels = c("Low", "Not low"))

summary(finalclean)


remove(list = c('data1', 'data1_asian_clean', 'data1_black_clean', 'data1_hispanic_clean', 'data1_white_clean',
                'data1_indian_clean', 'list_of_2Cat_var', 'list_of_3Cat_var', 'list_of_4Cat_var', 
                'list_of_5Cat_var', 'list_of_6Cat_var', 'list_of_7Cat_var', 'list_of_9Cat_var', 'i', 
                'Clean_2CategoricalValues', 'Clean_3CategoricalValues', 'Clean_4CategoricalValues',
                'Clean_5CategoricalValues', 'Clean_6CategoricalValues', 'Clean_7CategoricalValues',
                'Clean_9CategoricalValues', 'mode'))


# ========================= Drop Class Column ================================
summary(finalclean)

write.csv(finalclean, "austin_diabetes.csv", row.names = F)

