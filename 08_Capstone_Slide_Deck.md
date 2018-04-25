Firearm Suicide: The Hidden Side of Gun Violence
========================================================
author: Jim Scotland
date: April 24, 2018
autosize: true

Overview
========================================================
- Shed light on hidden issue of firearm suicide
- Frame issue relative to homicide deaths and overall suicide
- Explore potential impact of region, laws and ownership rates
- Develop regression model to predict gun suicides
- Use modeling to assess critical gun law interventions


The Problem
========================================================

- The individual most likely to kill a gun owner is *himself*
- Suicides made up 60% of gun deaths in 2016
- Almost 23,000 firearm suicides in 2016 and trend is rising
- In 44 states, rate of gun suicide exceeds gun homicide
- The greatest risk to a gun owner is their own gun


Best States for Gun Owners?
========================================================

![guns_ammo_vs_fsr](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/guns_ammo_vs_fsr-1.png)

***

- Guns & Ammo state rankings find curious correlation
- MT ranked 11th by G&A, 1st in gun suicides
- MA ranked 48th by G&A, 50th in gun suicides
- What exactly does "Best for Gun Owners" mean?


Firearm Suicide as Target of Study
========================================================

- Firearm suicide takes more lives than homicide
- Vast majority of states face far higher firearm suicide rates 
- Suicide is more critical problem in rural states
- Suicide methods and trends vary across regions
- Within regions, gun suicides drive higher rates in rural states


Suicide Takes More Lives, Getting Worse
========================================================

![sui_vs_hom_line](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/sui_vs_hom_line-1.png)

***

- Firearm suicides historically outpace homicides
- Sharp and steady rise in suicides since 2008
- Firearm homicides spiking recently


Firearm Suicide Minus Firearm Homicide
========================================================

![fsr_minus_hsr](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/fsr_minus_hsr-1.png)

***

- Firearm suicide rate 2X homicide rate on average
- Disparity greater in rural states
- Only six states w/ higher homicide rate


Suicide Rates Higher in Rural States
========================================================

![osr_by_pop_density](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/osr_by_pop_density-1.png)

***

- Sparsely populated states face higher suicides
- Mountain states experience most extreme levels
- Similar Plains states all well below Mountain rates
- Northeast posts lowest suicide rates


Regional Variations in Suicide Modality
========================================================

![Regional Suicide Profiles](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/reg_sui_method-1.png)

***

- Firearm suicide rate (FSR) lower and trendline flatter in Northeast and Pacific
- FSR sharply higher and rising in South and Mountain regions



Rural vs Urban Divide within Regions
========================================================

![State Suicide Profiles](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/state_sui_method-1.png)

***

- Massachusetts vs Maine
- New York vs Pensylvania
- Illinois vs Indiana
- Texas vs Oklahoma
- California vs Oregon


Guns Drive Above Average Suicide Rates
========================================================

- Since 1999, guns accounted for 58% of deaths in states with above average suicides
- They account for 48% of deaths in below average states
- In three lowest suicide rate states, guns account for 22%-32% of deaths
- In three highest rate states, guns are used in 63%-65% of suicides


Gun Ownership and Firearm Suicides
========================================================

- Gun ownership data from 2013 Kalesan survey
- Strong relation between higher gun ownership and higher suicide rates
- Regional and rural/urban variations are evident
- Ownership data for one year only limits analysis


More Guns, More Gun Suicides
========================================================

![own_fsr_plot](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/own_fsr_plot-1.png)

***

- Ownership rates strongly correlated with FSR
- Correlation of 0.748 and r-squared of 0.559
- Divide between rural and urban apparent again


Mapping Gun Ownership and FSR Levels
========================================================

![own_rate_map](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/own_rate_map-1.png)

***

![fsr_rate_map](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/fsr_map-1.png)


Ownership Tier and Firearm Suicide Rates
========================================================

![fsr_own_tier](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/fsr_own_tier-1.png)

***

- High ownership tier has 12 of 13 highest FSR states
- Low ownership tier has 11 0f 13 lowest rates
- Hawaii data likely incorrect (see full report)


Giffords Gun Law Grades
========================================================

- Giffords Law Center Data for 2014-2016
- Grades & Rankings show relation between weak laws and gun deaths
- Gun law rankings also display relation with firearm suicide rates
- Data limited to three years impacting deeper exploration


Giffords Grades and Gun Deaths
========================================================

![giff_grd_gun_dth_rnk](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/giff_grd_gun_dth_rnk-1.png)

***

- Half of states receive gun law grade of "F"
- Worst gun death ranks dominated by "F" states
- States with A-B grades boast lowest gun deaths
- Similar relationship for firearm suicides


Mapping Giffords Grades and FSR Levels
========================================================

![giff_grd_map](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/giff_grd_map-1.png)

***

![fsr_rate_map](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/fsr_map-1.png)


Giffords F and Overall Suicide Rates
========================================================

![osr_by_f_grade](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/osr_by_f_grade-1.png)

***

- 41 Above/Below Average rankings indicated by Giffords "F"
- 21 "Non-F" states below average
- 20 "F" states above average


Strong Laws, Fewer Firearm Suicides
========================================================

- Gun regulation varies widely by state and region
- Increased regulation largely limited to coastal states
- Strong relation between regulation and firearm suicides
- Reduced gun laws, increased FSR deaths


Gun Regulation Varies by State & Region
========================================================

![law_state_plots](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/law_state_plots-1.png)

***

- Number of laws and trends wildly disparate
- Variation mirrors rural-urban divide within regions
- Northeast has strongest gun laws nationally
- Maine & Vermont laws closer to South or Mountain West 

Increased Regulation on Coasts
========================================================

![law_net_chg](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/law_net_chg-1.png)

***

Gun Law Changes 1999-2016
- Significantly increased regulation (10+ laws) in only 12 states
- Increases concentrated on East and West coasts
- Laws decreased in 18 states across South, Midwest and West


Laws Strong Indicator of FSR Level
========================================================

![laws_vs_fsr_all](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/laws_vs_fsr_all-1.png)

***

- Number of laws explains 61.7% of variation in state FSR levels
- High regulation coastal states have far lower FSRs
- Western states dominate the low regulation, high FSR corner
- Plot presents reversed mirror image of earlier ownership plot 


Relationship Stronger at Regional Level
========================================================

![laws_vs_fsr_reg](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/laws_vs_fsr_reg-1.png)

***

- Regional plots call out rural vs urban divde once more
- R-squared values markedly higher by region
- AK, WY, MT remain unfortunate outliers at top of FSR range


Reduced Gun Laws, Increased FSR Deaths
========================================================

![law_chg_fsr_chg](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/law_chg_fsr_chg-1.png)

***

- Reduced gun law states averaged 2.42 increase in FSR
- Large increase states (10+ laws) saw only 0.47 increase
- 5X difference in FSR change between two groups
- Changes occur as overall suicide rates rise across nation


Select State Comparisons
========================================================

![ca_mo_plot](https://raw.githubusercontent.com/datahoundz/Springboard_Data_Science/master/07_Capstone_Report_files/figure-markdown_github/ca_mo_plot-1.png)

***

- California +33 gun laws, FSR fell 0.5/100K
- Missouri -10 gun laws, FSR rose by 3.0/100K
- Estimated 176 more Missouri suicides in 2016
- Estimated 183 lives saved in California
- 39 saved lives in NY, 151 more SC deaths






