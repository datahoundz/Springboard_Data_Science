library(xml2)
library(readxl)
library(readr)
library(tidyr)
library(dplyr)
library(purrr)
library(ggplot2)
library(lubridate)

# =======================================================================
# 
# Data Import - CDC Suicides, CDC Homicides, CDC Population
# 
# =======================================================================

# Import CDC Suicide Data (cleaned version with additional footer data deleted) 
suicides_df <- read_tsv("data_cleaned/CDC_FirearmSuicide_1999-2016.txt")

# Review general layout by viewing head of file
head(suicides_df)

# Remove duplicate/empty columns, make Rate numeric
suicides_df$Notes <- NULL
suicides_df$'Year Code' <- NULL
suicides_df$`Crude Rate` <- as.numeric(suicides_df$`Crude Rate`)

# Standardize and sepcify variable names (plan to merge w/ homicide data)
suicides_df <- suicides_df %>%
  rename(state = State) %>%
  rename(st_code = 'State Code') %>%
  rename(year = Year) %>%
  rename(sui_cnt = Deaths) %>%
  rename(sui_pop = Population) %>%
  rename(sui_rate = 'Crude Rate')

# Check results
head(suicides_df)

# Check for NAs and other data issues
summary(suicides_df)

# 13 NA's in suicide rate?
suicides_df %>%
  filter(is.na(sui_rate))

# DC & RI too few for calculation, replace NA w/ calculation
suicides_df <- mutate(suicides_df, sui_rate = ifelse(is.na(sui_rate), round(sui_cnt / sui_pop * 100000, 1), sui_rate))
summary(suicides_df)

# =======================================================================

# Repeat process w/ appropriate variable adjustments for homicide data
homicides_df <- read_tsv("data_cleaned/CDC_FirearmHomicide_1999-2016.txt")

head(homicides_df)

homicides_df$Notes <- NULL
homicides_df$'Year Code' <- NULL
homicides_df$`Crude Rate` <- as.numeric(homicides_df$`Crude Rate`)

homicides_df <- homicides_df %>%
  rename(state = State) %>%
  rename(st_code = 'State Code') %>%
  rename(year = Year) %>%
  rename(hom_cnt = Deaths) %>%
  rename(hom_pop = Population) %>%
  rename(hom_rate = 'Crude Rate')

# Check results
head(homicides_df)

# Check for NAs and other data issues
summary(homicides_df)

# 86 NA's in hom_rate
homicides_df %>%
  filter(is.na(hom_rate))

# Same issue as suicides data - replace NA hom_rate w/ calculation
homicides_df <- mutate(homicides_df, hom_rate = ifelse(is.na(hom_rate), round(hom_cnt / hom_pop * 100000, 1), hom_rate))
summary(homicides_df)


# =======================================================================

# Modify process to adjust for population data

# Import CDC Population Data (baseline for combining suicide/homicide data)
population_df <- read_tsv("data_cleaned/CDC_PopEst_1990-2016.txt")
head(population_df)

# Similar adjustments for population table
population_df$Notes <- NULL
population_df$`Yearly July 1st Estimates Code` <- NULL

population_df <- population_df %>%
  rename(state = State) %>%
  rename(st_code = 'State Code') %>%
  rename(year = `Yearly July 1st Estimates`) %>%
  rename(pop = Population)
  
# Filter for Years applicable to available CDC data
population_df <- population_df %>%
  filter(year >= 1999)

# Check to make sure totals match up (51 states x 18 years)
51*18 == nrow(population_df)

# Check results
head(population_df)
summary(population_df)
