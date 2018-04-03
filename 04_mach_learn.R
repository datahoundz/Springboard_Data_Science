# Machine Learning Code

library(ranger)
library(vtreat)


# ==================================================================================
# 
# Structure a table that includes variables of interest for linear regression model
# 
# ==================================================================================

mach_data_df <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(population_df, by = join_key) %>%
  select(-land_area, -pop.y, -pop.x) %>%
  left_join(regions_df, by = "state") %>%
  select(year, state, usps_st, region, subregion, reg_code, subreg_code, gun_rate, other_rate, all_rate, pop_density) %>%
  left_join(state_laws_total_df, by = join_key) %>%
  left_join(laws_cat_df, by = join_key) %>%
  left_join(gun_own_2013_df, by = "state") %>%
  left_join(gun_own_prx_df, by = join_key) %>%
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

# ==================================================================================
# 
# Divide data into train and test sets (two methods)
# 
# ==================================================================================

# Split into train & test data sets at 50/50 ratio
gp <- runif(nrow(mach_data_df))
train_df <- mach_data_df[gp < 0.50, ]
test_df <- mach_data_df[gp >= 0.50, ]
dim(train_df)
dim(test_df)

# # Play with 2013 as train and balance as test
# train_df <- mach_data_df %>% filter(year == 2013)
# test_df <- mach_data_df %>% filter(year != 2013)

# ==================================================================================
# 
# Run correlation table, check for colinearity, assess prospective variables
# 
# ==================================================================================

# Run correlation matrix on prospective variables
train_df[ , 8:ncol(train_df)] %>%
  cor()

# Check single variable linear models
mod1 <- lm(gun_rate ~ pop_density, train_df)
summary(mod1)

# ==================================================================================
# 
# Design, test and run regression model on train data
# 
# ==================================================================================

# Design, test and run multi-variate linear model
mod2 <- lm(gun_rate ~ own_proxy + buy_reg + reg_west, train_df)

# Check results
summary(mod2)
summary(augment(mod2))
confint(mod2)
anova(mod2)

# Most effective variables are own_proxy, buy_reg and reg_west
# pop_density effect plummeted when combined with other variables
# lawtotal similar in effect to buy_reg but inlcudes laws unrelated to dependent variable
# siegel_rate (avg own_proxy for 1981-2013) oddly more accurate than annual own_proxy,
# but annual own_proxy is a more statistically relevant value to utilize

# Residual & Q-Q Plot code from linear regression exercise
par(mar = c(4, 4, 2, 2), mfrow = c(1, 2)) #optional
plot(mod2, which = c(1, 2)) # "which" argument optional

# Checking outliers - WV-2016, WY-2012, SD-2007
train_df[c(435, 449, 372), ]

# ==================================================================================
# 
# Apply model to test data and evaluate results
# 
# ==================================================================================

# Run model against test data and check results
test2 <- lm(mod2, test_df)
summary(test2)
confint(test2)
anova(test2)

# Load predicted values into test_df, check r2 and RMSE
test_df$predict <- predict(mod2, test_df)
(cor(test_df$predict, test_df$gun_rate)^2)
(test2_rmse <- sqrt(mean((test_df$predict - test_df$gun_rate)^2)))

# Residual & Q-Q Plot
plot(test2, which = c(1, 2))

# Checking outliers - AK-2008, OK-2016, AK-2013 
test_df[c(10, 318, 12), ]

# Plot Gain Curve for Model
GainCurvePlot(test_df, "predict", "gun_rate", "Proxy Ownership Model Results")


# ==================================================================================
# 
# Develop model utilizing Random Forest approach
# 
# ==================================================================================

# Create table for use with ranger package
rf_data_df <- sui_method_df %>%
  filter(state != "District of Columbia") %>%
  left_join(population_df, by = join_key) %>%
  select(-land_area, -pop.y, -pop.x) %>%
  left_join(regions_df, by = "state") %>%
  select(year, state, usps_st, reg_code, subreg_code, gun_rate, pop_density) %>%
  left_join(gun_own_prx_df, by = join_key) %>%
  left_join(laws_cat_df, by = join_key) %>%
  filter(year >= 1999)

# Convert region/subregion to factor for linear regression
rf_data_df$reg_code <- factor(rf_data_df$reg_code)
rf_data_df$subreg_code <- factor(rf_data_df$subreg_code)

# Create variable for reg_west T/F per feedback from initial model
# Deciding to create separate variable for each to test
rf_data_df <- rf_data_df %>%
  mutate(reg_west = reg_code == 4,
         reg_neast = reg_code == 1,
         reg_midw = reg_code == 2,
         reg_south = reg_code == 3)

str(rf_data_df)
outcome <- c("gun_rate")
var_names <- c("deal_reg", "buy_reg", "high_risk", "bkgrnd_chk", "ammo_reg", "poss_reg",
               "conceal_reg", "assault_mag", "child_acc", "gun_traff", "stnd_grnd", "pre_empt",
               "immunity_", "dom_viol")


# Split into train & test data sets at 50/50 ratio
gp <- runif(nrow(rf_data_df))
rf_train <- rf_data_df[gp < 0.50, ]
rf_test <- rf_data_df[gp >= 0.50, ]
dim(rf_train)
dim(rf_test)

# Create formula
fml <- paste(outcome, "~", paste(var_names, collapse = " + "))

# Fit the model
model_rf <- ranger(fml,
                   rf_train,
                   num.trees = 500,
                   respect.unordered.factors = "order", 
                   seed = 123)
model_rf

rf_test$predict <- predict(model_rf, rf_test)$predictions

cor(rf_test$gun_rate, rf_test$predict)^2
(rf_rmse <- sqrt(mean((rf_test$predict - rf_test$gun_rate)^2)))
# r2 of 0.887 and RMSE of 1.05 using gun law variables only

ggplot(rf_test, aes(x = predict, y = gun_rate, label = usps_st, color = reg_code)) + 
  geom_point() + 
  geom_abline()


outcome <- c("gun_rate")
var_names <- c("deal_reg", "buy_reg", "high_risk", "bkgrnd_chk", "ammo_reg", "poss_reg",
               "conceal_reg", "assault_mag", "child_acc", "gun_traff", "stnd_grnd", "pre_empt",
               "immunity_", "dom_viol", "reg_west", "reg_neast", "reg_midw", "reg_south",
               "subreg_code", "pop_density", "own_proxy")
