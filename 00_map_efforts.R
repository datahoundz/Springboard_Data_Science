## Test run with hex maps

## Source code for map creation below
## https://gist.github.com/hrbrmstr/4efedf3b24f7da4e24d1 
## https://gist.github.com/benmarwick/a8888f96728f32e4191f81e7e62d2736

library(rgdal)
library(rgeos)
library(ggplot2)
library(maptools)


# get map from 
download.file("https://gist.githubusercontent.com/hrbrmstr/51f961198f65509ad863/raw/219173f69979f663aa9192fbe3e115ebd357ca9f/us_states_hexgrid.geojson", "us_states_hexgrid.geojson")
us <- readOGR("us_states_hexgrid.geojson")
centers <- cbind.data.frame(data.frame(gCentroid(us, byid=TRUE), id=us@data$iso3166_2))
us_map <- fortify(us, region="iso3166_2")

## =================================================================

## My edits to original source code

## Remove DC from map
us_map <- us_map %>%
  filter(id != "DC")

## Replace w/ my data set
giff_grd_df %>%
  filter(year == 2016) %>%
  mutate(score = round(law_score)) %>%
  left_join(grd_conv_df, by = c("score" = "GPA")) %>%
  select(state, grade = Letter) ->  giff_letter_mp

qnt <- 3

map_data_df <- regions_df %>%
  select(state, region, usps_st) %>%
  arrange(state) %>%
  left_join(giff_grd_df, by = "state") %>%
  filter(year == 2016) %>%
  left_join(giff_letter_mp, by = "state") %>%
  left_join(gun_own_2013_df, by = "state") %>%
  mutate(own_qnt = ntile(own_rate, qnt)) %>%
  left_join(gun_own_prx_df, by = join_key) %>%
  mutate(prx_qnt = ntile(own_proxy, qnt)) %>%
  left_join(sui_method_df, by = join_key) %>%
  mutate(all_qnt = ntile(all_rate, qnt),
         fsr_qnt = ntile(gun_rate, qnt),
         pct_gun_qnt = ntile(gun_pct, qnt)) %>%
  left_join(homicides_df, by = join_key) %>%
  mutate(hom_qnt = ntile(hom_rate, qnt)) %>%
  inner_join(law_chg_df, by = "state") %>%
  mutate(law_qnt = ntile(law_chg, qnt)) %>%
  inner_join(fsr_chg_df, by = "state") %>%
  mutate(fsr_qnt = ntile(fsr_chg, qnt))

# ===================================================================
# 
# Set colors for mapping continuous and discrete values
# 
# ===================================================================

library(RColorBrewer)
myBlues = brewer.pal(n = 9, "Blues")[3:9]
# c("#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B")

grade_colors <- c("A" = "#08306B", "B" = "#08519C", "C" = "#4292C6", "D" = "#9ECAE1", "F" = "#C6DBEF")
qnt3_colors <- c("1" = "#C6DBEF", "2" = "#4292C6", "3" = "#08306B")
qnt3_labels <- c("1" = "Low", "2" = "Med", "3" = "High")
qnt4_colors <- c("4" = "#C6DBEF", "3" = "#6BAED6", "2" = "#2171B5", "1" = "#08306B")
map_law_labels <- c("1" = "Reduced", "2" = "Unchanged", "3" = "Small Increase", "4" = "Large Increase")


# ===================================================================
# 
# Map Giffords Law Grade
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = grade,       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = grade_colors) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Law Grade") +
  labs(title = "Giffords Law Center: State Gun Law Grades", 
       subtitle = "Grades for 2016") +
  labs(caption = "Source: Giffords Law Center") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_giff_grd <- gg
mp_giff_grd

# ===================================================================
# 
# Map Proxy Gun Ownership Rates
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(own_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Gun Ownership Level") +
  labs(title = "Gun Ownership Rates", 
       subtitle = "Ownership Rates for 2013") +
  labs(caption = "2013 ownership data cited by Kalesan B, Villarreal MD, Keyes KM, et al
       Gun ownership and social gun culture Injury Prevention 2016;22:216-220.") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_own_rate <- gg
mp_own_rate

# ===================================================================
# 
# Map OVERALL Suicide Rates
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(all_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Overall Suicide Rates") +
  labs(title = "OVERALL Suicide Rates", 
       subtitle = "Rates for 2016") +
  labs(caption = "Source: Centers for Disease Control") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_all_rate <- gg
mp_all_rate

# ===================================================================
# 
# Map FIREARM Suicide Rates
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(fsr_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Firearm Suicide Rates") +
  labs(title = "FIREARM Suicide Rates", 
       subtitle = "Rates for 2016") +
  labs(caption = "Source: Centers for Disease Control") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_fsr_rate <- gg
mp_fsr_rate

# ===================================================================
# 
# Map FIREARM HOMICIDE Rates
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(hom_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Firearm Homicide Rates") +
  labs(title = "Firearm HOMICIDE Rates", 
       subtitle = "Rates for 2016") +
  labs(caption = "Source: Centers for Disease Control") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_hom_rate <- gg
mp_hom_rate

# ===================================================================
# 
# Map Gun Law Change
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(law_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Gun Law Change") +
  labs(title = "Changes in Number of Gun Laws", 
       subtitle = "Net Change from 1999-2016") +
  labs(caption = "Boston University School of Public Health") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_law_chg <- gg
mp_law_chg

# ===================================================================
# 
# Map FSR Change
# 
# ===================================================================

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_data_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(fsr_qnt),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_data_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = qnt3_colors, labels = qnt3_labels) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "Firearm Suicide Change") +
  labs(title = "Changes in Firearm Suicide Rates", 
       subtitle = "Net Change from 1999-2016") +
  labs(caption = "Centers for Disease Control") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_fsr_chg <- gg
mp_fsr_chg


# ===================================================================
# 
# Map Gun Laws by Category ---- NOT WORKING???
# 
# ===================================================================

laws_cat_df %>%
  filter(year == 2016) %>%
  group_by(state) %>%
  gather(3:16, key = law_cat, value = law_cnt) %>%
  filter(law_cat == "buy_reg") %>%
  left_join(regions_df, by = "state") -> map_law_df

gg <- ggplot()

gg <- gg + geom_map(
  data = us_map,
  map = us_map,
  aes(x = long,
      y = lat,
      map_id = id),
  color = "white",
  size = 0.5
)

gg <- gg + geom_map(data = map_law_df,            ## set data source
                    map = us_map,
                    aes(fill = as.factor(law_cnt > 0),       #### set map variable 
                        map_id = usps_st))      ## set map label data

gg <- gg + geom_map(
  data = map_law_df,                              ## set data source again
  map = us_map,
  aes(map_id = usps_st),                        ## set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_manual(values = c("#c6dbef", "#08306b")) +
  # scale_fill_continuous(low = "#c6dbef", high = "#08306b") +
  xlab("") +
  ylab("") +
  labs(fill = "") +
  labs(title = "State Gun Laws by Category", 
       subtitle = "Laws in 2016") +
  labs(caption = "Source: Boston University School of Public Health") 

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg <- gg + theme(legend.position = "bottom")

mp_law_cats <- gg
mp_law_cats
