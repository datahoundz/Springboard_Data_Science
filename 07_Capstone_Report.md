
Firearm Suicide: The Hidden Side of Gun Violence
================================================

The Problem
-----------

**The individual most likely to kill a gun owner is …himself.** In the ongoing discussions of mass shootings and gun regulation, few address this less newsworthy fact. The CDC reports that 37,353 people were killed by firearms in 2016. Suicides, at 22,938, made up over 60% of those deaths. In 42 states an individual is more likely to kill themselves with a gun than to be shot dead by an assailant. The greatest risk to a gun owner is his own gun.

Best States for Gun Owners?
---------------------------

The 2015 Guns & Ammo rankings for ["Best States for Gun Owners"](http://www.gunsandammo.com/network-topics/culture-politics-network/best-states-for-gun-owners-2015/) bear an uncanny relationship to another data set, state level firearm suicide rates. Alaska, Wyoming and Montana rank 3rd, 6th and 11th respectively in the Guns & Ammo rankings. They also boast, by far, the highest firearm suicide rates (FSR) in the country. Guns & Ammo ranks Massachusetts, New Jersey and New York at 48, 49 and 50. These three states post the lowest FSR levels in the nation. In 2015, the FSR for Massachusetts was approximately ten times lower than the rate for Montana. This equated to 118 gun suicides in Massachusetts compared to 174 in Montana, with a population nearly seven times smaller. In addition, Massachusetts, a highly urbanized northeastern state, also registered a lower firearm *homicide* rate. By these measures, it is hard to determine what is meant by "The Best States for Gun Owners".

![](07_Capstone_Report_files/figure-markdown_github/guns_ammo_vs_fsr-1.png)

Abstract
--------

This project will explore the often overlooked issue of firearm suicide in the United States. The analysis will include an overall picture of the degree and distribution of firearm suicides and an investigation of the key state-level variables of gun ownership rates and gun control legislation. Linear regression models will be developed to test the relationship between ownership levels, gun law categories and state firearm suicide rates. Finally, specific classes of gun laws will be evaulated to determine their potential effect in reducing firearm suicide deaths.

The Data
--------

The [Centers for Disease Control and Prevention](https://wonder.cdc.gov/) provides the state-level firearm homicide and suicides rates as well as overall suicide rates annually for the period of 1999 to 2016. Gun law grades and limited state gun law and gun death data comes from the [Giffords Law Center](http://lawcenter.giffords.org/) for 2014 to 2016. Highly detailed annual gun law data for 1999 to 2016 was accessed at the Boston University School of Public Health [State Firearm Law database](https://www.statefirearmlaws.org/index.html). State level gun ownership data is exceedingly rare. This analysis was developed utilizing 2013 gun ownership survey results published in the journal [Injury Prevention](http://injuryprevention.bmj.com/content/22/3/216) for a paper by Bindu Kalesan et al., titled *Gun Ownership and Social Gun Culture*.

Data Preparation
----------------

### Data Import and Clean-Up of Variable Names and Types

During data import, all variable names were converted to lower case and spaces were replaced with underscores. Variable names were shortened where possible and shared variable names were standardized to facilitate the table joins. Other names had to be made more distinct to accommodate planned table merges. In addition, certain variables had to be converted from character to integer or numerical types. All imported files were converted to data frames with names that clearly indicated the nature of the data.

### Missing State Level CDC Suicide and Homicide Data

Several states were missing CDC homicide and suicide data for specific years. To assure the same 18 years of data for every state, both the suicide and homicide tables were joined to a complete CDC population data table. A consequent review of the state level data indicated that missing entries were likely not zero values. Further review of state level min, max and mean values suggested replacing the missing values with a state mean. After replacing the missing death count values, the related death rate NA’s were calculated where missing. Data was inspected for consistency and outliers, revealing only that the District of Columbia has an unusually high homicide rate, partially the result of a very small population base.

### Letter to Score and Reordered Rankings of Giffords Gun Law Grades

The Giffords gun law data included letter grades, but the analysis would be better served by also having numerical grades. The was addressed by joining the gun law data to a letter grade conversion table and then using a mutate command to populate an equivalent numerical gun law score in the gun law data table. A second issue arose from the gun death ranking variable running from low to high, with highest being the best ranking. This was the opposite of the gun law rankings where low scores were the best. It was decided to maintain the same low-high ranking logic across variables and convert the death rank scores accordingly.

### Collapsing Variables for Boston University State Gun Law Data

The state gun law data tracked back to 1991 and included 134 gun law variables. First, the data was filtered to include only the 1999-2016 timeframe covered by the CDC data. Second, and much more complicated, a law category data table was created with specific laws grouped into broader categories reducing the number of gun law variables from 134 to 14. The additional source state law code file facilitated this process, providing the category names and the related variables for the required mutate sequence. The original disaggregated file was retained for potential use at the machine learning phase of the capstone project.

### State Region and Subregion Census Data

Census Bureau data for state regions and sub-regions were imported to allow higher level data analysis investigating regional differences in gun ownership, gun laws and gun deaths. A unite command created region and subregion variables combining the code number and the name for simpler sorting of data legends when creating plots.

The source R-code file is available in a GitHub repository [here](https://github.com/datahoundz/Springboard_Data_Science/blob/master/01_data_import.R) and cleaned csv files are [here](https://github.com/datahoundz/Springboard_Data_Science/tree/master/data_cleaned).

Data Issues
-----------

### Excluding the District of Columbia

The District of Columbia was excluded from the anlaysis. As the lone geographical unit that is both a city and a state, its homicide rates were extremely high skewing any plots that included it. Inversely, DC's suicide rate is the lowest in the country with several years posting no suicide data at all. Also, several other data sources include only state level data without figures for DC. It is believed that these reasons justify its exclusion from this analysis.

### Gun Ownership Rates

Gun ownership data presents conflicting issues. The survey data acquired from the Kalesan Injury Prevention article covers only the single year of 2013. This impairs the ability to analyze shifts in state level gun ownership rates over time. Dr. Michael Siegel at the Boston University School of Public Health has developed a [proxy ownership metric](https://www.ncbi.nlm.nih.gov/pubmed/23956369) that has been calculated from 1980 to 2016. This data was acquired directly from Dr. Siegel and was integrated into the analysis. However, the proxy measurement utilizes the firearm suicide rate as a key element in its calculation. As the FSR is the dependent variable of interest in this study, this proxy measure was not utilized in the final analysis. Sharp discrepancies between Siegel's proxy measure and the Kalesan 2013 survey results, as illustrated in the plot below, strongly supports the need for better data on this critical variable.

![](07_Capstone_Report_files/figure-markdown_github/siegel_kalesan_plot-1.png)

### State Firearm Laws

The State Firearm Law database tracks 132 separate law variables over more than twenty years. For purposes of simplification, the 132 laws were grouped into the 14 larger categories outlined in the code file. Yet, the most frequent count for many of these categories remains zero as shown in this [linked map plot](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/law_cat_map.png) (zero values in pale green). In these cases the measure is more binary than one of degree - does the state have *any* laws within a given category? This makes comaprisons between states more challenging, especially when combined with gun ownership data for only a single year.

Firearm Suicide Takes More Lives, and It's Getting Worse
--------------------------------------------------------

Firearm suicides not only consistently exceed firearm homicides, the divergence has been growing. Since 2008, the number of American's taking their lives with a gun has risen steadily with no indication of slowing down. Firearm homicides, by contrast, remained fairly steady and even posted several years of declines until the last few years.

![](07_Capstone_Report_files/figure-markdown_github/sui_vs_hom_line-1.png)

### Firearm Suicide Nearly Twice as Frequent as Firearm Homicide

The average state firearm suicide rate (FSR) is nearly twice as high as the the average firearm homicide rate (FHR). In more rural states, the disparity is even greater. Only six states have firearm homicide rates that exceed their firearm suicide rates. Five of these six states have an FSR far below the national average.

![](07_Capstone_Report_files/figure-markdown_github/fsr_minus_hsr-1.png)

### Rural and Mountain States Suffer Higher Overall Suicide Rates

Overall suicide rates display a strong negative correlation (-0.759) with a state's population density and also exhibit significant regional influences. States in the Northeast have much lower rates, while states in the Mountain subregion experience sharply higher levels than the rest of the country. This holds even allowing for population density as shown by the discrepancy between Mountain and Great Plains states at similar population densities.

![](07_Capstone_Report_files/figure-markdown_github/osr_by_pop_density-1.png)

![](07_Capstone_Report_files/figure-markdown_github/osr_boxplot_subreg-1.png)

### Suicide Methods and Trends Differ Widely by Subregion and State

Time series plots of suicides broken out by firearm/other indicate major regional differences. Coastal states exhibit much lower firearm rates and at levels that appear more steady compared to other suicide methods and other states. State level plots show these disparities existing within subregions as well.

![](07_Capstone_Report_files/figure-markdown_github/reg_sui_method-1.png)

![](07_Capstone_Report_files/figure-markdown_github/state_sui_method-1.png)

More Gun Ownership, More Suicides
---------------------------------

### Gun Ownership Rates Vary by Region

The Northeast has the lowest gun ownership rates, while the South and West display much higher levels.

![](07_Capstone_Report_files/figure-markdown_github/own_rate_boxplot-1.png)

![](07_Capstone_Report_files/figure-markdown_github/own_rate_map-1.png)

### Gun Ownership Correlates with OVERALL Suicide Rates

A positive correlation of 0.644 and an r2 of 0.415 exists between a state's overall suicide rate and it's level of household gun ownership. Regional effects are particularly pronounced in the Northeast and West.

![](07_Capstone_Report_files/figure-markdown_github/own_osr_plot-1.png)

### Mountain States Plagued by High Suicide Rates

Arizona is the only Mountain state to escape the "High" overall suicide classification. Higher population states appear to experience lower suicide levels generally.

![](07_Capstone_Report_files/figure-markdown_github/osr_map-1.png)

### Higher Suicide Levels in Rural States Across Regions

Regional plots bear out the relationship between population density and overall suicide with rural states commanding the upper end of regional FSR levels.

![](07_Capstone_Report_files/figure-markdown_github/own_osr_reg-1.png)

More Gun Ownership, More Gun Suicides
-------------------------------------

### Strong Correlation Between Gun Ownership and Firearm Suicide

Gun ownership rates, unsurprisingly, display an even stronger relationship to the state's firearm suicide rate with a correlation of 0.748 and an r2 of 0.559. The map plot highlights regional variations in this effect as further displayed by the regional correlation plot.

![](07_Capstone_Report_files/figure-markdown_github/own_fsr_plot-1.png)

### Clear Picture of FSR Issue in Mountain States

Utah is the only Mountain state to dodge the "High" FSR classification. Coastal states tend toward lower FSR levels, Alaska being an obvious exception.

![](07_Capstone_Report_files/figure-markdown_github/fsr_map-1.png)

### Regional Plots Highlight Rural/Urban Divide

Rural states rank higher for FSR across all four major regions, while highly urbanized states dominate the lower range of the plots.

![](07_Capstone_Report_files/figure-markdown_github/fsr_own_reg-1.png)

### Gun Ownership Tiers Call Out Impact on FSR

High ownership states account for 12 ot the 13 states with the highest FSR levels. Low ownership states included 11 of the 13 lowest FSR states. Hawaii is almost certainly misrepresented as a high ownership state. Dr. Michael Siegel's proxy data suggests an average ownership rate of only 12.2% as compared to 45.1% from the Kalesan 2013 survey data.

![](07_Capstone_Report_files/figure-markdown_github/fsr_own_tier-1.png)

### Firearms Contribute to Above Average *Overall* Suicide Rates

Since 1999, guns accounted for an average 58% of suicides in states with above average suicide rates and 48% of suicides in states with below average rates (average rates calculated annually).

    ## # A tibble: 2 x 4
    ##   abv_avg_rate     n deaths avg_gun_pct
    ##   <lgl>        <int>  <int>       <dbl>
    ## 1 FALSE          502 437229       0.486
    ## 2 TRUE           398 210903       0.583

Giffords Gun Law Grades Simplify the Picture
--------------------------------------------

### Giffords Law Grades Strong Indicator of Gun Deaths

A state's Giffords Law Grade not only works as a strong predictor of both overall gun death rank and firearm suicide rates, it even helps to predict a state's overall suicide rate. This provides additional support to the hypothesis that easier availability of guns contributes to higher overall suicide rates.

![](07_Capstone_Report_files/figure-markdown_github/giff_grd_gun_dth_rnk-1.png)

### Giffords Rank Solid Predictor of FSR Levels

The regional plot reveals the strong relationship between the gun law rank and the FSR. The relationship holds steadily over the three-year period for which data was available. It also indicates the stability of each state's position in these rankings.

![](07_Capstone_Report_files/figure-markdown_github/giff_vs_fsr-1.png)

### Giffords "F" Associated with Above Average *Overall* Suicide Rate

Out of 50 states, 41 Abv Avg Suicide ratings were indicated correctly by Gifford F. Displayed data for 2016. Slightly lower accuracy in 2014 and 2015 at 38/50 each.

![](07_Capstone_Report_files/figure-markdown_github/osr_by_f_grade-1.png)

    ##           Abv_Average_Rate
    ## Giffords_F FALSE TRUE
    ##      FALSE    21    4
    ##      TRUE      5   20

### Giffords Grade Map Displays Prevalence of "F" Ratings

The map of Giffords Grades presents an almost shocking image of the prevalence of "F" grades across the United States. The South appears distinctly lacking in non-F states. The northern Mountain and Prairie states represent another pocket of light regulation. Grades of A and B are concentrated in the Northeast and West coast. ![](07_Capstone_Report_files/figure-markdown_github/giff_grd_map-1.png)

### Overall Suicide Map Discloses Flipped Regional Images

The New England/Mid-Atlantic region and the Northern Mountain/Plains exhibit a flipped mirror image of the Giffords Grade map. On the other hand, the South and Pacific Northwest evade the direct relationship. ![](07_Capstone_Report_files/figure-markdown_github/giff_osr_mp-1.png)

Strong Firearm Legislation, Lower Firearm Suicides
--------------------------------------------------

### Gun Regulation Varies Widely by Region and Within Regions

As the state level plots below indicate, both the number of gun laws and the trend, increasing or decreasing varies significantly across the country. Even within the highly regulated Northeast, the more rural states of Vermont Maine and New Hampshire have gun laws at levels similar to the South or Mountain West.

![](07_Capstone_Report_files/figure-markdown_github/law_state_plots-1.png)

### Increased Gun Regulation Occuring Mostly on Coasts

Only twelve states, concentrated on the East and West coasts, have significantly increased the number of gun laws between 1999 and 2016. This compares to 18 states that decreased the number of laws during the same period.

![](07_Capstone_Report_files/figure-markdown_github/law_net_chg-1.png)

### Strong Inverse Relation Between Regulation and Firearm Suicides

A strong inverse relationship exists between the number of state gun laws and the firearm suicide rate and this relationship is even more pronounced at regional levels.

![](07_Capstone_Report_files/figure-markdown_github/laws_vs_fsr_all-1.png)

### Regional Plot of Regulation Mirrors Ownership Rates

The distribution of regulation reflects the inverse of the pattern seen with ownership rates. Here gun legislation levels are higher in more urbanized states and lower in the rural areas.

![](07_Capstone_Report_files/figure-markdown_github/laws_vs_fsr_reg-1.png)

### Reduced Gun Laws, Increased FSR Deaths

States that reduced their total number of gun laws saw their average FSR increase by 5X the level experienced by states that implemented 10 or more new gun laws (Large Increase).

![](07_Capstone_Report_files/figure-markdown_github/law_chg_fsr_chg-1.png)

### Select State Comparisons

By way of comparison, Missouri eliminated a net of 10 gun laws and saw its FSR rise by 3.0 per 100,000. California implemented 33 new gun laws and saw its FSR drop by 0.5 per 100,000. Adjusting for population, Missouri saw an estimated 176 more suicides in 2016 while California saved an estimated 183 lives. The equivalent numbers for New York and South Carolina are 39 lives saved and 151 additional deaths respectively.

![](07_Capstone_Report_files/figure-markdown_github/ca_mo_plot-1.png)

Preliminary Conclusions
-----------------------

Analysis to this point suggests some strong candidate variables for predicting a state's firearm suicide rate, several of which correlate with each other. These include region, gun ownership rates, the level of gun law restrictions and population density.

During the machine learning phase of the project, an effort will be made to focus more closely on regional distinctions. The analysis will also shift from the simple total number of laws to explore specific law categories and perhaps even individual laws.

The goal of this analysis is to explore firearm suicide; however, preliminary findings suggest that many of the candidate variables are reasonably strong predictors of overall suicide levels as well. This is to be expected as the FSR represents around half of the overall suicide rate. But it would be interesting to explore how specific classes of gun legislation or other actions might effectively reduce the overall rate, especially in states with disproprtionately high FSR levels.

Another area of interest raised is the disparity between suicide rates in the Mountain and Great Plains subregions, both of which are characterized by similarly low population densities. Additionally sharp differences between neighboring states, Indiana and Illinois for example, present opportunities for more focused investigation of states with similar population profiles.

Machine Learning Plan
---------------------

### The Machine Learning Problem

This research seeks to identify factors that might addressed to reduce firearm suicide rates. Consequently, the machine learning problem is to discover the variables that most effectively predict a state’s firearm suicide rate (FSR). This question lends itself very naturally to a supervised multivariate regression approach.

### Critical Features of the Model

The state level firearm suicide rate is the targeted dependent value. Initial statistical analysis suggests candidates for significant independent variables. These include the state level firearm ownership rates, the number of state level gun control laws – both overall total and counts for specific law categories, census geographic regions and state population density. Additionally, a single national level overall suicide rate for each year will be considered to account for the steady rise in suicide rates, particularly since 2008.

### Gun Ownership Rate Concerns

State level ownership rates are elusive, and the model will depend on rates for 2013 only. This means the model will not account for shifts in ownership rates over the 18-year analysis period. The reliability of the state level gun ownership data presents a second concern. Additional research uncovered another set of 30-year average proxy ownership rates that varies significantly from the modeled data. The annual proxy ownership rates underlying these averages were kindly provided by Dr. Michael Siegel at the Boston University School of Public Health. Unfortunately, this proxy is largely derived from firearm and overall suicide figures. The first is the dependent variable of interest, and the second is made up in part by the first and thus overlapping and highly correlated.

### Time Sensitivity Issues

An additional concern is the reliance on geographic region as an independent variable. This variable is also constant over time, meaning that two of the three primary predictive variables are time invariant. This is a significant drawback of the proposed model as the number of gun laws is the only critical independent variable that varies over time. This fact contributed to the consideration of the national overall suicide rate to account for changes over time. However, this approach again ran into the same issues posed by the ownership proxy.

### Manual Modelling Technique and Evaluation

The predictions will be based upon a multivariate regression model using 2013 data (ownership survey year) to train the model and the remaining data to test it. Variable selection will be based upon the strength of the multiple r-squared value on the training set with an eye to variables with higher absolute values for coefficients and t-values and high significance levels. Residual plots and Q-Q plots will be created to check for data skewing and outlier values. Evaluation will include calculating the r-squared for the predicted and targeted values along with the RMSE figures for the same. In addition to residual and Q-Q plots, gain plots will be created to further visually display model performance.

### Random Forest Models

One random forest model will be created utilizing only the 14 law categories and another using the 132 specific law variables. Their creation is primarily to determine the degree to which law variables alone can predict a state’s FSR.

### Gradient Boost Models

Like the random forest approach above, the primary reason for gradient boost modelling is to assess the ability of law variables alone to predict FSR. However, the gradient boost approach allows the chance to view variables in terms of their importance to the model. After assessing variable importance, an effort will be made to manually create a more effective regression model. Model evaluation will be assessed as above except that the train/test data will be a randomized 70/30 split of the dataset.

The machine learning R data file is available [here](https://github.com/datahoundz/Springboard_Data_Science/blob/master/04_mach_learn.R).

### Machine Learning Process

A data frame, mach\_data\_df, including *all* primary variables of interest has been created. Region and subregion variables of interest were converted to individual factor variables.

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    900 obs. of  34 variables:
    ##  $ year       : int  1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 ...
    ##  $ state      : chr  "Alabama" "Alabama" "Alabama" "Alabama" ...
    ##  $ usps_st    : chr  "AL" "AL" "AL" "AL" ...
    ##  $ region     : chr  "3-South" "3-South" "3-South" "3-South" ...
    ##  $ subregion  : chr  "6-South Central East" "6-South Central East" "6-South Central East" "6-South Central East" ...
    ##  $ reg_code   : Factor w/ 4 levels "1","2","3","4": 3 3 3 3 3 3 3 3 3 3 ...
    ##  $ subreg_code: Factor w/ 9 levels "1","2","3","4",..: 6 6 6 6 6 6 6 6 6 6 ...
    ##  $ gun_rate   : num  9.8 9.6 8.7 8.5 8.9 8.3 8.1 8.6 8.5 9 ...
    ##  $ other_rate : num  2.7 3.5 2.8 3 2.6 3.7 3.6 3.9 4.2 3.8 ...
    ##  $ all_rate   : num  12.5 13.1 11.5 11.5 11.5 12 11.7 12.5 12.7 12.8 ...
    ##  $ pop_density: num  87.5 87.9 88.2 88.5 88.9 ...
    ##  $ lawtotal   : int  16 11 11 11 11 11 11 11 11 11 ...
    ##  $ deal_reg   : int  6 5 5 5 5 5 5 5 5 5 ...
    ##  $ buy_reg    : int  1 0 0 0 0 0 0 0 0 0 ...
    ##  $ high_risk  : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ bkgrnd_chk : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ ammo_reg   : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ poss_reg   : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ conceal_reg: int  3 3 3 3 3 3 3 4 4 4 ...
    ##  $ assault_mag: int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ child_acc  : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ gun_traff  : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ stnd_grnd  : int  1 1 1 1 1 1 1 0 0 0 ...
    ##  $ pre_empt   : int  1 0 0 0 0 0 0 0 0 0 ...
    ##  $ immunity_  : int  1 0 0 0 0 0 0 0 0 0 ...
    ##  $ dom_viol   : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ own_rate   : num  0.489 0.489 0.489 0.489 0.489 0.489 0.489 0.489 0.489 0.489 ...
    ##  $ siegel_rate: num  0.497 0.497 0.497 0.497 0.497 0.497 0.497 0.497 0.497 0.497 ...
    ##  $ own_proxy  : num  0.51 0.477 0.493 0.483 0.496 ...
    ##  $ reg_west   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ reg_neast  : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ reg_midw   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ reg_south  : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
    ##  $ reg_mtn    : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...

### Train & Test Split

Two methods were considered for dividing the train and test data. It was decided to utilize the 2013 data as the training set since it contained the actual 2013 ownership rate survey results. The alternative 70/30 spit code is left, but commented out, in the event that the 2013 training data decision is reversed.

``` r
# Split into train & test data sets at 70/30 ratio
# gp <- runif(nrow(mach_data_df))
# train_df <- mach_data_df[gp < 0.70, ]
# test_df <- mach_data_df[gp >= 0.70, ]
# dim(train_df)
# dim(test_df)

# # Use 2013 as train and balance as test
train_df <- mach_data_df %>% filter(year == 2013)
test_df <- mach_data_df %>% filter(year != 2013)
```

### Review Correlation Table for Colinearity Issues

``` r
# Run correlation matrix on prospective variables
train_df[ , 8:ncol(train_df)] %>% cor()
```

    ##             gun_rate other_rate all_rate pop_density lawtotal deal_reg
    ## gun_rate      1.0000     0.0343    0.906     -0.7006  -0.7864 -0.67778
    ## other_rate    0.0343     1.0000    0.455     -0.0468   0.0304  0.03357
    ## all_rate      0.9057     0.4547    1.000     -0.6442  -0.6879 -0.58978
    ## pop_density  -0.7006    -0.0468   -0.644      1.0000   0.6904  0.68322
    ## lawtotal     -0.7864     0.0304   -0.688      0.6904   1.0000  0.88168
    ## deal_reg     -0.6778     0.0336   -0.590      0.6832   0.8817  1.00000
    ## buy_reg      -0.7616     0.1029   -0.635      0.7129   0.8917  0.78031
    ## high_risk    -0.5927     0.0769   -0.496      0.4698   0.7767  0.65121
    ## bkgrnd_chk   -0.6577     0.1475   -0.524      0.6044   0.8424  0.76790
    ## ammo_reg     -0.6242    -0.0104   -0.561      0.6682   0.8645  0.78466
    ## poss_reg     -0.5587    -0.1382   -0.556      0.5918   0.6833  0.51261
    ## conceal_reg  -0.5257    -0.1830   -0.546      0.3195   0.5737  0.39320
    ## assault_mag  -0.5648    -0.1031   -0.547      0.5907   0.7781  0.66461
    ## child_acc    -0.7163    -0.0360   -0.654      0.6767   0.8484  0.75814
    ## gun_traff    -0.4869    -0.0168   -0.441      0.4341   0.7068  0.61313
    ## stnd_grnd    -0.3795     0.2699   -0.224      0.2956   0.4545  0.31667
    ## pre_empt     -0.6733     0.0410   -0.583      0.5700   0.8138  0.67435
    ## immunity_    -0.5114     0.1939   -0.373      0.4147   0.6312  0.48706
    ## dom_viol     -0.6095     0.0860   -0.507      0.3900   0.8154  0.69513
    ## own_rate      0.7479    -0.0526    0.644     -0.6238  -0.4997 -0.46208
    ## siegel_rate   0.8953    -0.1294    0.743     -0.7230  -0.7787 -0.68013
    ## own_proxy     0.8799    -0.1939    0.702     -0.7116  -0.7851 -0.68705
    ## reg_west      0.3601     0.5651    0.561     -0.3045  -0.0311  0.00422
    ## reg_neast    -0.4461     0.1710   -0.325      0.5984   0.3995  0.47827
    ## reg_midw     -0.1245    -0.0141   -0.117     -0.1983  -0.1212 -0.23462
    ## reg_south     0.1428    -0.6593   -0.152     -0.0250  -0.1888 -0.18306
    ## reg_mtn       0.4562     0.5032    0.620     -0.2851  -0.2521 -0.28217
    ##             buy_reg high_risk bkgrnd_chk ammo_reg poss_reg conceal_reg
    ## gun_rate    -0.7616   -0.5927     -0.658  -0.6242  -0.5587     -0.5257
    ## other_rate   0.1029    0.0769      0.147  -0.0104  -0.1382     -0.1830
    ## all_rate    -0.6351   -0.4956     -0.524  -0.5607  -0.5565     -0.5461
    ## pop_density  0.7129    0.4698      0.604   0.6682   0.5918      0.3195
    ## lawtotal     0.8917    0.7767      0.842   0.8645   0.6833      0.5737
    ## deal_reg     0.7803    0.6512      0.768   0.7847   0.5126      0.3932
    ## buy_reg      1.0000    0.6900      0.737   0.7275   0.5809      0.5083
    ## high_risk    0.6900    1.0000      0.589   0.6427   0.4163      0.5032
    ## bkgrnd_chk   0.7374    0.5890      1.000   0.6935   0.4320      0.4377
    ## ammo_reg     0.7275    0.6427      0.693   1.0000   0.6272      0.3790
    ## poss_reg     0.5809    0.4163      0.432   0.6272   1.0000      0.4165
    ## conceal_reg  0.5083    0.5032      0.438   0.3790   0.4165      1.0000
    ## assault_mag  0.6181    0.5638      0.634   0.7360   0.5315      0.4097
    ## child_acc    0.7614    0.5720      0.632   0.7674   0.6091      0.3955
    ## gun_traff    0.4958    0.5062      0.606   0.6948   0.4478      0.3275
    ## stnd_grnd    0.4217    0.4612      0.447   0.3674   0.1805      0.2878
    ## pre_empt     0.7779    0.5810      0.593   0.6780   0.6677      0.4838
    ## immunity_    0.6601    0.4784      0.537   0.5466   0.4321      0.3092
    ## dom_viol     0.6961    0.6661      0.612   0.6510   0.5527      0.5205
    ## own_rate    -0.4351   -0.3594     -0.572  -0.4057  -0.2404     -0.1897
    ## siegel_rate -0.7635   -0.6207     -0.688  -0.6318  -0.5793     -0.5039
    ## own_proxy   -0.7626   -0.5964     -0.693  -0.6510  -0.5895     -0.4579
    ## reg_west    -0.0377   -0.0329      0.038  -0.0784  -0.1333     -0.0781
    ## reg_neast    0.3751    0.2627      0.374   0.3992   0.2467     -0.1255
    ## reg_midw    -0.0747   -0.0326     -0.134  -0.1243  -0.1447      0.1335
    ## reg_south   -0.2051   -0.1556     -0.221  -0.1413   0.0548      0.0546
    ## reg_mtn     -0.2859   -0.2537     -0.141  -0.1893  -0.1545     -0.1721
    ##             assault_mag child_acc gun_traff stnd_grnd pre_empt immunity_
    ## gun_rate        -0.5648   -0.7163   -0.4869   -0.3795 -0.67332   -0.5114
    ## other_rate      -0.1031   -0.0360   -0.0168    0.2699  0.04099    0.1939
    ## all_rate        -0.5470   -0.6536   -0.4411   -0.2238 -0.58266   -0.3735
    ## pop_density      0.5907    0.6767    0.4341    0.2956  0.57000    0.4147
    ## lawtotal         0.7781    0.8484    0.7068    0.4545  0.81379    0.6312
    ## deal_reg         0.6646    0.7581    0.6131    0.3167  0.67435    0.4871
    ## buy_reg          0.6181    0.7614    0.4958    0.4217  0.77790    0.6601
    ## high_risk        0.5638    0.5720    0.5062    0.4612  0.58102    0.4784
    ## bkgrnd_chk       0.6344    0.6322    0.6064    0.4473  0.59252    0.5366
    ## ammo_reg         0.7360    0.7674    0.6948    0.3674  0.67797    0.5466
    ## poss_reg         0.5315    0.6091    0.4478    0.1805  0.66768    0.4321
    ## conceal_reg      0.4097    0.3955    0.3275    0.2878  0.48376    0.3092
    ## assault_mag      1.0000    0.6168    0.6593    0.3401  0.73932    0.4924
    ## child_acc        0.6168    1.0000    0.6433    0.3325  0.59822    0.5496
    ## gun_traff        0.6593    0.6433    1.0000    0.3686  0.49715    0.3039
    ## stnd_grnd        0.3401    0.3325    0.3686    1.0000  0.38490    0.6624
    ## pre_empt         0.7393    0.5982    0.4972    0.3849  1.00000    0.5810
    ## immunity_        0.4924    0.5496    0.3039    0.6624  0.58103    1.0000
    ## dom_viol         0.5127    0.6518    0.4973    0.3217  0.68433    0.4640
    ## own_rate        -0.4463   -0.4603   -0.4140   -0.3060 -0.37060   -0.3144
    ## siegel_rate     -0.5113   -0.6858   -0.4957   -0.3566 -0.63397   -0.4557
    ## own_proxy       -0.5447   -0.6774   -0.4892   -0.3737 -0.66166   -0.4947
    ## reg_west        -0.0368   -0.1273    0.0132    0.0897 -0.00951    0.0558
    ## reg_neast        0.4495    0.3424    0.1727    0.2235  0.45590    0.3231
    ## reg_midw        -0.2071   -0.1015   -0.0673    0.1428 -0.08788    0.0909
    ## reg_south       -0.1460   -0.0694   -0.0930   -0.3992 -0.28608   -0.4019
    ## reg_mtn         -0.1337   -0.2731   -0.0800   -0.0350 -0.18201   -0.0829
    ##             dom_viol own_rate siegel_rate own_proxy reg_west reg_neast
    ## gun_rate     -0.6095   0.7479     0.89532    0.8799  0.36008    -0.446
    ## other_rate    0.0860  -0.0526    -0.12938   -0.1939  0.56515     0.171
    ## all_rate     -0.5067   0.6442     0.74302    0.7020  0.56059    -0.325
    ## pop_density   0.3900  -0.6238    -0.72305   -0.7116 -0.30448     0.598
    ## lawtotal      0.8154  -0.4997    -0.77873   -0.7851 -0.03114     0.400
    ## deal_reg      0.6951  -0.4621    -0.68013   -0.6871  0.00422     0.478
    ## buy_reg       0.6961  -0.4351    -0.76353   -0.7626 -0.03766     0.375
    ## high_risk     0.6661  -0.3594    -0.62074   -0.5964 -0.03287     0.263
    ## bkgrnd_chk    0.6123  -0.5721    -0.68808   -0.6931  0.03800     0.374
    ## ammo_reg      0.6510  -0.4057    -0.63179   -0.6510 -0.07845     0.399
    ## poss_reg      0.5527  -0.2404    -0.57926   -0.5895 -0.13334     0.247
    ## conceal_reg   0.5205  -0.1897    -0.50392   -0.4579 -0.07813    -0.126
    ## assault_mag   0.5127  -0.4463    -0.51126   -0.5447 -0.03678     0.450
    ## child_acc     0.6518  -0.4603    -0.68579   -0.6774 -0.12733     0.342
    ## gun_traff     0.4973  -0.4140    -0.49568   -0.4892  0.01324     0.173
    ## stnd_grnd     0.3217  -0.3060    -0.35660   -0.3737  0.08966     0.224
    ## pre_empt      0.6843  -0.3706    -0.63397   -0.6617 -0.00951     0.456
    ## immunity_     0.4640  -0.3144    -0.45569   -0.4947  0.05583     0.323
    ## dom_viol      1.0000  -0.2938    -0.58540   -0.6030  0.05797     0.217
    ## own_rate     -0.2938   1.0000     0.70840    0.6968  0.33997    -0.537
    ## siegel_rate  -0.5854   0.7084     1.00000    0.9756  0.14616    -0.414
    ## own_proxy    -0.6030   0.6968     0.97556    1.0000  0.04867    -0.454
    ## reg_west      0.0580   0.3400     0.14616    0.0487  1.00000    -0.278
    ## reg_neast     0.2173  -0.5374    -0.41352   -0.4536 -0.27772     1.000
    ## reg_midw     -0.0279  -0.0752     0.00952    0.1099 -0.33310    -0.263
    ## reg_south    -0.2080   0.1918     0.19442    0.2272 -0.40662    -0.321
    ## reg_mtn      -0.1692   0.3427     0.31194    0.2066  0.73629    -0.204
    ##             reg_midw reg_south reg_mtn
    ## gun_rate    -0.12448    0.1428  0.4562
    ## other_rate  -0.01411   -0.6593  0.5032
    ## all_rate    -0.11691   -0.1524  0.6199
    ## pop_density -0.19835   -0.0250 -0.2851
    ## lawtotal    -0.12122   -0.1888 -0.2521
    ## deal_reg    -0.23462   -0.1831 -0.2822
    ## buy_reg     -0.07468   -0.2051 -0.2859
    ## high_risk   -0.03262   -0.1556 -0.2537
    ## bkgrnd_chk  -0.13388   -0.2213 -0.1408
    ## ammo_reg    -0.12427   -0.1413 -0.1893
    ## poss_reg    -0.14475    0.0548 -0.1545
    ## conceal_reg  0.13350    0.0546 -0.1721
    ## assault_mag -0.20709   -0.1460 -0.1337
    ## child_acc   -0.10148   -0.0694 -0.2731
    ## gun_traff   -0.06728   -0.0930 -0.0800
    ## stnd_grnd    0.14282   -0.3992 -0.0350
    ## pre_empt    -0.08788   -0.2861 -0.1820
    ## immunity_    0.09095   -0.4019 -0.0829
    ## dom_viol    -0.02787   -0.2080 -0.1692
    ## own_rate    -0.07516    0.1918  0.3427
    ## siegel_rate  0.00952    0.1944  0.3119
    ## own_proxy    0.10990    0.2272  0.2066
    ## reg_west    -0.33310   -0.4066  0.7363
    ## reg_neast   -0.26329   -0.3214 -0.2045
    ## reg_midw     1.00000   -0.3855 -0.2453
    ## reg_south   -0.38550    1.0000 -0.2994
    ## reg_mtn     -0.24526   -0.2994  1.0000
