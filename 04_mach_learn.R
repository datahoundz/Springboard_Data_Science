# Machine Learning Code


# Structure a table that includes variables of interest for linear regression model

mach_data_df <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(regions_df, by = "state") %>%
  select(state, usps_st, region, reg_code, subregion, subreg_code, year, gun_rate, other_rate, all_rate) %>%
  left_join(laws_cat_df, by = join_key) %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  filter(year >= 1999)

View(mach_data_df)  

mod1 <- lm(gun_rate ~ own_rate, mach_data_df)
summary(mod1)

mod2 <- lm(gun_rate ~ own_rate + buy_reg, mach_data_df)
summary(mod2)
augment(mod2)

mach_data_df[ , 8:26] %>%
  cor()
