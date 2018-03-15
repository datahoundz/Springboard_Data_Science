# Test run with hex maps

# https://gist.github.com/hrbrmstr/4efedf3b24f7da4e24d1 (source for code below)

library(rgdal)
library(rgeos)
library(ggplot2)
library(maptools)
library(viridis)

## Try to replace w/ FSR data
map_data <- sui_method_df %>%
  left_join(regions_df, by = "state")


# get GeoJSON from https://team.cartodb.com/u/andrew/tables/andrew.us_states_hexgrid/public/map

# Read in GeoJSON ---------------------------------------------------------

us <- readOGR("us_states_hexgrid.geojson")

# Get centers of polygns for label placement ------------------------------

centers <- cbind.data.frame(data.frame(gCentroid(us, byid=TRUE), id=us@data$iso3166_2))

# Convert base shapefile into something ggplot can handle -----------------

us_map <- fortify(us, region="iso3166_2")

gg <- ggplot()

# Plot base map -----------------------------------------------------------

gg <- gg + geom_map(data=us_map, map=us_map,
                    aes(x=long, y=lat, map_id=id),
                    color="white", size=0.5)

# Plot filled polygons ----------------------------------------------------

gg <- gg + geom_map(data=us@data, map=us_map,
                    aes(fill=bees, map_id=iso3166_2))

# Overlay borders without ugly line on legend -----------------------------

gg <- gg + geom_map(data=us@data, map=us_map,
                    aes(map_id=iso3166_2),
                    fill="#ffffff", alpha=0, color="white",
                    show_guide=FALSE)

# Place state name in center ----------------------------------------------

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

# ColorBrewer scale; using distiller for discrete vs continuous -----------

gg <- gg + scale_fill_distiller(palette="RdPu", na.value="#7f7f7f")

# coord_map mercator works best for the display ---------------------------

gg <- gg + coord_map()

# Remove chart junk for the “map" -----------------------------------------

gg <- gg + labs(x=NULL, y=NULL)
gg <- gg + theme_bw()
gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())
gg


# ====================================================================
  
# get map from 
download.file("https://gist.githubusercontent.com/hrbrmstr/51f961198f65509ad863/raw/219173f69979f663aa9192fbe3e115ebd357ca9f/us_states_hexgrid.geojson", "us_states_hexgrid.geojson")
us <- readOGR("us_states_hexgrid.geojson")
centers <- cbind.data.frame(data.frame(gCentroid(us, byid=TRUE), id=us@data$iso3166_2))
us_map <- fortify(us, region="iso3166_2")

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

gg <- gg + geom_map(data = map_data,
                    map = us_map,
                    aes(fill = gun_pct,
                        map_id = usps_st))

gg <- gg + geom_map(
  data = map_data,
  map = us_map,
  aes(map_id = usps_st),
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  scale_fill_viridis(option = "inferno", direction = -1) +
  xlab("") +
  ylab("")

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())


gg 


## Try to replace w/ FSR data
map_data <- sui_method_df %>%
  left_join(regions_df, by = "state")

summary(map_data)
  