# Machine Learning Code

library(stringr)
library(ranger)
library(vtreat)
library(xgboost)


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
         reg_south = reg_code == 3,
         reg_mtn = subreg_code == 8)

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
# gp <- runif(nrow(mach_data_df))
# train_df <- mach_data_df[gp < 0.50, ]
# test_df <- mach_data_df[gp >= 0.50, ]
# dim(train_df)
# dim(test_df)

# # Use 2013 as train and balance as test
train_df <- mach_data_df %>% filter(year == 2013)
test_df <- mach_data_df %>% filter(year != 2013)

# ==================================================================================
# 
# Run correlation table, check for colinearity, assess prospective variables
# 
# ==================================================================================

# Run correlation matrix on prospective variables
train_df[ , 8:ncol(train_df)] %>%
  cor()


# Check single variable linear models
mod1 <- lm(gun_rate ~ buy_reg, train_df)
summary(mod1) 

# ==================================================================================
# 
# Design, test and run regression model on train data
# 
# ==================================================================================

# Design, test and run multi-variate linear model
mod2 <- lm(gun_rate ~ own_rate + buy_reg + reg_west, train_df)

# Check results
summary(mod2)
summary(augment(mod2))
confint(mod2)
anova(mod2)

# Most effective variables are own_rate, buy_reg and reg_west
# pop_density effect plummeted when combined with other variables
# lawtotal similar in effect to buy_reg but inlcudes laws unrelated to dependent variable


# Residual & Q-Q Plot code from linear regression exercise
par(mar = c(4, 4, 2, 2), mfrow = c(1, 2)) #optional
plot(mod2, which = c(1, 2)) # "which" argument optional

# Checking outliers - AK-2013, OK-2013, WA-2013
train_df[c(2, 36, 47), ]

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

# Checking outliers - WY-2012, OK-2016, MT-2015 
test_df[c(847, 612, 441), ]

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
  left_join(state_laws_df, by = join_key) %>%
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

# Get law variables from state_codes_df and create law category variable
str(state_codes_df)
law_vars <- unique(state_codes_df$var_name)
law_cats <- c("deal_reg", "buy_reg", "high_risk", "bkgrnd_chk", "ammo_reg", "poss_reg",
              "conceal_reg", "assault_mag", "child_acc", "gun_traff", "stnd_grnd", "pre_empt",
              "immunity_", "dom_viol")


outcome <- c("gun_rate")
var_names <- law_cats
  
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
# r2 of 0.873 and RMSE of 1.09 using gun law category variables only

ggplot(rf_test, aes(x = predict, y = gun_rate, label = usps_st, color = reg_code)) + 
  geom_text() + 
  geom_abline()

GainCurvePlot(rf_test, "predict", "gun_rate", "Random Forest Law Category Model")

# ==================================================================================
# 
# Apply Random Forest approach to specific law variables
# 
# ==================================================================================

outcome <- c("gun_rate")
var_names <- law_vars

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
# Review model
model_rf

rf_test$predict <- predict(model_rf, rf_test)$predictions

cor(rf_test$gun_rate, rf_test$predict)^2
(rf_rmse <- sqrt(mean((rf_test$predict - rf_test$gun_rate)^2)))
# r2 of 0.863 and RMSE of 1.15 using gun law variables only

ggplot(rf_test, aes(x = predict, y = gun_rate, label = usps_st, color = reg_code)) + 
  geom_text() + 
  geom_abline()

GainCurvePlot(rf_test, "predict", "gun_rate", "Random Forest Law Category Model")


# ==================================================================================
# 
# Develop model w/ xgboost package to assess law variable contribution
# 
# ==================================================================================

library(vtreat)
library(magrittr)

# Create table for use with xgboost package
xgb_data_df <- sui_method_df %>%
  select(state, year, fsr = gun_rate) %>%
  left_join(laws_cat_df, by = join_key) %>%
  filter(year >= 1999)

var_names <- law_cats


# Split into train & test data sets at 50/50 ratio
gp <- runif(nrow(xgb_data_df))
xgb_train <- xgb_data_df[gp < 0.50, ]
xgb_test <- xgb_data_df[gp >= 0.50, ]
dim(xgb_train)
dim(xgb_test)

# Create the treatment plan
treat_plan <- designTreatmentsZ(xgb_train, var_names)

# Examine scoreFrame
scoreFrame <- treat_plan %>%
    use_series(scoreFrame) %>%
    select(varName, origName, code)

# We only want the rows with codes "clean" or "lev"
newvars <- scoreFrame %>%
    filter(code %in% c("clean", "lev")) %>%
    use_series(varName)

# Create the treated training data
xgb_train_treat <- prepare(treat_plan, xgb_train, varRestriction = newvars)

# Create the treated test data
xgb_test_treat <- prepare(treat_plan, xgb_test, varRestriction = newvars)


#==============================================================
# 
# Use cross validation to determine number of trees
# 
#==============================================================

# Run xgb.cv cross validation on xgb_train
cv <- xgb.cv(data = as.matrix(xgb_train_treat), 
             label = xgb_train$fsr,
             nrounds = 100,
             nfold = 5,
             objective = "reg:linear",
             eta = 0.3,
             max_depth = 6,
             early_stopping_rounds = 10,
             verbose = 0)

# Get the evaluation log 
eval_log <- as.data.frame(cv$evaluation_log)

# Determine number of trees to minimize training and test error
eval_log %>% 
  summarize(ntrees.train = which.min(train_rmse_mean), ntrees.test  = which.min(test_rmse_mean)) 
# Use 34 trees per evaluation log results (lowest rmse_mean + lowest rmse_std)

#==============================================================
# 
# Fit xgboost model and predict fsr
# 
#==============================================================

xgb_model <- xgboost(data = as.matrix(xgb_train_treat),
                          label = xgb_train$fsr,
                          nrounds = 34,
                          objective = "reg:linear",
                          eta = 0.3,
                          depth = 6,
                          verbose = 0)

# Run model on test data
xgb_test$pred <- predict(xgb_model, as.matrix(xgb_test_treat))

# Plot resulting predictions
xgb_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

# Check r2 and RMSE
cor(xgb_test$pred, xgb_test$fsr)^2
sqrt(mean((xgb_test$pred - xgb_test$fsr)^2))
# r2 = 0.890, RMSE = 0.990

GainCurvePlot(xgb_test, "pred", "fsr", "Gradient Boost Model")


# Model, using only law categories, far outperforms manually created regression model
# Use Gain and Cover measures as blend to evaluate critical variables
importance_table <- xgb.importance(feature_names = var_names, model = xgb_model)
importance_table %>%
  mutate(gain_cover = Gain * Cover) %>%
  arrange(desc(gain_cover))
# buyer_reg ranks as top variable validating its selection in manual regression model
# child_acc variable adds much to its given trees (gain), but covers a much smaller number of trees (cover).
# Other variables drop off rapidly in influence, and bkgrnd_chk is surprisingly near the bottom

# Feature         Gain    Cover   Frequency Importance gain*cover
# 1      buy_reg 0.653139 0.1496   0.11577   0.653139 0.09767944
# 2  conceal_reg 0.056210 0.1849   0.12500   0.056210 0.01039461
# 3    high_risk 0.044581 0.1358   0.13842   0.044581 0.00605225
# 4    child_acc 0.095150 0.0535   0.04279   0.095150 0.00509520
# 5     poss_reg 0.035706 0.1415   0.10822   0.035706 0.00505406
# 6     deal_reg 0.045324 0.0689   0.14094   0.045324 0.00312281
# 7    immunity_ 0.019239 0.0440   0.06208   0.019239 0.00084675
# 8     pre_empt 0.015184 0.0408   0.03356   0.015184 0.00061974
# 9    gun_traff 0.019759 0.0287   0.02349   0.019759 0.00056794
# 10    dom_viol 0.006978 0.0480   0.07550   0.006978 0.00033523
# 11   stnd_grnd 0.005360 0.0460   0.07131   0.005360 0.00024653
# 12  bkgrnd_chk 0.002024 0.0248   0.03020   0.002024 0.00005025
# 13    ammo_reg 0.000710 0.0179   0.02601   0.000710 0.00001270
# 14 assault_mag 0.000636 0.0155   0.00671   0.000636 0.00000984

xgb.plot.importance(importance_matrix = importance_table)


# Use feedback from above to create manual model w/ critical variables
xgb_manual <- lm(fsr ~ buy_reg * child_acc * conceal_reg, xgb_train)
summary(xgb_manual)

# Call:
# lm(formula = fsr ~ buy_reg * child_acc * conceal_reg, data = xgb_train)
# 
# Residuals:
#   Min     1Q Median     3Q    Max 
# -4.448 -1.231 -0.265  0.976  8.235 
# 
# Coefficients:
#   Estimate Std. Error t value             Pr(>|t|)    
# (Intercept)                    10.2481     0.3337   30.71 < 0.0000000000000002 ***
#   buy_reg                         0.3575     0.2476    1.44              0.14949    
# child_acc                      -1.1129     0.2220   -5.01           0.00000078 ***
#   conceal_reg                    -0.2612     0.0892   -2.93              0.00358 ** 
#   buy_reg:child_acc              -0.1068     0.0556   -1.92              0.05530 .  
# buy_reg:conceal_reg            -0.1920     0.0507   -3.79              0.00017 ***
#   child_acc:conceal_reg           0.0899     0.0522    1.72              0.08568 .  
# buy_reg:child_acc:conceal_reg   0.0332     0.0114    2.91              0.00380 ** 
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.88 on 430 degrees of freedom
# Multiple R-squared:  0.646,	Adjusted R-squared:  0.64 
# F-statistic:  112 on 7 and 430 DF,  p-value: <0.0000000000000002


xgb_test$man_pred <- predict(xgb_manual, xgb_test)
cor(xgb_test$man_pred, xgb_test$fsr)^2
sqrt(mean((xgb_test$man_pred - xgb_test$fsr)^2))
# r2 = 0.652, RMSE = 1.75
# Respectable results for utilizing only three law category variables
# After multiple iterations: buyer_reg and child_acc best, 
# conceal_reg and pre_empt equivalent third variable

xgb_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = man_pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

GainCurvePlot(xgb_test, "man_pred", "fsr", "Gradient Boost Manual Model")
