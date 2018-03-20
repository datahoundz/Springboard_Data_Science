# Machine Learning Code


# Structure a table that includes variables of interest for linear regression model

mach_data_df <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(population_df, by = join_key) %>%
  select(-land_area, -pop.y, -pop.x) %>%
  left_join(regions_df, by = "state") %>%
  select(year, state, usps_st, region, subregion, reg_code, subreg_code, gun_rate, other_rate, all_rate, pop_density) %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(laws_cat_df, by = join_key) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  filter(year >= 1999)

# Convert region/subregion to factor for linear regression
mach_data_df$reg_code <- factor(mach_data_df$reg_code)
mach_data_df$subreg_code <- factor(mach_data_df$subreg_code)

# Create variable for reg_west T/F per feedback from initial model
# Deciding to stick with reg_code, though reg_west exhibits predictive value
mach_data_df <- mach_data_df %>%
  mutate(reg_west = reg_code == 4) 


View(mach_data_df)  

# Run correlation matrix on prospective variables
mach_data_df[ , 8:28] %>%
  cor()

# Run single variable linear model
mod1 <- lm(gun_rate ~ own_rate, mach_data_df)
summary(mod1)

# Run multi-variate linear model
mod2 <- lm(gun_rate ~ reg_code + own_rate + buy_reg, mach_data_df)
summary(mod2)

augment(mod2)
confint(mod2)
anova(mod2)

# Residual & Q-Q Plot code from linear regression exercise
par(mar = c(4, 4, 2, 2), mfrow = c(1, 2)) #optional
plot(mod2, which = c(1, 2)) # "which" argument optional

mach_data_df[c(896, 648, 467), ]
