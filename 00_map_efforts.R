# Test run with hex maps

# https://gist.github.com/hrbrmstr/4efedf3b24f7da4e24d1 (source for code below)
# https://gist.github.com/benmarwick/a8888f96728f32e4191f81e7e62d2736

library(rgdal)
library(rgeos)
library(ggplot2)
library(maptools)
library(viridis)


# get map from 
download.file("https://gist.githubusercontent.com/hrbrmstr/51f961198f65509ad863/raw/219173f69979f663aa9192fbe3e115ebd357ca9f/us_states_hexgrid.geojson", "us_states_hexgrid.geojson")
us <- readOGR("us_states_hexgrid.geojson")
centers <- cbind.data.frame(data.frame(gCentroid(us, byid=TRUE), id=us@data$iso3166_2))
us_map <- fortify(us, region="iso3166_2")

# =================================================================

## My edits to original source code

## Remove DC from map
us_map <- us_map %>%
  filter(id != "DC")

## Replace w/ my data set
map_data <- gun_deaths_df %>%
  left_join(regions_df, by = "state") %>%
  inner_join(giff_grd_df, by = join_key) %>%
  filter(year == 2016)

summary(map_data)
head(map_data)

# =================================================================

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

gg <- gg + geom_map(data = map_data,            # set data source
                    map = us_map,
                    aes(fill = subregion,        # set map variable 
                        map_id = usps_st))

gg <- gg + geom_map(
  data = map_data,                              # set data source again
  map = us_map,
  aes(map_id = usps_st),                        # set map label data
  fill = "#ffffff",
  alpha = 0,
  color = "white",
  show.legend = FALSE
) 

gg <- gg + geom_text(data=centers, aes(label=id, x=x, y=y), color="white", size=4)

gg <- gg + coord_map() +
  theme_bw() +
  # scale_fill_continuous(trans = "reverse") +
  scale_fill_discrete() +
  xlab("") +
  ylab("")

gg <- gg + theme(panel.border=element_blank())
gg <- gg + theme(panel.spacing=unit(3, "lines"))
gg <- gg + theme(panel.grid=element_blank())
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(axis.text=element_blank())

gg

  