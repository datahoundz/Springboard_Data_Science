library(xml2)
library(readxl)
library(readr)
library(tidyr)
library(dplyr)
library(purrr)
library(ggplot2)
library(directlabels)
library(lubridate)
library(broom)
library(scales)

# Set options to limit sci notation and decimal places
options(scipen = 999, digits = 3)


# =======================================================================
# 
# Statistical Analysis - CDC Firearm Homicide & Suicide Data
# 
# =======================================================================

# Run basic stats on CDC Homicide and Suicide Rates

# Plot total numbers of firearm suicides & homicides to highlight problem at start
gun_deaths_df %>%
  group_by(year) %>%
  summarise(Homicide = sum(hom_cnt), Suicide = sum(sui_cnt)) %>%
  gather(key = "Firearm_Death", value = "Deaths", c(Homicide, Suicide)) %>%
  ggplot(aes(x = year, y = Deaths, color = Firearm_Death)) +
  geom_line(size = 1.5) +
  expand_limits(y = 0) +
  scale_y_continuous(labels = comma) +
  ylab("Annual CDC Firearm Fatality Totals") +
  xlab("Year") +
  labs(color = "Firearm Deaths") +
  labs(title = "CDC Annual Firearm Deaths, Homicide vs Suicide", 
       subtitle = "National Totals 1999-2016") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "right")

# Statistical summary for Homicide rates
gun_deaths_df %>%
  ungroup(state) %>%
  summarize(N = n(), Min = min(hom_rate), Max = max(hom_rate), Avg = mean(hom_rate), 
            Median = median(hom_rate), IQR = IQR(hom_rate), SD = sd(hom_rate))
# Max of 30.7 stems from exceedingly high DC rates noted on import, will filter
# out DC for boxplots below to avoid excessive skewing of y-axis

# Add regional grouping
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(hom_rate), Max = max(hom_rate), Avg = mean(hom_rate), 
            Median = median(hom_rate), IQR = IQR(hom_rate), SD = sd(hom_rate))

# Statistical summary for Firearm Suicide rates
gun_deaths_df %>%
  ungroup(state) %>%
  summarize(N = n(), Min = min(sui_rate), Max = max(sui_rate), Avg = mean(sui_rate), 
            Median = median(sui_rate), IQR = IQR(sui_rate), SD = sd(sui_rate))

# Add regional grouping
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(sui_rate), Max = max(sui_rate), Avg = mean(sui_rate), 
            Median = median(sui_rate), IQR = IQR(sui_rate), SD = sd(sui_rate))

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

# Run correlation on Homicide vs Suicide relationship
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  ungroup(state) %>%
  summarize(N = n(), r2 = cor(sui_rate, hom_rate)^2)
# At r2 of 0.0168, close to zero relationship between homicide and suicide

# Plot Suicide Rate by Homicide Rate with two-letter state, colored by region 
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  ggplot(aes(x = hom_rate, y = sui_rate, color = region, label = usps_st)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("CDC Firearm Homicide Rate") +
  labs(title = "Firearm Suicide Rates by Firearm Homicide Rates", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016; DC excluded to avoid skewing of scale.") +
  theme(legend.position = "right")

# Check state rates of suicides - rates homicides, assess greater risk
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  group_by(region, usps_st) %>%
  summarise(Avg_Suicide_Rate = mean(sui_rate), Avg_Homicide_Rate = mean(hom_rate),
            Suicide_Homicide_Diff = Avg_Suicide_Rate - Avg_Homicide_Rate) %>%
  arrange(desc(Suicide_Homicide_Diff), desc(usps_st)) %>%
  select(region, usps_st, Suicide_Homicide_Diff) %>%
  ggplot(aes(x = reorder(usps_st, -Suicide_Homicide_Diff), y = Suicide_Homicide_Diff, fill = region)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  facet_wrap(~ region, scales = "free_y") +
  labs(color = "Region") +
  ylab("Avg Firearm Suicide Rate Minus Avg Firearm Homicide Rate") +
  xlab("State") +
  labs(title = "Assessing the Greater Gun Threat: Firearm Suicides vs Firearm Homicides", 
       subtitle = "Bars Indicate Amount by which Suicide Rate Exceeds Homicide Rate") +
  labs(caption = "Centers for Disease Control Data for 1999-2016; DC excluded to avoid skewing of scale.") +
  theme(legend.position = "none")
# Firearm homicide rates exceed firearm suicide rates in only 6 of 50 states

# Turn focus to suicide only

# Check summary data for ALL suicide methods
all_suicides_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(all_sui_rate), Max = max(all_sui_rate), Avg = mean(all_sui_rate), 
            Median = median(all_sui_rate), IQR = IQR(all_sui_rate), SD = sd(all_sui_rate))

# Compare to FIREARM suicide summary from above
# Add regional grouping
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(sui_rate), Max = max(sui_rate), Avg = mean(sui_rate), 
            Median = median(sui_rate), IQR = IQR(sui_rate), SD = sd(sui_rate))

# Average firearm and overall suicide seem to scale together


# =============================================================================
# 
# Need to determine if firearm rate is related to higher TOTAL suicide rates.
# Assuming reduced firearm accessibility leads to lower overall suicide rate.
# 
# =============================================================================

# Create new suicide method table and calculate pct of suicides by gun
sui_method_df <-  all_suicides_df %>%
  left_join(gun_deaths_df, by = join_key) %>%
  select(state, year, pop, all_cnt = all_sui_cnt, all_rate = all_sui_rate, gun_cnt = sui_cnt, gun_rate = sui_rate) %>%
  mutate(gun_pct = gun_cnt/all_cnt, other_cnt = all_cnt - gun_cnt, other_rate = all_rate - gun_rate)
summary(sui_method_df)
# Table reveals wildly disparate data across all categories. Investigate on subregion level per indications from plot above.

head(sui_method_df)
summary(sui_method_df)
class(sui_method_df)
class(regions_df)

# Plot displaying overall suicide rate trend nationally
sui_method_df %>%
  group_by(year) %>%
  summarize(all_rate = weighted.mean(all_rate, pop)) %>%
  ggplot(aes(x = year, y = all_rate)) +
  geom_line(size = 1) +
  expand_limits(y = 0)


# Plot overall suicide rates by subregion
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(subregion, year) %>%
  summarise(all_rate = sum(all_cnt)/sum(pop) * 100000,
            gun_rate = sum(gun_cnt)/sum(pop) * 100000,
            other_rate = sum(other_cnt)/sum(pop) * 100000) %>%
  ggplot(aes(x = subregion, y = all_rate, fill = subregion)) +
  geom_boxplot() +
  labs(fill = "Subregion") +
  ylab("CDC Overall Suicide Rate") +
  xlab("Year") +
  labs(title = "Subregional Suicide Rates ALL Methods", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "right") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
# Coastal states have lower overall suicide rates, with the mountain region much higher
# which may be the result of significantly lower overall population levels.

pop_labels <- c(
      '1' = "Low Population",
      '2' = "Moderate Low Population",
      '3' = "Moderate High Population",
      '4' = "High Population"
)

# Run subregion overall suicide boxplots grouped by population quantiles to check for population effect.
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(subregion, usps_st, year) %>%
  summarise(all_rate = sum(all_cnt)/sum(pop) * 100000,
            gun_rate = sum(gun_cnt)/sum(pop) * 100000,
            other_rate = sum(other_cnt)/sum(pop) * 100000,
            avg_suicides = mean(all_cnt),
            avg_pop = mean(pop)) %>%
  ggplot(aes(x = reorder(usps_st, -all_rate), y = all_rate, fill = subregion)) +
  geom_boxplot() +
  facet_wrap(~ ntile(avg_pop, 4), scales = "free_x", labeller = as_labeller(pop_labels)) +
  labs(fill = "Subregion") +
  ylab("CDC Overall Suicide Rate") +
  xlab("State") +
  labs(title = "Overall Suicide Rates by State Grouped by Population Quantile", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "right")

# Plot firearm vs other using line plot over time
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(subregion, year) %>%
  summarise(all_rate = sum(all_cnt)/sum(pop) * 100000,
            gun_rate = sum(gun_cnt)/sum(pop) * 100000,
            other_rate = sum(other_cnt)/sum(pop) * 100000) %>%
  gather(key = "Method", value = "rate", c(other_rate, gun_rate))  %>%
    ggplot(aes(x = year, y = rate, color = Method)) +
    geom_line(size = 1) +
    facet_wrap(~ subregion) +
    expand_limits(y = 0) +
    ylab("CDC Suicide Rates, Firearm & Other") +
    xlab("Year") +
    labs(title = "Regional Suicide Rates by Firearm vs Other Methods", 
         subtitle = "Rate: Deaths per 100,000 Population") +
    labs(caption = "Centers for Disease Control Data for 1999-2016") +
    theme(legend.position = "right")
# Time series plot of suicides broken out by firearm/other indicates major regional differences
# Coastal states exhibit much lower firearm rates.

# Run same plot as above but with many-mini view of each state
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(state, year) %>%
  summarise(all_rate = sum(all_cnt)/sum(pop) * 100000,
            gun_rate = sum(gun_cnt)/sum(pop) * 100000,
            other_rate = sum(other_cnt)/sum(pop) * 100000) %>%
  gather(key = "Method", value = "rate", c(other_rate, gun_rate))  %>%
  ggplot(aes(x = year, y = rate, color = Method)) +
  geom_line(size = 1) +
  facet_wrap(~ state) +
  ylab("CDC Suicide Rates, Firearm & Other") +
  xlab("Year") +
  labs(title = "State Level Suicide Rates by Firearm vs Other Methods", 
       subtitle = "Rate: Deaths per 100,000 Population, 1999-2016") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "bottom") +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank())
# Nicely displays variation by state with small pop variations jumping out


# Try plotting Firearm Suicide Rate against Other Suicide Rate
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_rate, y = other_rate, color = region)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  ylab("CDC Suicide Rate, Other Methods") +
  xlab("CDC Suicide Rate, Firearm") +
  labs(title = "Suicide Rates by Firearm vs Other Methods", 
       subtitle = "Rate: Deaths per 100,000 Population, 1999-2016") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "right")

# Check r2 for above plot
sui_method_df %>%
  left_join(regions_df, by = "state") %>%
  summarize(N = n(), r2 = cor(other_rate, gun_rate)^2)
# r2 = 0.077, very weak relationship as shown in plot

# Check firearm share of suicides in states w/ above average suicide rates
sui_method_df %>%
  group_by(year) %>%
  mutate(abv_avg_rate = all_rate > mean(all_rate)) %>%
  group_by(abv_avg_rate) %>%
  summarise(n = n(), deaths = sum(all_cnt), avg_gun_pct = mean(gun_pct))
# Since 1999, guns accounted for an average 58% of suicides in states with above average suicide
# rates and 48% of suicides in states with below average rates (average rates calculated annually).

# Try to plot this relationship???
sui_method_df %>%
  group_by(year) %>%
  mutate(Above_Average_Suicide_Rate = all_rate > mean(all_rate)) %>%
  group_by(year, Above_Average_Suicide_Rate) %>%
  summarise(n = n(), deaths = sum(all_cnt), avg_gun_pct = mean(gun_pct)) %>%
  ggplot(aes(x = year, y = avg_gun_pct, fill = Above_Average_Suicide_Rate)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ifelse(Above_Average_Suicide_Rate, "Above Average Suicide Rate", "Below Average Suicide Rate")) +
  ylab("Percentage of Suicides Using Firearm") +
  xlab("Year") +
  labs(title = "Percentage of Deaths by Firearm, Partition States by Above/Below Average Overall Suicide Rates", 
       subtitle = "Rate: Deaths per 100,000 Population") +
  labs(caption = "Centers for Disease Control Data for 1999-2016") +
  theme(legend.position = "none")
# Higher suicide rate states average 10 pct point greater use of firearm as instrument of mortality

# Data table for above plot
sui_method_df %>%
  group_by(year) %>%
  mutate(Above_Average_Suicide_Rate = all_rate > mean(all_rate)) %>%
  group_by(year, Above_Average_Suicide_Rate) %>%
  summarise(n = n(), deaths = sum(all_cnt), avg_gun_pct = mean(gun_pct))


# =======================================================================
# 
# Statistical Analysis - Gun Ownership Rates
# 
# =======================================================================

# Run general statistical summary
gun_own_2013_df %>%
  summarize(N = n(), Min = min(own_rate), Max = max(own_rate), Avg = mean(own_rate), 
            Median = median(own_rate), IQR = IQR(own_rate), SD = sd(own_rate))

# Average ownership rate of 33% ranging from 5% to 61.7%

# Add geographical layer to check ownership rate by region
gun_own_2013_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(subregion) %>%
  summarize(N = n(), Min = min(own_rate), Max = max(own_rate), Avg = mean(own_rate), 
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
       subtitle = "Household Gun Ownership Rates for 2013") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "none")

# Boxplot displays regional differences and outliers w/in regions

# =======================================================================
# 
# Statistical Analysis - Gun Ownership Rates vs CDC Suicide Rates
# 
# =======================================================================

# Check OVERALL Suicide Rates against Gun Ownership Rates
sui_method_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = own_rate, y = all_rate, color = region, label = usps_st)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(color = "Region") +
  ylab("CDC Overall Suicide Rate (2013)") +
  xlab("Gun Ownership Rate") +
  labs(title = "Overall Suicide Rates by Gun Ownership Rates", 
       subtitle = "Household Gun Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "bottom")

# Check strength of correlation to OVERALL Suicide Rate
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
  ggplot(aes(x = own_rate, y = all_rate, color = region, label = usps_st)) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE) +
  facet_grid(. ~ region) +
  theme(legend.position = "none") +
  labs(color = "Region") +
  ylab("CDC Overall Suicide Rate (2013)") +
  xlab("Gun Ownership Rate") +
  labs(title = "Regional Overall Suicide Rates by Gun Ownership Rates", 
       subtitle = "Household Gun Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "none")

# Check strength of regional correlation to OVERALL Suicide Rate
sui_method_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), r2 = cor(all_rate, own_rate)^2)
# r2 = 0.289 in NE to 0.441 in West suggesting moderate but significant relationship

# Run ownership rate against FIREARM suicide rate for 2013
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
       subtitle = "Household Gun Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
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
       subtitle = "Household Gun Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "none")

gun_deaths_df %>%
  filter(year == 2013) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), r2 = cor(own_rate, sui_rate)^2)
# r2 ranges from 0.360 in Midwest to 0.487 in South, lack of data a problem 


own_rate_labels <- c(
    '1' = "Low",
    '2' = "Medium",
    '3' = "High"
)

# Firearm suicide rates grouped by ownership rate
gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  filter(year == 2013) %>%
  inner_join(gun_own_2013_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  ggplot(aes(x = reorder(usps_st, -sui_rate), y = sui_rate, fill = region)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  facet_grid(. ~ ntile(own_rate, 3), labeller = as_labeller(own_rate_labels)) +
  labs(fill = "Region") +
  ylab("CDC Firearm Suicide Rate (2013)") +
  xlab("State") +
  labs(title = "States Ranked by Firearm Suicide Rate, Grouped by Gun Ownership Tier", 
       subtitle = "Tier 1 = Low, Tier 2 = Med, Tier 3 = High, Household Gun Ownership Rates for 2013, CDC Rate: Deaths per 100,000 Population") +
  labs(caption = "Data cited by Kalesan B, Villarreal MD, Keyes KM, et al Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") +
  theme(legend.position = "bottom")
# Plot supports strong connection between gun ownership rates and higher firearm suicide levels 


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
  labs(title = "Distribution of Giffords Gun Law Grades", subtitle = "GPA Scale: 4 = A, 0 = F") +
  labs(caption = "Giffords Law Center Data for 2014-2016")
  
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
  labs(title = "Giffords Gun Law Grades Plotted by Gun Death Rank", subtitle = "Rank: 1 = Best, 50 = Worst") +
  labs(caption = "Giffords Law Center Data for 2014-2016")

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
       subtitle = "1 = Best, 50 = Worst, Regional Regression Lines") +
  labs(caption = "Giffords Law Center Data for 2014-2016")

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
  theme(legend.position = "none") +
  labs(caption = "Giffords Law Center Data for 2014-2016")

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
# Statistical Analysis - Giffords Law Center Data vs CDC Firearm Suicide Rate
# 
# =======================================================================

# Run same graph as above but between Gifford Law Rank and Suicide Rate
giff_grd_df %>%
  filter(year >= 2014) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = sui_rate, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE) +
  facet_grid(year ~ region) +
  labs(color = "Region") +
  ylab("CDC Firearm Suicide Rate") +
  xlab("Giffords Gun Law Rank") +
  labs(title = "Giffords Gun Law Rank by CDC Firearm Suicide Rate", 
       subtitle = "Rank: 1 = Best, 50 = Worst, Rate: Deaths per 100,000 Population") +
  labs(caption = "Based on 2015 data from Giffords Law Center and Centers for Disease Control") +
  theme(legend.position = "none")

giff_grd_df %>%
  filter(year >= 2014) %>%
  left_join(gun_deaths_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), r2 = cor(sui_rate, law_rnk)^2)
# Overall r2 = 0.594
# Regional r2 in 0.33 range for NE & MW, 0.525 in South and 0.744 in West

# Calculate Average Total Suicide Rate for use below
sui_method_df %>%
  filter(year == 2016) %>%
  summarize(avg_all_rate = mean(all_rate))

# Breaking out Above Average Total Suicide Rate and Giffords Gun Law Grade of F,
# plotting gun_rate & other_rate as stacked horizontal bars (2016 only)
sui_method_df %>%
  filter(year == 2016) %>%
  mutate(Abv_Average_Rate = all_rate > mean(all_rate)) %>%
  gather(key = "cause", value = "rate", c(other_rate, gun_rate))  %>%
  left_join(regions_df, value = "state") %>%
  inner_join(giff_grd_df, by = join_key) %>%
  mutate(Giffords_F = law_score == 0) %>%
    ggplot(aes(x = reorder(usps_st, all_rate), y = rate, fill = cause)) +
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
# Displayed data for 2016. Slightly lower accuracy in 2014 and 2015 at 38/50 each.

# Check r2 for above plot, 2014 to 2016
sui_method_df %>%
  filter(year >= 2014) %>%
  mutate(other_rate = all_rate - gun_rate, Abv_Average_Rate = all_rate > mean(all_rate)) %>%
  inner_join(giff_grd_df, by = join_key) %>%
  mutate(Giffords_F = law_score == 0) %>%
  select(Giffords_F, Abv_Average_Rate) %>%
  summarize(N = n(), r2 = cor(Giffords_F, Abv_Average_Rate)^2)
# r2 = 0.304 indicates some relationship between Giffords F and above average suicide rate


# =======================================================================
# 
# Statistical Analysis - Gun Ownership Rates vs Giffords Law Rankings
# 
# =======================================================================

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


# =======================================================================
# 
# Statistical Analysis - BU Public Health State Firearm Law Data
# 
# =======================================================================

# Check summary stats on lawtotal variable from state law database
state_laws_total_df %>%
  left_join(regions_df, by = "state") %>%
  select(region, year, lawtotal) %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(lawtotal), Max = max(lawtotal), Avg = mean(lawtotal), 
            Median = median(lawtotal), IQR = IQR(lawtotal), SD = sd(lawtotal))
# Very broad range from 3 to 104 w/ average of 24.8 and sd of 23.4

# Plot overal total of laws over time period
state_laws_total_df %>%
  group_by(year) %>%
  select(year, lawtotal) %>%
  summarise(tot_laws = sum(lawtotal)) %>%
  ggplot(aes(x = year, y = tot_laws)) +
  geom_line(size = 1, color = "blue") +
  scale_y_continuous(labels = comma) +
  geom_dl(aes(label = max(tot_laws)), method = list("last.points", cex = 1.5, hjust = 0.5, vjust = -0.25)) +
  geom_dl(aes(label = min(tot_laws)), method = list("first.points", cex = 1.5, hjust = 0.5, vjust = 1)) +
  ylab("Total Gun Laws") +
  xlab("Year") +
  labs(title = "Total Gun Law Counts Nationally, 1999-2016", 
       subtitle = "") +
  labs(caption = "Boston University School of Public Health: State Gun Law Database") +
  theme(legend.position = "bottom")
# Definite regional differences and some regions decreasing gun laws

# Moderate increase of 226 or 20% between 1999 and 2016
# Sharp increases in 2000 and again in 2013/2014

# Add regional layer to above plot
state_laws_total_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region, year) %>%
  select(region, year, lawtotal) %>%
  summarise(tot_laws = sum(lawtotal)) %>%
  ggplot(aes(x = year, y = tot_laws, color = region)) +
  geom_line(size = 1) +
  labs(color = "Year") +
  ylab("Total Gun Laws") +
  xlab("Year") +
  labs(title = "Total Gun Law Counts by Region, 1999-2016", 
       subtitle = "") +
  labs(caption = "Boston University School of Public Health: State Gun Law Database") +
  theme(legend.position = "bottom")
# Definite regional differences and some regions decreasing gun laws

# Calculate region level statistics
state_laws_total_df %>%
  left_join(regions_df, by = "state") %>%
  select(region, year, lawtotal) %>%
  group_by(region) %>%
  summarize(N = n(), Min = min(lawtotal), Max = max(lawtotal), Avg = mean(lawtotal), 
            Median = median(lawtotal), IQR = IQR(lawtotal), SD = sd(lawtotal))

# Run many-mini at state level to investigate shifts
state_laws_total_df %>%
  left_join(regions_df, by = "state") %>%
  group_by(region, state, year) %>%
  select(region, state, year, lawtotal) %>%
  summarise(tot_laws = sum(lawtotal)) %>%
  ggplot(aes(x = year, y = tot_laws, color = region)) +
  geom_line(size = 1) +
  facet_wrap(~ state) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank()) +
  labs(color = "Region") +
  ylab("Total Gun Laws") +
  xlab("Region") +
  labs(title = "Total Gun Law Counts by State, 1999-2016", 
       subtitle = "") +
  labs(caption = "Boston University School of Public Health: State Gun Law Database") +
  theme(legend.position = "bottom")
# Plot allows one to see shifts in gun laws, up or down, by state over time - pretty busy though

# Calculate change in number of laws by state between 1999 and 2016, assign quartile
law_chg_df <- state_laws_total_df %>%
  select(state, year, lawtotal) %>%
  filter(year == 1999 | year == 2016) %>%
  spread(year, lawtotal, sep = "_") %>%
  mutate(law_chg = year_2016 - year_1999, law_quant = ntile(law_chg, 4)) %>%
  arrange(desc(law_chg)) %>%
  print()

# Create facet labels for plots below
law_quant_lbl <- c(
  '1' = "1 - Reduced",
  '2' = "2 - Unchanged",
  '3' = "3 - Small Increase",
  '4' = "4 - Large Increase"
)

# Plot law change counts grouped by quartile
law_chg_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = reorder(usps_st, law_chg), y = law_chg, fill = region)) +
  geom_bar(stat = "identity") +
  geom_hline(data = fsr_law_avg_df, aes(yintercept = Avg_Law_Chg), lty = 2) +
  geom_text(data = fsr_law_avg_df, aes(label = paste("Avg = ", round(Avg_Law_Chg, 2))), 
            x = -Inf, y = fsr_law_avg_df$Avg_Law_Chg, hjust = -0.1, vjust = -0.5, size = 4,
            inherit.aes = FALSE) +
  facet_wrap(~ law_quant, labeller = as_labeller(law_quant_lbl), scales = "free_x") +
  labs(fill = "Region") +
  ylab("Net Change in State Gun Laws") +
  xlab("State") +
  labs(title = "Net Change in Gun Law Counts by State, 1999-2016", 
       subtitle = "Grouped into Quartiles by Net Change") +
  labs(caption = "Boston University School of Public Health: State Gun Law Database") +
  theme(legend.position = "bottom") +
  labs(color = "Region")
# Law Change grouped into four categories: Reduced, Unchanged, Sm Increase, Lg Increase
  

# =======================================================================
# 
# Statistical Analysis - State Firearm Law Data vs CDC Firearm Suicide Rates
# 
# =======================================================================

# Calculate r2 for firearm suicide rates by total laws
cor_law_fsr_all <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(state_laws_total_df, by = join_key) %>%
  summarize(N = n(), r2 = cor(gun_rate, lawtotal)^2) %>%
  print()
# r2 of 0.546 indicates moderate relationship between gun law total and firearm suicide rate

# Plot total laws against firearm suicide rates
sui_method_df %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  filter(usps_st != "DC") %>%
  ggplot(aes(x = lawtotal, y = gun_rate, color = region)) +
  geom_point() +
  geom_text(data = cor_law_fsr_all, aes(label = paste("r2 = ", round(r2, 3))), 
            x = Inf, y = Inf, hjust = 1.1, vjust = 1.5, size = 5, color = "blue",
            inherit.aes = FALSE) +
  stat_smooth(method = "lm", se = FALSE, color = "blue") +
  ylab("Annual CDC Firearm Suicide Rate") +
  xlab("Number of Gun Laws by State") +
  labs(color = "Region") +
  labs(title = "Annual Firearm Suicide Rate by Number of State Gun Laws", 
       subtitle = "Rate: Deaths per 100,000 Population, Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "right")
# Negative relationship with numerous outliers from West at higher suicide rates

# Calculate r2 by region
cor_law_fsr_reg <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  group_by(region) %>%
  summarize(N = n(), r2 = cor(gun_rate, lawtotal)^2) %>%
  print()
# r2 low of 0.371 in South, 0.571 in Midwest, 0.635 in West and 0.715 in Northeast

# Plot by region total laws against firearm suicide rates
sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = lawtotal, y = gun_rate, color = region)) +
  geom_point() +
  facet_wrap(~ region) +
  geom_text(data = cor_law_fsr_reg, aes(label = paste("r2 = ", round(r2, 3))), 
            x = 100, y = 17.5, hjust = 0.75, vjust = -0.25, size = 3.5, color = "blue",
            inherit.aes = FALSE) +
  stat_smooth(method = "lm", se = FALSE) +
  ylab("Annual CDC Firearm Suicide Rate") +
  xlab("Number of Gun Laws by State") +
  labs(color = "Region") +
  labs(title = "Annual Firearm Suicide Rate by Number of State Gun Laws by Region", 
       subtitle = "Rate: Deaths per 100,000 Population, Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "right")
# All regions exhibit negative relationship, more laws -> fewer firearm suicides

# Create Firearm Suicide Rate change 1999-2016 to plot against law change
fsr_chg_df <- sui_method_df %>%
  select(state, yr = year, gun_rate) %>%
  filter(yr == 1999 | yr == 2016) %>%
  spread(yr, gun_rate, sep = "_") %>%
  mutate(fsr_chg = yr_2016 - yr_1999, fsr_quant = ntile(-fsr_chg, 4)) %>%
  arrange(desc(fsr_chg)) %>%
  print()
# Use -fsr_chg so law and fsr quartiles numbers align, low law_chg to high_fsr chg

# Calculate average change in fsr by law change quartile, use as labels for plots below
fsr_law_avg_df <- law_chg_df %>%
  left_join(fsr_chg_df, by = "state") %>%
  group_by(law_quant) %>%
  summarise(N = n(),  Avg_Law_Chg = mean(law_chg), Avg_FSR_Chg = mean(fsr_chg)) %>%
  print()

# Plot change in firearm suicide rate grouped by law change quantiles
fsr_chg_df %>%
  filter(state != "District of Columbia") %>%
  left_join(regions_df, by = "state") %>%
  left_join(law_chg_df, by = "state") %>%
  filter(law_quant %in% c(1, 2, 3, 4)) %>%
  ggplot(aes(x = reorder(usps_st, -fsr_chg), y = fsr_chg, fill = region)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ law_quant, labeller = as_labeller(law_quant_lbl), scale = "free_x") +
  geom_hline(data = fsr_law_avg_df, aes(yintercept = Avg_FSR_Chg), lty = 2) +
  geom_text(data = fsr_law_avg_df, aes(label = paste("Avg = ", round(Avg_FSR_Chg, 2))), 
            x = Inf, y = fsr_law_avg_df$Avg_FSR_Chg, hjust = 1, vjust = -0.5, size = 3.2,
            inherit.aes = FALSE) +
  ylab("Change in CDC Firearm Suicide Rate from 1999 to 2016") +
  xlab("State") +
  labs(fill = "Region") +
  labs(title = "Net Change in Firearm Suicide Rate by Change in State Gun Laws Quartile", 
       subtitle = "Rate: Deaths per 100,000 Population, Quartiles by Change in Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "right")
# States that reduced gun laws saw average FSR increase 5X that of states that increased laws significantly 

# Plot average FSR change by law change quantile
law_chg_df %>%
  left_join(fsr_chg_df) %>%
  group_by(law_quant) %>%
  summarise(N = n(), Avg_Law_Chg = mean(law_chg), Avg_FSR_Chg = mean(fsr_chg)) %>%
  ggplot(aes(x = law_quant_lbl, y = Avg_FSR_Chg, fill = as.factor(round(Avg_Law_Chg)))) +
  geom_bar(stat = "identity") +
  geom_dl(aes(label = paste("+", round(Avg_FSR_Chg, 2), " Deaths/100K")), 
          method = list("last.points", cex = 1, hjust = 0.5, vjust = -0.25)) +
  ylab("Average Change in CDC Firearm Suicide Rate") +
  xlab("Change in Number of Gun Laws") +
  labs(fill = "Avg Law Change") +
  labs(title = "Average Change in Firearm Suicide Rate by State Gun Law Change Quartile", 
       subtitle = "Rate: Deaths per 100,000 Population, Quartiles by Change in Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "bottom")
# Plot exhibits relationship between quantile averages

# Line plot of each quartile over period
sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(law_chg_df, by = "state") %>%
  select(state, year, law_quant, gun_rate) %>%
  group_by(law_quant, year) %>%
  summarize(avg_fsr = mean(gun_rate)) %>%
  ggplot(aes(x = year, y = avg_fsr, color = as.factor(law_quant))) +
  geom_line(size = 1) +
  stat_smooth(method = "lm", se = FALSE, linetype = 2) +
  facet_grid(. ~ as.factor(law_quant), labeller = as_labeller(law_quant_lbl)) +
  ylab("Average CDC Firearm Suicide Rate") +
  xlab("Year") +
  labs(color = "Gun Law Chg") +
  labs(title = "Firearm Suicide Trend Grouped by Changes in State Gun Laws", 
       subtitle = "Rate: Deaths per 100,000 Population, Quartiles by Change in Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "none")


# Plot by state laws against firearm suicide rates - states that reduced laws
sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  left_join(law_chg_df, by = "state") %>%
  filter(law_quant == 1) %>%
  ggplot(aes(x = lawtotal, y = gun_rate, color = -year)) +
  geom_point() +
  facet_wrap(~ state) +
  geom_text(aes(label = paste("Law Change = ", law_chg)), 
            x = 20, y = 17, hjust = 0.6, vjust = 1, size = 3.5, color = "blue",
            inherit.aes = TRUE) +
  stat_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(expand = c(0, 0), limits = c(0,18)) +
  ylab("Annual CDC Firearm Suicide Rate") +
  xlab("Number of Gun Laws by State") +
  labs(color = "Region") +
  labs(title = "Firearm Suicide Rates for States that Reduced Gun Laws", 
       subtitle = "Rate: Deaths per 100,000 Population, Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "right")
# Every state that reduced gun laws experienced an increase in firearm suicides.
# However, it should be noted that overall suicide rates rose from 10.5 to almost 14 per 100,000.

# Plot by state laws against firearm suicide rates - states that significantly increased laws
sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  left_join(law_chg_df, by = "state") %>%
  filter(law_quant == 4) %>%
  ggplot(aes(x = lawtotal, y = gun_rate, color = -year)) +
  geom_point() +
  facet_wrap(~ state) +
  geom_text(aes(label = paste("Law Change = ", law_chg)), 
            x = 75, y = 17, hjust = 0.5, vjust = 1, size = 3.5, color = "blue",
            inherit.aes = TRUE) +
  stat_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(expand = c(0, 0), limits = c(0,18)) +
  ylab("Annual CDC Firearm Suicide Rate") +
  xlab("Number of Gun Laws by State") +
  labs(color = "Region") +
  labs(title = "Firearm Suicide Rates for States that Significantly Increased Gun Laws", 
       subtitle = "Rate: Deaths per 100,000 Population, Number of Laws 1999-2016") +
  labs(caption = "Sources: Boston University School of Public Health, Centers for Disease Control") +
  theme(legend.position = "right")
# Two states, Colorado and Delaware, saw sharp suicide increases in spite of added gun laws.
# A few more expeienced a more modest rise, while others were nearly flat or fell.
# Again, this is all occurring as overal national suicide rates climbed from 10.5 to 14 per 100,000


