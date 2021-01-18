rm(list = ls())

## Set working directory
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd()

## Packages
library(tidyverse)
library(rvest)
library(leaflet)
library(sf)
#library(here)
#library(tigris)
#options(tigris_use_cache = TRUE)
library(mapview)

# Import data ------------------------------------------------------

## Import CA counties simple file
ca_county_shape <- st_read("01-raw-data/shape-files/CA_Counties/CA_Counties_TIGER2016.shp") %>%
  st_transform("+proj=longlat +datum=WGS84")

## Import compliance data
tracker <- read.csv("02-clean-data/HEIT_cycle5_all_cities.csv")

## Import CA places
ca_places <- st_read("01-raw-data/shape-files/ca-places-boundaries/CA_Places_TIGER2016.shp") %>%
  st_transform("+proj=longlat +datum=WGS84")

## Import CA city coordinates
# ca_city <- read.csv("02-clean-data/CA_city_coord.csv")


# Data cleaning and formatting --------------------------------------------

## Remove counties from cities in tracker data
tracker <- tracker %>%
  filter(!grepl("COUNTY", Jurisdiction))

## Format compliance data
compliers <- tracker %>% 
  select(2:31) %>%
  group_by(County) %>%
  summarise(complier = sum(compliance))

## Non-compliance
noncompliers <- tracker %>%
  filter(compliance == 0) %>%
  group_by(County) %>%
  count(compliance) %>%
  select(County, noncomplier = n)

## Merge dataframes
compliers <- left_join(compliers, noncompliers, by = c("County" = "County"))

compliers$noncomplier <- ifelse(is.na(compliers$noncomplier) == TRUE, 0, compliers$noncomplier)

compliers$compliance_prop <- round(compliers$complier/(compliers$complier + compliers$noncomplier), 2)*100

## Merge shape file and compliance data
#ca_county_compliance <- geo_join(ca_county_shape, compliers, "NAMELSAD", "County")

ca_county_compliance <- left_join(ca_county_shape, compliers,
                                  by = c("county" = "County")) %>%
  st_as_sf()
  

# Map of counties --------------------------------------------------

# ## Pop-up text
# popup <- paste0(ca_county_compliance$county, "<br>Cities in compliance: ",
#                 as.character(ca_county_compliance$complier))

# popup2 <- paste0(ca_county_compliance$county, "<br>Cities in compliance: ",
#                  as.character(ca_county_compliance$compliance_prop), "%")
#  
# ## Color palette based on categories of compliers
# # ca_county_compliance$compliance_grp <- ifelse(ca_county_compliance$complier < 26, "1-25",
# #                                               ifelse(ca_county_compliance$complier >= 26 & 
# #                                                        ca_county_compliance$complier < 51, "26-50", "51-75"))
# # 
# # pal <- colorFactor("Blues", domain = ca_county_compliance$compliance_grp)
# 
# ca_county_compliance$compliance_prop_group <- ifelse(ca_county_compliance$compliance_prop < 26, "1-25",
#                                                      ifelse(ca_county_compliance$compliance_prop >= 26 &
#                                                               ca_county_compliance$compliance_prop < 51, "26-50",
#                                                             ifelse(ca_county_compliance$compliance_prop >= 51 &
#                                                                      ca_county_compliance$compliance_prop < 76, "51-75",
#                                                                    "76-100")))
# 
# pal2 <- colorFactor("Blues", domain = ca_county_compliance$compliance_prop_group)
# 
# ca_county_map <- leaflet() %>%
#   #addTiles() %>% # overlay polygon onto general map
#   setView(-119.4179, 36.778259, zoom = 5.5) %>%
#   addPolygons(data = ca_county_shape,
#               popup = ~popup2, 
#               color = "#3498DB", # color of lines and fill
#               weight = 1, # thickness of lines
#               smoothFactor = 0.5, # smoothness of lines
#               opacity = 1, # outline opacity
#               fillOpacity = 0.5,
#               fillColor = ~pal2(ca_county_compliance$compliance_prop_group),
#               highlightOptions = highlightOptions(color = "#F4D03F",
#                                                   weight = 2,
#                                                   bringToFront = TRUE)) %>%
#   addLegend(pal = pal2,
#             values = ca_county_compliance$compliance_prop_group,
#             position = "bottomright",
#             title = "Cities in Compliance<br>per County")
# 
# ca_county_map


# Map of cities -----------------------------------------------------------

## Get rid of simple features geometry (only need coordinates for cities)
st_geometry(ca_places) <- NULL

## First capitalize city names to merge with tracker data and filter only what you need
ca_places <- ca_places %>%
  mutate(NAME= toupper(NAME)) %>%
  select(NAME, 
         GEOID, 
         city_lat = INTPTLAT, 
         city_long = INTPTLON)

## Change to numeric data
ca_places$GEOID <- as.integer(ca_places$GEOID)
ca_places$city_lat <- as.numeric(ca_places$city_lat)
ca_places$city_long <- as.numeric(ca_places$city_long)

## Pare down county level data
ca_county_shape <- ca_county_shape %>%
  select(GEOID, 
         county = NAMELSAD, 
         county_lat = INTPTLAT, 
         county_long = INTPTLON)

## Merge city compliance data with county level map file
county_compl <- left_join(tracker, ca_county_shape, 
                          by = c("County" = "county")) %>%
  st_as_sf()

## Merge housing implementation tracker data and city coordinates
ca_city_compliance <- left_join(county_compl, ca_places,
                                by = c("Jurisdiction" = "NAME"))

## Need to fix coordinates for duplicated city entries
dupes <- subset(ca_city_compliance, duplicated(Jurisdiction) == TRUE)

## Popup for each city marker
popup_city <- paste0(ca_city_compliance$Jurisdiction, 
                     "<br>Compliance: ", ca_city_compliance$cyc5_current_compliance)

## CA city icons
city_icon <- iconList(makeIcon(ifelse(ca_city_compliance$compliance == 1,
                                   "03-analysis/icons/green-dot.png",
                                   "03-analysis/icons/red-dot.png"),
                            iconWidth = 12,
                            iconHeight = 12))

## Interactive map
ca_city_map <- leaflet(ca_city_compliance) %>%
  addTiles() %>% # overlay polygon onto general map
  setView(-119.4179, 36.778259, zoom = 5.5) %>%
  addMarkers(~city_long, ~city_lat, 
                   popup = ~popup_city,
                   popupOptions = popupOptions(maxWidth = 100, closeOnClick = TRUE),
             icon = city_icon) %>%
  addPolygons(data = ca_county_shape,
              color = "#3498DB", # color of lines and fill
              weight = 1, # thickness of lines
              smoothFactor = 0.5, # smoothness of lines
              opacity = 1, # outline opacity
              fillOpacity = 0,
              #fillColor = ~pal2(ca_county_compliance$compliance_prop_group),
              highlightOptions = highlightOptions(color = "#F4D03F",
                                                  weight = 2,
                                                  bringToFront = TRUE))

ca_city_map 


# Extra stuff (comment out) -----------------------------------------------

# Scrape CA city coordinates ----------------------------------------------

# webpage <- read_html("https://www.mapsofworld.com/usa/states/california/lat-long.html")
# 
# table <- html_table(webpage, fill = TRUE)
# 
# coord1 <- table[[4]]
# coord2 <- table[[5]]
# coord1 <- data.frame(coord1)
# coord2 <- data.frame(coord2)
# 
# ca_coord <- rbind(coord1, coord2)
# 
# ca_coord <- ca_coord %>% rename(city = Location,
#                                 latitude = Latitude,
#                                 longitude = Longitude)
# 
# ## Save to file
# write.csv(ca_coord, "02-clean-data/CA_city_coord.csv")
