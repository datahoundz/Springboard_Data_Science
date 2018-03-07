library(xml2)
library(readxl)
library(readr)
library(tidyr)
library(dplyr)
library(purrr)
library(ggplot2)
library(lubridate)
library(broom)

# Set options to limit sci notation and decimal places
options(scipen = 999, digits = 3)

# =======================================================================
# 
# Statistical Analysis - Giffords Law Center Data
# 
# =======================================================================


# Check distribution of Giffords Law Score (letter grade converted to numeric 0 to 4)
giff_grd_df %>%
  ggplot(aes(x = law_score)) +
  geom_histogram() +
  scale_x_reverse() +
  facet_grid(. ~ year) +
  ylab("States (n)") +
  xlab("Giffords Gun Law Grade (GPA Scale)") +
  labs(title = "Distribution of Giffords Gun Law Grades", subtitle = "GPA Scale: 4 = A, 0 = F")
  
# Distribution is heavily left skewed with half of all states receiving a score of 0 or F.


# Check summary statistics by year
giff_grd_df %>%
  group_by(year) %>%
  summarize(N = n(), Min = min(law_score), Max = max(law_score), AvgScore = mean(law_score), 
            Median = median(law_score), IQR = IQR(law_score), SD = sd(law_score))
# Zero scores clearly dominate distribution statistics w/ two median scores of 0

# Add geographical data layer w/ state labels to plot, y-axis = death_rnk
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  filter(reg_code >= 0) %>%
  ggplot(aes(x = law_grd, y = death_rnk, label = usps_st, color = region)) +
  geom_text() +
  facet_grid(. ~ year) +
  labs(color = "Region") +
  ylab("State Gun Death Rank") +
  xlab("Giffords Gun Law Grade") +
  labs(title = "Giffords Gun Law Grades Plotted by Gun Death Rank", subtitle = "Rank: 1 = Best, 50 = Worst")

# Modified histogram highlights F scores and worse Death Rank dominated by South and West.
# Of the 20 worst death rankings, between 18 and 20 had a law grade of F over three years.

# Check summary statistics by year, adding region
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region, year) %>%
  summarize(N = n(), Min = min(law_score), Max = max(law_score), AvgScore = mean(law_score),
            Median = median(law_score), IQR = IQR(law_score), SD = sd(law_score))
# Northeast displays greatest variation of scores by SD/IQR and highest median score by far.
# Midwest shows least variation among scores by SD and a non-zero median.
# South also exhibits minimal variation, in spite of largest N value, but at much lower scores.
# West displays greater variation and a steadily rising mean score.

# Check internal correlation between Giffords Law Rank and Death Rank
# Source death rank reversed to maintain same good -> bad scale
giff_grd_df %>%
  ggplot(aes(x = law_rnk, y = death_rnk)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE) +
  ylab("State Gun Death Rank") +
  xlab("State Gun Law Rank") +
  labs(title = "Giffords Gun Death Rank by Gun Law Rank", subtitle = "1 = Best, 50 = Worst") +
  labs(caption = "Based upon Giffords Law Center ratings for 2014-2016")

# Scatterplot suggest significant correlation between law rank and death rank.

# Calculate r2
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  summarize(N = n(), r2 = cor(law_rnk, death_rnk)^2)

# Calculated r2 of 0.555 supports moderate-strong relationship.


# Add geographical labeling element to identify outliers, facet by year
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = death_rnk, label = usps_st, color = region)) +
  facet_wrap(~ year) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE) +
  labs(color = "Region") +
  ylab("State Gun Death Rank") +
  xlab("State Gun Law Rank") +
  labs(title = "Giffords Gun Death Rank by Gun Law Rank", 
       subtitle = "1 = Best, 50 = Worst, Regional Regression Lines")

# Clear distinction between regions jumps out from regression lines. 


# Add regional facet to view correlation across regions
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = death_rnk, label = usps_st, color = region)) +
  facet_grid(year ~ region) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE) +
  labs(color = "Region") +
  ylab("State Gun Death Rank") +
  xlab("State Gun Law Rank") +
  labs(title = "Giffords Regional Gun Death Rank by Gun Law Rank", 
       subtitle = "1 = Best, 50 = Worst") +
  theme(legend.position = "none")

# Added regional facet increases readability and clearly highlights regional distinctions.


giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), r2 = cor(law_rnk, death_rnk)^2)

# Calculated r2 indicates stronger correlation for South (0.525) and West (0.744)
# and weaker relationship for Northeast (0.327) and Midwest (0.338).
# This suggests regional factors are influencing the relationship.


# =======================================================================
# 
# Statistical Analysis - Ranking Data: Guns & Ammo vs Giffords Law Center
# 
# =======================================================================

# Check relationship between Guns & Ammo Rank and Giffords Death Rank
gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = death_rnk, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(color = "Region") +
  ylab("Giffords Gun Death Rank") +
  xlab("Guns & Ammo Best States Rank") +
  labs(title = "Guns & Ammo: Best States for Gun Owners by Gun Death Rank", 
       subtitle = "1 = Best, 50 = Worst") +
  labs(caption = "Based on 2015 rankings from Guns & Ammo and Giffords Law Center") +
  theme(legend.position = "right")

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  summarize(N = n(), r2 = cor(death_rnk, gun_ammo_rnk)^2)

# r2 = 0.409 indicating modearate but still significant negative relationship
# between Guns & Ammo ranking of Best States for Gun Owners and the Giffords
# death rank.


# =======================================================================
# 
# Statistical Analysis - CDC Firearm Homicide & Suicide Data
# 
# =======================================================================

# Run basic stats on CDC Homicide and Suicide Rates

# Statistical summary for Homicide rates
gun_deaths_df %>%
  ungroup(state) %>%
  summarize(N = n(), Min = min(hom_rate), Max = max(hom_rate), AvgScore = mean(hom_rate), 
            Median = median(hom_rate), IQR = IQR(hom_rate), SD = sd(hom_rate))
# Max of 30.7 stems from exceedingly high DC rates noted on import, will filter
# out DC for boxplots below to avoid excessive skewing of y-axis

# Add regional grouping
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(hom_rate), Max = max(hom_rate), AvgScore = mean(hom_rate), 
            Median = median(hom_rate), IQR = IQR(hom_rate), SD = sd(hom_rate))

# Statistical summary for Firearm Suicide rates
gun_deaths_df %>%
  ungroup(state) %>%
  summarize(N = n(), Min = min(sui_rate), Max = max(sui_rate), AvgScore = mean(sui_rate), 
            Median = median(sui_rate), IQR = IQR(sui_rate), SD = sd(sui_rate))

# Add regional grouping
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(sui_rate), Max = max(sui_rate), AvgScore = mean(sui_rate), 
            Median = median(sui_rate), IQR = IQR(sui_rate), SD = sd(sui_rate))

# Check out same data for ALL suicide methods
all_suicides_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(all_sui_rate), Max = max(all_sui_rate), AvgScore = mean(all_sui_rate), 
            Median = median(all_sui_rate), IQR = IQR(all_sui_rate), SD = sd(all_sui_rate))


# =============================================================================
# 
# IMPORTANT: Need to determine if firearm rate is related to higher TOTAL suicide rates.
# 
# =============================================================================


# Create new suicide method table and calculate pct of suicides by gun
sui_method_df <- all_suicides_df %>%
  left_join(gun_deaths_df, by = join_key) %>%
  select(state, year, pop, all_cnt = all_sui_cnt, all_rate = all_sui_rate, gun_cnt = sui_cnt, gun_rate = sui_rate) %>%
  mutate(gun_pct = gun_cnt/all_cnt, other_cnt = all_cnt - gun_cnt, other_rate = other_cnt/all_cnt)

head(sui_method_df)
summary(sui_method_df)

# Plot overall suicide rates by subregion
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = as.factor(subreg_code), y = all_rate, color = subregion)) +
  geom_boxplot()

# Plot Firearm Suicide Percentage by subregion
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = as.factor(subreg_code), y = gun_pct, color = subregion)) +
  geom_boxplot()

# Percentage of suicides by gun does not seem to align w/ overall suicide rate

# Try plotting Firearm Suicide Rate against Overall Suicide Rate
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_rate, y = all_rate, color = subregion)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE, color = "blue") 

# Aha!

# Check r2 for above plot
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  summarize(N = n(), r2 = cor(all_rate, gun_rate)^2)
# r2 = 0.826, very strong relationship as shown in plot

# Check same relationship broken out by subregion
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_rate, y = all_rate, color = subregion)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ subregion)


# Check r2 for above plot
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(subregion) %>%
  summarize(N = n(), r2 = cor(all_rate, gun_rate)^2)
# r2 = 0.720 to 0.895, very strong relationship holds across subregions

# Calculate Average Total Suicide Rate for use below
sui_method_df %>%
  filter(year == 2016) %>%
  summarize(avg_all_rate = mean(all_rate))

# Breaking out Above Average Total Suicide Rate and Giffords Gun Law Grade of F,
# plotting gun_rate & other_rate as stacked horizontal bars (2016 only)
sui_method_df %>%
  filter(year == 2016) %>%
  mutate(other_rate = all_rate - gun_rate, Abv_Average_Rate = all_rate > mean(all_rate)) %>%
  gather(key = "cause", value = "rate", c(other_rate, gun_rate))  %>%
  left_join(regions_df, value = "state") %>%
  inner_join(giff_grd_df, by = join_key) %>%
  mutate(Giffords_F = law_score == 0) %>%
    ggplot(aes(x = usps_st, y = rate, fill = cause)) +
    facet_grid(Giffords_F ~ Abv_Average_Rate, labeller = label_both, scales = "free_y") +
    geom_col() +
    geom_hline(linetype = 2, aes(yintercept = mean(all_rate))) +
    coord_flip() +
    labs(fill = "Suicide Rate") +
    ylab("Suicide Rate") +
    xlab("State") +
    labs(title = "Overall Suicide Rates and States Scoring F on Giffords Gun Law Grade", 
         subtitle = "True/False Panels: Above Average Suicide Rate and Giffords Grade of F, Dashed Line Indicates Average") +
    labs(caption = "Giffords Law Center & Centers for Disease Control Data for 2016") +
    theme(legend.position = "right")


# Create table for count of results from above
sui_method_df %>%
  filter(year == 2016) %>%
  mutate(other_rate = all_rate - gun_rate, Abv_Average_Rate = all_rate > mean(all_rate)) %>%
  inner_join(giff_grd_df, by = join_key) %>%
  mutate(Giffords_F = law_score == 0) %>%
  select(Giffords_F, Abv_Average_Rate) %>%
  table()
# Out of 50 states, 41 Abv Avg Suicide ratings were indicated correctly by Gifford F


# Check r2 for above plot
sui_method_df %>%
  filter(year == 2016) %>%
  mutate(other_rate = all_rate - gun_rate, Abv_Average_Rate = all_rate > mean(all_rate)) %>%
  inner_join(giff_grd_df, by = join_key) %>%
  mutate(Giffords_F = law_score == 0) %>%
  select(Giffords_F, Abv_Average_Rate) %>%
  summarize(N = n(), r2 = cor(Giffords_F, Abv_Average_Rate)^2)
# r2 = 0.410 indicates moderate relationship between Giffords F and total suicide rate


sui_method_df %>%
  group_by(year) %>%
  mutate(abv_avg_rate = all_rate > mean(all_rate)) %>%
  group_by(abv_avg_rate) %>%
  summarise(n = n(), deaths = sum(all_cnt), avg_gun_pct = mean(gun_pct))
# Since 1999, guns accounted for an average 58% of suicides in states with above average suicide
# rates and 48% of suicides in states with below average rates (average rates calculated annually).


# Check Overall Suicide Rates against Gun Ownership Rates
sui_method_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = all_rate)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE)

# Check strength of correlation
sui_method_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  summarize(N = n(), r2 = cor(all_rate, own_rate)^2)
# r2 = 0.399 suggesting significant relationship

# Add geograpical dimension
sui_method_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = all_rate, color = subregion, label = usps_st)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ subregion) +
  theme(legend.position = "right")

# ==================================================================

# Check regional distribution of CDC Firearm Suicide rates
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = region, y = sui_rate, color = region, label = usps_st)) +
  geom_boxplot() +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("Region") +
  labs(title = "Firearm Suicide Rates by Region", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "none")

# Same plot for CDC Firearm Homicide rates
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  ggplot(aes(x = region, y = hom_rate, color = region, label = usps_st)) +
  geom_boxplot() +
  labs(color = "Region") +
  ylab("CDC Firearm Homicide Rate") +
  xlab("Region") +
  labs(title = "Firearm Homicide Rates by Region", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "none")

# Run G&A Rank against CDC Firearm Homicide Rate
gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = hom_rate, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(color = "Region") +
  ylab("CDC Firearm Homicide Rate") +
  xlab("Guns & Ammo Best States Rank") +
  labs(title = "Guns & Ammo: Best States for Gun Owners by CDC Firearm Homicide Rate", 
       subtitle = "Rank: 1 = Best, 50 = Worst, Rate: Deaths per 100,000 Population") +
  labs(caption = "Based on 2015 data from Guns & Ammo and Centers for Disease Control") +
  theme(legend.position = "right")

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  summarize(N = n(), r2 = cor(hom_rate, gun_ammo_rnk)^2)

# No apparent correlation between G&A rank and firearm homicide rate, r2 of 0.059

# Run G&A Rank against CDC Firearm Suicide Rates
gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = sui_rate, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE, colour = "blue") +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("Guns & Ammo Best States Rank") +
  labs(title = "Guns & Ammo: Best States for Gun Owners by CDC Firearm Suicide Rate", 
       subtitle = "Rank: 1 = Best, 50 = Worst, Rate: Deaths per 100,000 Population") +
  labs(caption = "Based on 2015 data from Guns & Ammo and Centers for Disease Control") +
  theme(legend.position = "right")

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  summarize(N = n(), r2 = cor(sui_rate, gun_ammo_rnk)^2)
# r2 = 0.466

# Significant correlation between G&A rank and firearm suicide rate, r2 of 0.466

# Add regional facet to investigate geographical influences
gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = sui_rate, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE) +
  facet_grid(. ~ region) +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("Guns & Ammo Best States Rank") +
  labs(title = "Guns & Ammo: Best States for Gun Owners by CDC Firearm Suicide Rate", 
       subtitle = "Rank: 1 = Best, 50 = Worst, Rate: Deaths per 100,000 Population") +
  labs(caption = "Based on 2015 data from Guns & Ammo and Centers for Disease Control") +
  theme(legend.position = "none")

# Sharp regional contrasts emerge once more


# Run same graph as above but between Gifford Law Rank and Suicide Rate
giff_grd_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = sui_rate, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE) +
  facet_grid(. ~ region) +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("Giffords Gun Law Rank") +
  labs(title = "Giffords Gun Law Rank by CDC Firearm Suicide Rate", 
       subtitle = "Rank: 1 = Best, 50 = Worst, Rate: Deaths per 100,000 Population") +
  labs(caption = "Based on 2015 data from Giffords Law Center and Centers for Disease Control") +
  theme(legend.position = "none")

giff_grd_df %>%
  filter(year == 2015) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  summarize(N = n(), r2 = cor(sui_rate, law_rnk)^2)
# r2 = 0.616

# =======================================================================
# 
# Statistical Analysis - Gun Ownership Rates
# 
# =======================================================================

# Run general statistical summary
gun_own_2013_df %>%
  summarize(N = n(), Min = min(own_rate), Max = max(own_rate), AvgScore = mean(own_rate), 
            Median = median(own_rate), IQR = IQR(own_rate), SD = sd(own_rate))

# AVerage ownership rate of 33% ranging from 5% to 61.7%

# Add geographical layer to check ownership rate by region
gun_own_2013_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(own_rate), Max = max(own_rate), AvgScore = mean(own_rate), 
            Median = median(own_rate), IQR = IQR(own_rate), SD = sd(own_rate))
  
# Below average rates in Northeast, above average in West and South - regional dynamic again.

# Display regional difference w/ boxplots
gun_own_2013_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = region, y = own_rate, color = region, label = usps_st)) +
  geom_boxplot() +
  geom_text(position = "jitter") +
  labs(color = "Region") +
  ylab("Gun Ownership Rate") +
  xlab("Region") +
  labs(title = "Gun Ownership Rates by Region", 
       subtitle = "Ownership Rates for 2013") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "none")

# Boxplot displays regional differences and outliers w/in regions

# Ownership rates only available for 2013, will compare to Giffords 2014
giff_grd_df %>%
  filter(year == 2014) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = law_rnk, label = usps_st, color = region)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE, colour = "blue") +
  labs(color = "Region") +
  ylab("Giffords Gun Law Rank (2014)") +
  xlab("Gun Ownership Rate (2013)") +
  labs(title = "Ownership Rates by Giffords Gun Law Rank", 
       subtitle = "Ownership Rates for 2013, Rank: 1 = Best, 50 = Worst") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "bottom")

giff_grd_df %>%
  filter(year == 2014) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  summarize(N = n(), r2 = cor(own_rate, law_rnk)^2)

# Moderate negative relationship between Gifford Law Rank and Ownership Rate
# with an r2 of 0.393

# Run ownership rate against suicide rate for 2013
gun_deaths_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = sui_rate, label = usps_st, color = region)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate (2013)") +
  xlab("Gun Ownership Rate") +
  labs(title = "Firearm Suicide Rates by Gun Ownership Rates", 
       subtitle = "Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "bottom")

gun_deaths_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  ungroup(state) %>%                                 # Don't know why needed to ungroup, but it worked?
  summarize(N = n(), r2 = cor(own_rate, sui_rate)^2)

# r2 of 0.547 indicates solid relationship between suicide rate and gun ownership 

# Add regional facet to highlights differences in ownership and suicide rates
gun_deaths_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = sui_rate, label = usps_st, color = region)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE) +
  facet_grid(. ~ region)  +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate (2013)") +
  xlab("Gun Ownership Rate") +
  labs(title = "Regional Firearm Suicide Rates by Gun Ownership Rates", 
       subtitle = "Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "none")


# =======================================================================
# 
# Statistical Analysis - BU Public Health State Firearm Law Data
# 
# =======================================================================



