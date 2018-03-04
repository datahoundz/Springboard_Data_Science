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
# Statistical Analysis - Ranking Data: Guns & Ammo vs Giffords Law Center
# 
# =======================================================================


# Check distribution of Giffords Law Score (letter grade converted to numeric 0 to 4)
giff_grd_df %>%
  ggplot(aes(x = law_score)) +
  geom_histogram() +
  facet_grid(. ~ year)

# Distribution is heavily right skewed with half of all states receiving a score of 0 or F.

# Check for movement by adding geographical data layer to plot
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_grd, y = death_rnk, label = usps_st, color = region)) +
  geom_text() +
  facet_grid(. ~ year)

# Check internal correlation between Giffords Law Rank and Death Rank (death rank reversed for same good to bad scale)
giff_grd_df %>%
  ggplot(aes(x = law_rnk, y = death_rnk)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE)

# Add geographical labeling element to identify outliers, facet by year
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = death_rnk, label = usps_st)) +
  facet_wrap(~ year) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE)

# Add regional facet to view correlation in greater detail

# Add geographical labeling element to identify outliers, facet by year
giff_grd_df %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = law_rnk, y = death_rnk, label = usps_st, color = region)) +
  facet_grid(region ~ year) +
  geom_text() +
  stat_smooth(method = "lm", se = FALSE)



gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = law_rnk, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE, colour = "blue")

ga_gf_mod <- gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key)
  
ga_gf_mod1 <- lm(law_rnk ~ gun_ammo_rnk, ga_gf_mod)
summary(ga_gf_mod1) 

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = death_rnk, label = usps_st, color = region)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE, colour = "blue")

mod2 <- lm(death_rnk ~ gun_ammo_rnk, ga_gf_mod)
summary(mod2) 
