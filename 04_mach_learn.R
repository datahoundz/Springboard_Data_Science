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

# Create table for use with xgboost package
gb_data_df <- sui_method_df %>%
  select(state, year, fsr = gun_rate) %>%
  left_join(laws_cat_df, by = join_key) %>%
  filter(year >= 1999)

var_names <- law_cats


# Split into train & test data sets at 70/30 ratio
gp <- runif(nrow(gb_data_df))
gb_train <- gb_data_df[gp < 0.70, ]
gb_test <- gb_data_df[gp >= 0.70, ]
dim(gb_train)
dim(gb_test)

# Create the treatment plan
treat_plan <- designTreatmentsZ(gb_train, var_names)

# Examine scoreFrame
scoreFrame <- treat_plan %>%
    use_series(scoreFrame) %>%
    select(varName, origName, code)

# We only want the rows with codes "clean" or "lev"
newvars <- scoreFrame %>%
    filter(code %in% c("clean", "lev")) %>%
    use_series(varName)

# Create the treated training data
gb_train_treat <- prepare(treat_plan, gb_train, varRestriction = newvars)

# Create the treated test data
gb_test_treat <- prepare(treat_plan, gb_test, varRestriction = newvars)


#==============================================================
# 
# Use cross validation to determine number of trees
# 
#==============================================================

# Run xgb.cv cross validation on gb_train
cv <- xgb.cv(data = as.matrix(gb_train_treat), 
             label = gb_train$fsr,
             nrounds = 100,
             nfold = 5,
             objective = "reg:linear",
             eta = 0.3,
             max_depth = 6,
             early_stopping_rounds = 10,
             verbose = 0)

# Get the evaluation log 
eval_log <- as.data.frame(cv$evaluation_log)
eval_log

# Determine number of trees to minimize training and test error
eval_log %>% 
  summarize(ntrees.train = which.min(train_rmse_mean), ntrees.test  = which.min(test_rmse_mean)) 
# Use 28 trees per evaluation log results (lowest rmse_mean + lowest rmse_std)

#==============================================================
# 
# Fit xgboost model and predict fsr
# 
#==============================================================


gb_model <- xgboost(data = as.matrix(gb_train_treat),
                          label = gb_train$fsr,
                          nrounds = 28,         # Enter number of trees from above
                          objective = "reg:linear",
                          eta = 0.3,
                          depth = 6,
                          verbose = 0)

# Run model on test data
gb_test$pred <- predict(gb_model, as.matrix(gb_test_treat))

# Plot resulting predictions
gb_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

# Check r2 and RMSE
cor(gb_test$pred, gb_test$fsr)^2
sqrt(mean((gb_test$pred - gb_test$fsr)^2))
# r2 = 0.906, RMSE = 0.947

GainCurvePlot(gb_test, "pred", "fsr", "Gradient Boost Model")


# Model, using only law categories, far outperforms manually created regression model
# Use Gain and Cover measures as blend to evaluate critical variables
importance_table <- xgb.importance(feature_names = var_names, model = gb_model)
importance_table %>%
  mutate(gain_cover = Gain * Cover) %>%
  arrange(desc(gain_cover))
# buyer_reg ranks as top variable validating its selection in manual regression model
# child_acc variable adds much to its given trees (gain), but covers a much smaller number of trees (cover).
# Other variables drop off rapidly in influence, and bkgrnd_chk is surprisingly near the bottom
# 
# Feature      Gain    Cover Frequency    gain_cover
# 1      buy_reg 0.6331310 0.128988   0.11352 0.08166604302
# 2    child_acc 0.1199564 0.092441   0.05573 0.01108892526
# 3  conceal_reg 0.0560467 0.174737   0.13416 0.00979342045
# 4    high_risk 0.0364547 0.128251   0.14448 0.00467535631
# 5     poss_reg 0.0313584 0.131531   0.11352 0.00412460752
# 6     deal_reg 0.0428521 0.071050   0.13622 0.00304463010
# 7     pre_empt 0.0302948 0.036055   0.02993 0.00109228596
# 8     dom_viol 0.0104223 0.065736   0.09494 0.00068512147
# 9    immunity_ 0.0192187 0.034670   0.04954 0.00066631931
# 10   gun_traff 0.0103027 0.039031   0.01651 0.00040212823
# 11   stnd_grnd 0.0038283 0.041035   0.05573 0.00015709228
# 12  bkgrnd_chk 0.0037922 0.040229   0.03612 0.00015255986
# 13    ammo_reg 0.0023314 0.015990   0.01858 0.00003727811
# 14 assault_mag 0.0000102 0.000255   0.00103 0.00000000261

xgb.plot.importance(importance_matrix = importance_table)


# Use feedback from above to create manual model w/ critical variables
gb_manual <- lm(fsr ~ buy_reg * child_acc * conceal_reg, gb_train)
summary(gb_manual)

# Call:
#   lm(formula = fsr ~ buy_reg * child_acc * conceal_reg, data = gb_train)
# 
# Residuals:
#   Min     1Q Median     3Q    Max 
# -4.705 -1.057 -0.136  0.931  8.242 
# 
# Coefficients:
#   Estimate Std. Error t value             Pr(>|t|)    
# (Intercept)                   10.12877    0.27016   37.49 < 0.0000000000000002 ***
#   buy_reg                        0.19206    0.19744    0.97               0.3311    
# child_acc                     -0.98170    0.16581   -5.92         0.0000000053 ***
#   conceal_reg                   -0.22373    0.07105   -3.15               0.0017 ** 
#   buy_reg:child_acc             -0.08174    0.04391   -1.86               0.0631 .  
# buy_reg:conceal_reg           -0.17031    0.03935   -4.33         0.0000174833 ***
#   child_acc:conceal_reg          0.06491    0.03911    1.66               0.0975 .  
# buy_reg:child_acc:conceal_reg  0.02991    0.00878    3.41               0.0007 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.79 on 630 degrees of freedom
# Multiple R-squared:  0.655,	Adjusted R-squared:  0.652 
# F-statistic:  171 on 7 and 630 DF,  p-value: <0.0000000000000002


gb_test$man_pred <- predict(gb_manual, gb_test)
cor(gb_test$man_pred, gb_test$fsr)^2
sqrt(mean((gb_test$man_pred - gb_test$fsr)^2))
# r2 = 0.635, RMSE = 1.86
# Respectable results for utilizing only three law category variables
# After multiple iterations: buyer_reg and child_acc best, 
# conceal_reg and pre_empt equivalent third variable
# pre_empt is rated low by gb_model but appeared influential when developing
# original regression model

gb_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = man_pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

GainCurvePlot(gb_test, "man_pred", "fsr", "Gradient Boost Manual Model")


#==============================================================
# 
# Apply gradient boost to individual law variables w/in top four categories:
# buyer_reg, child_acc, conceal_reg, pre_empt
# 
#==============================================================

# Generate list of laws within four key law categories
state_codes_df %>%
  filter(cat %in% c("Buyer regulations", "Child access prevention",
                    "Concealed carry permitting", "Preemption")) %>%
  select(var_name) -> gb_laws_df
gb_laws <- unique(gb_laws_df$var_name)

# Create table for gb_law_model
gb_law_df <- sui_method_df %>%
  filter(year >= 1999) %>%
  select(state, year, fsr = gun_rate) %>%
  left_join(state_laws_df, by = join_key) %>%
  select(state, year, fsr, c(gb_laws))


# Split into train & test data sets at 70/30 ratio
gp <- runif(nrow(gb_law_df))
gb_law_train <- gb_law_df[gp < 0.70, ]
gb_law_test <- gb_law_df[gp >= 0.70, ]
dim(gb_law_train)
dim(gb_law_test)

# Create the treatment plan
treat_plan <- designTreatmentsZ(gb_law_train, gb_laws)

# Examine scoreFrame
scoreFrame <- treat_plan %>%
  use_series(scoreFrame) %>%
  select(varName, origName, code)

# We only want the rows with codes "clean" or "lev"
newvars <- scoreFrame %>%
  filter(code %in% c("clean", "lev")) %>%
  use_series(varName)

# Create the treated training data
gb_law_train_treat <- prepare(treat_plan, gb_law_train, varRestriction = newvars)

# Create the treated test data
gb_law_test_treat <- prepare(treat_plan, gb_law_test, varRestriction = newvars)


#==============================================================
# 
# Use cross validation to determine number of trees
# 
#==============================================================

# Run xgb.cv cross validation on gb_law_train
gb_law_cv <- xgb.cv(data = as.matrix(gb_law_train_treat), 
             label = gb_law_train$fsr,
             nrounds = 100,
             nfold = 5,
             objective = "reg:linear",
             eta = 0.3,
             max_depth = 6,
             early_stopping_rounds = 10,
             verbose = 0)

# Get the evaluation log 
eval_log <- as.data.frame(gb_law_cv$evaluation_log)
eval_log

# Determine number of trees to minimize training and test error
eval_log %>% 
  summarize(ntrees.train = which.min(train_rmse_mean), ntrees.test  = which.min(test_rmse_mean)) 
# Use 27 trees per evaluation log results (lowest rmse_mean + lowest rmse_std)


#==============================================================
# 
# Fit xgboost model for individual laws and predict fsr
# 
#==============================================================

gb_law_model <- xgboost(data = as.matrix(gb_law_train_treat),
                    label = gb_law_train$fsr,
                    nrounds = 27,         # Enter number of trees from above
                    objective = "reg:linear",
                    eta = 0.3,
                    depth = 6,
                    verbose = 0)

# Run model on test data
gb_law_test$pred <- predict(gb_law_model, as.matrix(gb_law_test_treat))

# Plot resulting predictions
gb_law_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

# Check r2 and RMSE
cor(gb_law_test$pred, gb_law_test$fsr)^2
sqrt(mean((gb_law_test$pred - gb_law_test$fsr)^2))
# r2 = 0.800, RMSE = 1.38

GainCurvePlot(gb_law_test, "pred", "fsr", "Gradient Boost Model")

# Model, using only law categories, far outperforms manually created regression model
# Use Gain and Cover measures as blend to evaluate critical variables
importance_table <- xgb.importance(feature_names = gb_laws, model = gb_law_model)
importance_table %>%
  mutate(gain_cover = Gain * Cover) %>%
  arrange(desc(gain_cover))
# buyer_reg ranks as top variable validating its selection in manual regression model
# child_acc variable adds much to its given trees (gain), but covers a much smaller number of trees (cover).
# Other variables drop off rapidly in influence, and bkgrnd_chk is surprisingly near the bottom
# # 
#             Feature        Gain    Cover Frequency    gain x cover
# 1            permith 0.544721390 0.072051   0.06383 0.0392479905460
# 2            capuses 0.107159110 0.075529   0.05382 0.0080936724162
# 3           mayissue 0.153974236 0.050343   0.05382 0.0077514645903
# 4  ccrenewbackground 0.038949099 0.097955   0.04631 0.0038152486228
# 5           ccrevoke 0.022118615 0.070214   0.06383 0.0015530335496
# 6       ccbackground 0.015655980 0.059437   0.05257 0.0009305490425
# 7    permitconcealed 0.014087215 0.064327   0.03755 0.0009061916848
# 8   age18longgunsale 0.013590801 0.045266   0.04881 0.0006151982380
# 9         loststolen 0.014598060 0.036732   0.05382 0.0005362119649
# 10       defactoregh 0.011243408 0.043376   0.03004 0.0004876968110
# 11       fingerprint 0.013444413 0.029412   0.04255 0.0003954321219
# 12  ccbackgroundnics 0.004600998 0.069892   0.04756 0.0003215730417
# 13  age21handgunsale 0.005126564 0.057932   0.08260 0.0002969915462
# 14        preemption 0.006402303 0.045608   0.04380 0.0002919987292
# 15       onepermonth 0.006364584 0.043958   0.03379 0.0002797720954
# 16          waitingh 0.009492918 0.029464   0.03880 0.0002797020433
# 17             lockd 0.005281446 0.023100   0.04506 0.0001220018394
# 18  preemptionnarrow 0.003918584 0.015428   0.01877 0.0000604548950
# 19           showing 0.000782026 0.027949   0.01627 0.0000218564517
# 20            permit 0.003247775 0.005098   0.02003 0.0000165558321
# 21   preemptionbroad 0.001420727 0.003852   0.00751 0.0000054722767
# 22             cap18 0.001347517 0.003218   0.00751 0.0000043369007
# 23         capaccess 0.000863646 0.004059   0.00876 0.0000035058711
# 24           waiting 0.000613809 0.005669   0.03004 0.0000034794433
# 25      capliability 0.000219659 0.004298   0.01377 0.0000009441317
# 26          training 0.000190702 0.002180   0.00876 0.0000004157748
# 27         permitlaw 0.000239325 0.001703   0.00501 0.0000004074889
# 28     registrationh 0.000032792 0.006624   0.01001 0.0000002172052
# 29            locked 0.000285787 0.000716   0.00125 0.0000002047272
# 30             lockp 0.000024095 0.003447   0.01001 0.0000000830512
# 31             cap16 0.000001860 0.000997   0.00250 0.0000000018533
# 32      registration 0.000000558 0.000166   0.00125 0.0000000000926

xgb.plot.importance(importance_matrix = importance_table)


#==============================================================
# 
# Takeaways from gradient boost importance plot for specific laws
# 
#==============================================================

# TOP 10 LAWS FROM MODIFIED IMPORTANCE TABLE
# 1. permith:	A license or permit is required to purchase handguns
# 2. capuses:	Criminal liability for negligent storage of guns if child uses or carries the gun
# 3. mayissue:	"May issue" state (granting of cc permits at discretion of local authorities)
# 4. ccrenewbackground:	Concealed carry permit renewal requires a new background check
# 5. ccrevoke:	Authorities are required to revoke concealed carry permits under certain circumstances
# 6. ccbackground:	Concealed carry permit process requires a background check
# 7. permitconcealed:	Permit required to carry concealed weapons
# 8. age18longgunsale	Purchase of long guns from licensed dealers and private sellers restricted to age 18 and older
# 9. loststolen	Mandatory reporting of lost and stolen guns by firearm owners
# 10. defactoregh:	De facto registration of handguns is in place because of a recordkeeping requirement for all handgun sales


#==============================================================
# 
# Apply gradient boost to ALL law variables to check for missess
# 
#==============================================================

# Create table for gb_all_model
gb_all_df <- sui_method_df %>%
  filter(year >= 1999) %>%
  select(state, year, fsr = gun_rate) %>%
  left_join(state_laws_df, by = join_key) %>%
  select(state, year, fsr, c(law_vars))


# Split into train & test data sets at 70/30 ratio
gp <- runif(nrow(gb_all_df))
gb_all_train <- gb_all_df[gp < 0.70, ]
gb_all_test <- gb_all_df[gp >= 0.70, ]
dim(gb_all_train)
dim(gb_all_test)

# Create the treatment plan
treat_plan <- designTreatmentsZ(gb_all_train, law_vars)

# Examine scoreFrame
scoreFrame <- treat_plan %>%
  use_series(scoreFrame) %>%
  select(varName, origName, code)

# We only want the rows with codes "clean" or "lev"
newvars <- scoreFrame %>%
  filter(code %in% c("clean", "lev")) %>%
  use_series(varName)

# Create the treated training data
gb_all_train_treat <- prepare(treat_plan, gb_all_train, varRestriction = newvars)

# Create the treated test data
gb_all_test_treat <- prepare(treat_plan, gb_all_test, varRestriction = newvars)


#==============================================================
# 
# Use cross validation to determine number of trees
# 
#==============================================================

# Run xgb.cv cross validation on gb_all_train
gb_all_cv <- xgb.cv(data = as.matrix(gb_all_train_treat), 
                    label = gb_all_train$fsr,
                    nrounds = 100,
                    nfold = 5,
                    objective = "reg:linear",
                    eta = 0.3,
                    max_depth = 6,
                    early_stopping_rounds = 10,
                    verbose = 0)

# Get the evaluation log 
eval_log <- as.data.frame(gb_all_cv$evaluation_log)
eval_log

# Determine number of trees to minimize training and test error
eval_log %>% 
  summarize(ntrees.train = which.min(train_rmse_mean), ntrees.test  = which.min(test_rmse_mean)) 
# Use 25 trees per evaluation log results (lowest rmse_mean + lowest rmse_std)


#==============================================================
# 
# Fit xgboost model for individual laws and predict fsr
# 
#==============================================================

gb_all_model <- xgboost(data = as.matrix(gb_all_train_treat),
                        label = gb_all_train$fsr,
                        nrounds = 25,         # Enter number of trees from above
                        objective = "reg:linear",
                        eta = 0.3,
                        depth = 6,
                        verbose = 0)

# Run model on test data
gb_all_test$pred <- predict(gb_all_model, as.matrix(gb_all_test_treat))

# Plot resulting predictions
gb_all_test %>%
  left_join(regions_df, by = "state") %>%
  ggplot(aes(x = pred, y = fsr, color = region, label = usps_st)) + 
  geom_text() + 
  geom_abline() +
  expand_limits(y = 0, x = 0)

# Check r2 and RMSE
cor(gb_all_test$pred, gb_all_test$fsr)^2
sqrt(mean((gb_all_test$pred - gb_all_test$fsr)^2))
# r2 = 0.869, RMSE = 1.01

GainCurvePlot(gb_all_test, "pred", "fsr", "Gradient Boost Model")

# Model, using only law categories, far outperforms manually created regression model
# Use Gain and Cover measures as blend to evaluate critical variables
importance_table <- xgb.importance(feature_names = law_vars, model = gb_all_model)
importance_table %>%
  mutate(gain_cover = Gain * Cover) %>%
  arrange(desc(gain_cover))

xgb.plot.importance(importance_matrix = importance_table)

# TOP 20 Variables from ALL Gun Law Gradient Boost
#                     Feature        Gain     Cover Frequency   gain x cover
# 1                    permith 0.513099722 0.0513600   0.03048 0.026352811759
# 2           opencarrypermith 0.092291587 0.0338146   0.03165 0.003120803295
# 3                    capuses 0.092795690 0.0327936   0.00938 0.003043106284
# 4                   mayissue 0.028705073 0.0414387   0.01758 0.001189500957
# 5            permitconcealed 0.030005186 0.0346469   0.02462 0.001039587493
# 6             recordsdealerh 0.022693306 0.0389861   0.02345 0.000884723864
# 7          ccrenewbackground 0.012622745 0.0503945   0.03048 0.000636117178
# 8            incidentremoval 0.015991925 0.0335150   0.03048 0.000535968797
# 9                   immunity 0.017006658 0.0276221   0.02696 0.000469759631
# 10                elementary 0.017493518 0.0251695   0.03986 0.000440303389
# 11                     nosyg 0.008450914 0.0495511   0.03869 0.000418752101
# 12                    felony 0.009452476 0.0342363   0.03400 0.000323617923
# 13           drugmisdemeanor 0.029204542 0.0089891   0.00586 0.000262522936
# 14          ccbackgroundnics 0.005354246 0.0477977   0.03048 0.000255920493
# 15              alctreatment 0.008287328 0.0302079   0.02931 0.000250342453
# 16                   dealerh 0.016752739 0.0145934   0.02462 0.000244480031
# 17            violentpartial 0.006508868 0.0311845   0.01172 0.000202975493
# 18             invcommitment 0.005492532 0.0277109   0.03400 0.000152202910
# 19                   college 0.003634808 0.0352573   0.02579 0.000128153509
# 20    traffickingprohibitedh 0.009773109 0.0128511   0.00938 0.000125595231

#==============================================================
# 
# Takeaways from gradient boost importance plot for specific laws
# 
#==============================================================

# TOP 10 LAWS FROM MODIFIED IMPORTANCE TABLE IN ALL LAW TOP TEN
# Y permith:	A license or permit is required to purchase handguns
# Y capuses:	Criminal liability for negligent storage of guns if child uses or carries the gun
# Y mayissue:	"May issue" state (granting of cc permits at discretion of local authorities)
# Y ccrenewbackground:	Concealed carry permit renewal requires a new background check
# N ccrevoke:	Authorities are required to revoke concealed carry permits under certain circumstances
# N ccbackground:	Concealed carry permit process requires a background check
# Y permitconcealed:	Permit required to carry concealed weapons
# N age18longgunsale	Purchase of long guns from licensed dealers and private sellers restricted to age 18 and older
# N loststolen	Mandatory reporting of lost and stolen guns by firearm owners
# N defactoregh:	De facto registration of handguns is in place because of a recordkeeping requirement for all handgun sales

# LAWS FROM TOP TEN ALL NOT INCLUDED IN MODIFIED
# 2. opencarrypermith: No open carry of handguns is allowed in public places unless the person has a concealed carry or handgun carry permit
# 6. recordsdealerh: Record keeping and retention required for licensed dealers for handgun sales	
# 8. incidentremoval: State law requires law enforcement to remove firearms from the scene of a domestic violence incident
# 9. immunity: No law provides blanket immunity to gun manufacturers or prohibits state or local lawsuits against gun manufacturers	
# 10. elementary: No gun carrying on elementary school property, including concealed weapons permittees	
# 