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
# Deciding to create separate variable for each to test
mach_data_df <- mach_data_df %>%
  mutate(reg_west = reg_code == 4,
         reg_neast = reg_code == 1,
         reg_midw = reg_code == 2,
         reg_south = reg_code == 3)

# Factor in national suicide rate to adjust for rise since 2008
nat_suicides <- sui_method_df %>%
  group_by(year) %>%
  summarise(nat_pop = sum(pop), nat_sui_all = sum(all_cnt), 
            nat_rate = nat_sui_all/nat_pop * 100000)

mach_data_df <- mach_data_df %>%
  left_join(nat_suicides, by = "year") %>%
  select(-nat_pop, -nat_sui_all)
  

View(mach_data_df)


# Split into train & test data sets at 70/30 ratio
gp <- runif(nrow(mach_data_df))
train_df <- mach_data_df[gp < 0.50, ]
test_df <- mach_data_df[gp >= 0.50, ]
dim(train_df)
dim(test_df)

# Play with 2013 as train and balance as test
train_df <- mach_data_df %>% filter(year == 2013)
test_df <- mach_data_df %>% filter(year != 2013)


# Run correlation matrix on prospective variables
train_df[ , 8:ncol(train_df)] %>%
  cor()

# Check single variable linear models
mod1 <- lm(gun_rate ~ pop_density, train_df)
summary(mod1)

# Run multi-variate linear model
mod2 <- lm(gun_rate ~ own_rate + buy_reg + reg_west + nat_rate, train_df)
summary(mod2)

summary(augment(mod2))
confint(mod2)
anova(mod2)

# Residual & Q-Q Plot code from linear regression exercise
par(mar = c(4, 4, 2, 2), mfrow = c(1, 2)) #optional
plot(mod2, which = c(1, 2)) # "which" argument optional

# Checking outliers - MN-2013, WY-2013, AK-2013
train_df[c(2, 50, 23), ]

# Run model against test data and check correlation
test2 <- lm(mod2, test_df)
summary(test2)
confint(test2)
anova(test2)

test_pred <- data_frame(predict(mod2, test_df))
cor(test_pred, test_df$gun_rate)^2

# Residual & Q-Q Plot
plot(test2, which = c(1, 2))

# Checking outliers - WY-2012, WY-2002, AK-2008
test_df[c(847, 837, 27), ]


# Review test results and check for high leverage and large residual
test_results <- augment(test2)
head(test_results)
summary(test_results)
test_results %>%
  select(.hat) %>%
  arrange(desc(.hat)) %>%
  top_n(10)

test_results %>%
  filter(.cooksd > .03 | .hat > .05 | .se.fit > .3 | abs(.std.resid) > 3)



