library(xml2)
library(readxl)
library(readr)
library(tidyr)
library(dplyr)
library(purrr)
library(ggplot2)
library(lubridate)

# Set options to limit sci notation and decimal places
options(scipen = 999, digits = 3)

# =======================================================================
# 
# Data Import - CDC Suicides, CDC Homicides, CDC Population
# 
# =======================================================================

# Data accessed at
# https://wonder.cdc.gov/

# Import CDC Suicide Data (edited version with additional footer data deleted) 
suicides_df <- read_tsv("data_edited/CDC_FirearmSuicide_1999-2016.txt")

# Review general layout by viewing head of file
head(suicides_df)

# Remove duplicate/empty columns, make Rate numeric
suicides_df$Notes <- NULL
suicides_df$'State Code' <- NULL
suicides_df$'Year Code' <- NULL
suicides_df$`Crude Rate` <- as.numeric(suicides_df$`Crude Rate`)

# Standardize and sepcify variable names (plan to merge w/ homicide data)
suicides_df <- suicides_df %>%
  rename(state = State) %>%
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

# Run histograms to check distribution of values, any outliers
hist(suicides_df$sui_cnt)
hist(suicides_df$sui_rate)
plot(suicides_df$sui_pop, suicides_df$sui_cnt)
# Looks like everything checks out: fairly normal dist on rate, right skewed count due to pop size

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(suicides_df, path = "data_cleaned/suicides_df.csv")

# =======================================================================

# Repeat process w/ appropriate variable adjustments for homicide data
homicides_df <- read_tsv("data_edited/CDC_FirearmHomicide_1999-2016.txt")

head(homicides_df)

homicides_df$Notes <- NULL
homicides_df$'State Code' <- NULL
homicides_df$'Year Code' <- NULL
homicides_df$`Crude Rate` <- as.numeric(homicides_df$`Crude Rate`)

homicides_df <- homicides_df %>%
  rename(state = State) %>%
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

# Run histograms to check distribution of values, any outliers
hist(homicides_df$hom_cnt)
hist(homicides_df$hom_rate)
plot(homicides_df$hom_pop, homicides_df$hom_cnt)
# Right skewed count due to pop size. Curious long right tail in dist on rate? 

homicides_df %>%
  filter(hom_rate > 10) %>%
  arrange(desc(hom_rate)) %>%
  print(n = 25)
# DC rate extremely high, partially due to small population
hist(homicides_df$hom_rate[homicides_df$state != "District of Columbia"])

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(homicides_df, path = "data_cleaned/homicides_df.csv")

# =======================================================================

# Modify process to adjust for population data

# Import CDC Population Data (baseline for joining suicide/homicide data)
population_df <- read_tsv("data_edited/CDC_PopEst_1990-2016.txt")
head(population_df)

# Similar adjustments for population table
population_df$Notes <- NULL
population_df$`Yearly July 1st Estimates Code` <- NULL
population_df$`State Code` <- NULL

population_df <- population_df %>%
  rename(state = State) %>%
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
hist(population_df$pop)

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(population_df, path = "data_cleaned/population_df.csv")

# =======================================================================
# 
# Data Merge - CDC Suicides, CDC Homicides, CDC Population
# 
# =======================================================================

# Create standard join key variable for most common table join 
join_key <- c("state", "year")

# Join Population base table w/ homicides and suicides tables
gun_deaths_df <- left_join(population_df, homicides_df, by = join_key) %>%
  left_join(suicides_df, by = join_key) %>%
  select(-hom_pop, -sui_pop)

# Check results
head(gun_deaths_df)
summary(gun_deaths_df)

# Need to address 91 NA's in Homicide and HomicideRate and 6 NA's in Suicide & Suicide Rate
# Select list of States w/ NA in Homicides
# Calculate Min-Max-Mean for each State w/ NA to guide interpolation
gun_deaths_df %>%
  filter(is.na(hom_cnt)) %>%
  select(state) %>%
  unique() %>%  
  left_join(gun_deaths_df, by = "state") %>%
  group_by(state) %>%
  summarise(min = min(hom_cnt, na.rm = TRUE), max = max(hom_cnt, na.rm = TRUE), mean = mean(hom_cnt, na.rm = TRUE))

# Results suggest using mean to replace missing values

# Repeat for Suicide data
gun_deaths_df %>%
  filter(is.na(sui_cnt)) %>%
  select(state) %>%
  unique() %>%
  left_join(gun_deaths_df, by = "state") %>%
  group_by(state) %>%
  summarise(min = min(sui_cnt, na.rm = TRUE), max = max(sui_cnt, na.rm = TRUE), mean = mean(sui_cnt, na.rm = TRUE))

# Again the mean looks like the best replacement value

# Replace NA in Suicides/Homicides with Mean for respective State
# Calculate hom_rate and sui_rate to replace NA values 
gun_deaths_df <- gun_deaths_df %>%
  group_by(state) %>%
  mutate(hom_cnt = ifelse(is.na(hom_cnt), as.integer(mean(hom_cnt, na.rm = TRUE)), hom_cnt)) %>%
  mutate(sui_cnt = ifelse(is.na(sui_cnt), as.integer(mean(sui_cnt, na.rm = TRUE)), sui_cnt)) %>%
  mutate(hom_rate = ifelse(is.na(hom_rate), round(hom_cnt / pop * 100000, 1), hom_rate)) %>% 
  mutate(sui_rate = ifelse(is.na(sui_rate), round(sui_cnt / pop * 100000, 1), sui_rate))

# Check results
summary(gun_deaths_df)

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(gun_deaths_df, path = "data_cleaned/gun_deaths_df.csv")

# =======================================================================
# 
# Import Region/Subregion data to join on State for higher level analysis
# 
# =======================================================================

# Regional data information accessed at
# https://www2.census.gov/geo/docs/maps-data/maps/reg_div.txt

regions_df <- read_excel("data_edited/State_FIPS_Codes.xlsx")

# Check data
head(regions_df)

# Convert code fields to integer
regions_df$fips_st <- as.integer(regions_df$fips_st)
regions_df$reg_code <- as.integer(regions_df$reg_code)
regions_df$subreg_code <- as.integer(regions_df$subreg_code)

# Create region and subregion fields w/ code+name for sorting/labeling purposes
regions_df <- regions_df %>%
  unite(region, reg_code, reg_name, sep = "-", remove = FALSE) %>%
  unite(subregion, subreg_code, subreg_name, sep = "-", remove = FALSE)

# Check results
head(regions_df)
summary(regions_df)

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(regions_df, path = "data_cleaned/regions_df.csv")

# =======================================================================
# 
# Import Boston University School of Public Health Gun Law Data
# 
# =======================================================================

# Data accessed at
# https://www.statefirearmlaws.org/table.html

state_laws_df <- read.csv("data_edited/state_gun_law_database.csv")
state_codes_df <- read_xlsx("data_edited/state_gun_laws_codebook.xlsx")

head(state_laws_df)
str(state_laws_df)

head(state_codes_df)
str(state_codes_df)


# Clean up category names in State Firearm Codes
state_codes_df <- state_codes_df %>%
  select(cat_code = `Category Code`, cat = Category, sub_cat = `Sub-Category`, var_name = `Variable Name`)

# Filter state law data for 1999-2016 period only
state_laws_df <- state_laws_df %>%
  filter(year >= 1999 & year <= 2016)

# Address issues related to large number of variables in state_laws_df

# View category names for var_name lookup
unique(state_codes_df$cat)

# Use code below to generate var_name by cat for mutate below
state_codes_df %>%
  filter(cat == "Buyer regulations") %>%
  select(var_name)

# Collapse 134 individual variables in to 14 larger category groupings
laws_cat_df <- state_laws_df %>%
  mutate(deal_reg = dealer + dealerh + recordsall + recordsdealerh + recordsall + 
           reportdealer + reportdealerh + reportall + reportallh + purge + residential + 
           theft + security + inspection + liability + junkgun) %>%
  mutate(buy_reg = waiting + waitingh + permit + permith + permitlaw + fingerprint +
           training + registration + registrationh + defactoreg + defactoregh + age21handgunsale + 
           age18longgunsale + age21longgunsale + age21longgunsaled + loststolen + onepermonth) %>%
  mutate(high_risk = felony + violent + violenth + violentpartial + invcommitment + 
           invoutpatient + danger + drugmisdemeanor + alctreatment + alcoholism) %>%
  mutate(bkgrnd_chk = universal + universalh + gunshow + gunshowh + universalpermit + universalpermith + 
           backgroundpurge + threedaylimit + mentalhealth + statechecks + statechecksh) %>%
  mutate(ammo_reg = ammlicense + ammrecords + ammpermit + ammrestrict + amm18 +
           amm21h + ammbackground) %>%
  mutate(poss_reg = age21handgunpossess + age18longgunpossess + age21longgunpossess + 
           gvro + gvrolawenforcement + college + collegeconcealed + elementary + opencarryh +
           opencarryl + opencarrypermith + opencarrypermitl) %>%
  mutate(conceal_reg = permitconcealed + mayissue + showing + ccrevoke + ccbackground +
           ccbackgroundnics + ccrenewbackground) %>%
  mutate(assault_mag = assault + onefeature + assaultlist + assaultregister + assaulttransfer +
           magazine + tenroundlimit + magazinepreowned) %>%
  mutate(child_acc = lockd + lockp + lockstandards + locked + capliability + capaccess +
           capuses + capunloaded + cap18 + cap16 + cap14) %>%
  mutate(gun_traff = traffickingbackground + traffickingprohibited + traffickingprohibitedh +
           strawpurchase + strawpurchaseh + microstamp + personalized) %>%
  mutate(stnd_grnd = nosyg) %>%
  mutate(pre_empt = preemption + preemptionbroad + preemptionnarrow) %>%
  mutate(immunity_ = immunity) %>%
  mutate(dom_viol = mcdv + mcdvdating + mcdvsurrender + mcdvsurrendernoconditions +
           mcdvsurrenderdating + mcdvremovalallowed + mcdvremovalrequired + incidentremoval +
           incidentall + dvro) %>%
  select(state, year, contains("_"))

head(laws_cat_df)
summary(laws_cat_df)
str(laws_cat_df)

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(state_laws_df, path = "data_cleaned/state_laws_df.csv")
write_csv(laws_cat_df, path = "data_cleaned/laws_cat_df.csv")


# =======================================================================
# 
# Import Giffords Law Center Gun Law Data
# 
# =======================================================================

# Data accessed at 
# http://lawcenter.giffords.org/

# Import Giffords Law Center data, compiled in CSV from website data
giff_grd_df <- read.csv("data_edited/giffords_gunlawscorecard.csv")

# Import LetterGardeConverter to translate letter to numeric grade
grd_conv_df <- read.csv("data_edited/LetterGradeConverter.csv")

# Review data frame contents

head(grd_conv_df)
head(giff_grd_df)
str(giff_grd_df)
summary(giff_grd_df)

# Reverse numerical ordering of death_rnk to 1 for Fewest 50 for Most
# More intuitive to have rank on both reflect greater safety
giff_grd_df <- giff_grd_df %>%
  mutate(death_rnk = 51 - death_rnk)

head(giff_grd_df)

# Calculate numerical grade from grd_conv_df table, re-arrange table
giff_grd_df <- giff_grd_df %>%
  left_join(grd_conv_df, by = c("law_grd" = "Letter")) %>%
  select(state, year, law_grd, law_score = GPA, law_rnk, death_rnk, bkgrnd_chk) %>%
  arrange(state, year)

head(giff_grd_df)

# Create aggreagte data table w/ avg scores and ranks by state
giff_agg_df <- giff_grd_df %>%
  group_by(state) %>%
  summarise(avg_score = round(mean(law_score), 2), avg_law_rnk = round(mean(law_rnk), 2), 
            avg_death_rnk = round(mean(death_rnk), 2), avg_bkgrnd = round(mean(bkgrnd_chk), 2))

# Export to data_cleaned per Section 3 Data Wrangling Ex. 7
write_csv(giff_grd_df, path = "data_cleaned/giff_grd_df.csv")
write_csv(giff_agg_df, path = "data_cleaned/giff_agg_df.csv")

# =======================================================================
# 
# Import Gun Ownership Data and Guns & Ammo Magazine Rankings
# 
# =======================================================================

# Data accessed at
# http://injuryprevention.bmj.com/content/22/3/216
# http://www.gunsandammo.com/second-amendment/best-states-for-gun-owners-2017/
# http://www.gunsandammo.com/network-topics/culture-politics-network/best-states-for-gun-owners-2015/

gun_own_2013_df <- read_excel("data_edited/gun_ownership_rates_2013.xlsx")
gun_ammo_df <- read.csv("data_edited/guns_ammo_rankings.csv")

head(gun_own_2013_df)
summary(gun_own_2013_df)

head(gun_ammo_df)
summary(gun_ammo_df)

# No data cleaning required
