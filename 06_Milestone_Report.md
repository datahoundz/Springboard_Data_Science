Milestone Report
================
Jim Scotland
Revised: April 9, 2018

Abstract
--------

This project will explore the often overlooked issue of firearm suicide in the United States. The analysis will include an overall picture of the degree and distribution of firearm suicides and an investigation of the key state-level variables of gun ownership rates and gun control legislation. Linear regression models will be developed to test the relationship between ownership levels, gun law categories and state firearm suicide rates. Finally, specific classes of gun laws will be evaulated to determine their potential effect in reducing firearm suicide deaths.

The Data
--------

The [Centers for Disease Control and Prevention](https://wonder.cdc.gov/) provides the state-level firearm homicide and suicides rates as well as overall suicide rates annually for the period of 1999 to 2016. Limited state gun law data comes from the [Giffords Law Center](http://lawcenter.giffords.org/) for 2014 to 2016. Annual gun law data for 1999 to 2016 was accessed at the Boston University School of Public Health [State Firearm Law database](https://www.statefirearmlaws.org/index.html). State level gun ownership data is exceedingly rare. This analysis was developed utilizing 2013 gun ownership survey results published in the journal [Injury Prevention](http://injuryprevention.bmj.com/content/22/3/216) for a paper by Bindu Kalesan et al., titled *Gun Ownership and Social Gun Culture*.

Data Issues
-----------

### Gun Ownership Rates

Gun ownership data presents conflicting issues. The survey data acquired from the Kalesan Injury Prevention article covers only the single year of 2013. This limits the ability to analyze shifts in state level gun ownership rates over time. Dr. Michael Siegel at the Boston University School of Public Health has developed a [proxy ownership metric](https://www.ncbi.nlm.nih.gov/pubmed/23956369) that has been calculated from 1980 to 2016. This data was acquired directly from Dr. Siegel and was integrated into the analysis. However, the proxy measurement utilizes the firearm suicide rate (FSR) in its calculation. As the FSR is the dependent variable of interest in this study, this proxy measure was not utilized the final analysis. Sharp discrepancies between Siegel's proxy measure and the Kalesan 2013 survey results strongly supports the need for better data on this critical variable.

![](06_Milestone_Report_files/figure-markdown_github/siegel_kalesan_plot-1.png)

### State Firearm Laws

The State Firearm Law database tracks 132 separate law variables over a twenty-plus year period. For purposes of simplification, the 132 laws were grouped into the 14 larger categories outlined in the code file. Yet, the most frequent count for many of these categories remains zero as shown in this [linked map plot](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/law_cat_map.png) (zero values in light blue). In these cases the measure is more binary than one of degree - does the state have *any* laws within a given category? This makes comaprisons between states more challenging, especially when combined with gun ownership data for only a single year.

Preliminary Findings
--------------------

### Firearm Suicide Nearly Twice as Frequent as Firearm Homicide

The average state firearm suicide rate (FSR) is nearly twice as high as the the average firearm homicide rate (FHR). In more rural states, the disparity is even greater. Only six states have firearm homicide rates that exceed their firearm suicide rates. Five of these six states have an FSR far below the national average.

![](06_Milestone_Report_files/figure-markdown_github/sui_vs_hom_line-1.png)

![](06_Milestone_Report_files/figure-markdown_github/fsr_minus_hsr-1.png)

### Overall Suicide Rates Higher in Rural States and the Mountain Subregion

Overall suicide rates display a strong negative correlation (-0.759) with a state's population density and also exhibit significant regional influences. States in the Northeast have much lower rates, while states in the Mountain subregion experience sharply higher levels than the rest of the country. This holds even allowing for population density as shown by Mountain vs Great Plains divergence at similar population densities.

![](06_Milestone_Report_files/figure-markdown_github/osr_by_pop_density-1.png)

![](06_Milestone_Report_files/figure-markdown_github/osr_boxplot_subreg-1.png)

### Method of Suicide and Trendlines Vary Widely by Subregion and State

Time series plot of suicides broken out by firearm/other indicates major regional differences. Coastal states exhibit much lower firearm rates and at levels that appear more steady compared to other methods and other states. State level plots show these disparities existing within subregions as well.

![](06_Milestone_Report_files/figure-markdown_github/reg_sui_method-1.png)

![](06_Milestone_Report_files/figure-markdown_github/state_sui_method-1.png)

### Gun Ownership Rates Vary by Region

The Northeast has the lowest gun ownership rates, while the South and West display much higher levels.

![](06_Milestone_Report_files/figure-markdown_github/own_rate_boxplot-1.png)

![](06_Milestone_Report_files/figure-markdown_github/own_rate_map-1.png)

### Gun Ownership Correlates with OVERALL Suicide Rates

A positive correlation of 0.644 and an r2 of 0.415 exists between a state's overall suicide rate and it's level of household gun ownership. Regional effects are particularly pronounced in the Northeast and West.

    ## # A tibble: 1 x 3
    ##       N   cor    r2
    ##   <int> <dbl> <dbl>
    ## 1    50 0.644 0.415

![](06_Milestone_Report_files/figure-markdown_github/own_osr_plot-1.png)

![](06_Milestone_Report_files/figure-markdown_github/osr_map-1.png)

![](06_Milestone_Report_files/figure-markdown_github/own_osr_reg-1.png)

### Stronger Correlation Between Gun Ownership and Firearm Suicide

Gun ownership rates, unsurprisingly, display an even stronger relationship to the state's firearm suicide rate with a correlation of 0.748 and an r2 of 0.559. The map plot highlights regional variations in this effect as further displayed by the regional correlation plot.

    ## # A tibble: 1 x 3
    ##       N   cor    r2
    ##   <int> <dbl> <dbl>
    ## 1    50 0.748 0.559

![](06_Milestone_Report_files/figure-markdown_github/own_fsr_plot-1.png)

![](06_Milestone_Report_files/figure-markdown_github/fsr_map-1.png)

![](06_Milestone_Report_files/figure-markdown_github/fsr_own_reg-1.png)

![](06_Milestone_Report_files/figure-markdown_github/fsr_own_tier-1.png)

### Giffords Law Grades Strong Indicator of Gun Deaths

A state's Giffords Law Grade not only works as a strong predictor of both overall gun death rank and firearm suicide rates, it even helps to predict a state's overall suicide rate. This provides additional support to the possibilty that easier availability of guns may contribute to higher overall suicide rates.

![](06_Milestone_Report_files/figure-markdown_github/giff_grd_gun_dth_rnk-1.png)

![](06_Milestone_Report_files/figure-markdown_github/giff_vs_fsr-1.png)

![](06_Milestone_Report_files/figure-markdown_github/osr_by_f_grade-1.png)

![](06_Milestone_Report_files/figure-markdown_github/giff_grd_map-1.png)

![](06_Milestone_Report_files/figure-markdown_github/giff_osr_mp-1.png)
