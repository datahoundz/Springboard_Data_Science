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
# Statistical Analysis - Guns & Ammo Rank vs Giffords Law, Death Rank
# 
# =======================================================================

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = law_rnk, label = usps_st)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = TRUE)

ga_gf_mod <- gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key)
  
ga_gf_mod1 <- lm(law_rnk ~ gun_ammo_rnk, ga_gf_mod)
summary(ga_gf_mod1) 

gun_ammo_df %>%
  filter(year == 2015) %>%
  left_join(giff_grd_df, by = join_key) %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = gun_ammo_rnk, y = death_rnk, label = usps_st)) +
  geom_text(position = "jitter") +
  stat_smooth(method = "lm", se = FALSE) +
  aes(color = region)

mod2 <- lm(death_rnk ~ gun_ammo_rnk, mod1_df)
summary(mod2) 
