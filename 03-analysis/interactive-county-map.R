rm(list = ls())

## Set working directory
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd()

## Goal: interactive map that shows all CA cities and which ones are in/out of 
## compliance (e.g. hover over and see info about each city)
## Plan:
#### 1. Get coordinates of all CA cities (webscrape)
#### 2. Add coordinates as variable (lat and long) to main dataset
#### 3. Create map using leaflet with cities in and out of compliance

## Packages
library(tidyverse)
library(rvest)
library(leaflet)
library(sf)
#library(here)
library(tigris)
options(tigris_use_cache = TRUE)

## Scrape CA city coordinates

webpage <- read_html("https://www.mapsofworld.com/usa/states/california/lat-long.html")

table <- html_table(webpage, fill = TRUE)

coord1 <- table[[4]]
coord2 <- table[[5]]
coord1 <- data.frame(coord1)
coord2 <- data.frame(coord2)

ca_coord <- rbind(coord1, coord2)

ca_coord <- ca_coord %>% rename(city = Location,
                                latitude = Latitude,
                                longitude = Longitude)

write.csv(ca_coord, "02-clean-data/CA_city_coord.csv")

## Import CA counties shape file
ca_county_shape <- read_sf("01-raw-data/shape-files/CA_Counties/CA_Counties_TIGER2016.shp") %>%
  st_transform("+proj=longlat +datum=WGS84")

## Import compliance data
tracker <- read.csv("02-clean-data/HEIT_cycle5_all_cities.csv")

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
ca_county_compliance <- geo_join(ca_county_shape, compliers, "NAMELSAD", "County")

# ## Create interactive map

# ## Pop-up text
# popup <- paste0(ca_county_compliance$NAMELSAD, "<br>Cities in compliance: ",
#                 as.character(ca_county_compliance$complier))

popup2 <- paste0(ca_county_compliance$NAMELSAD, "<br>Cities in compliance: ",
                 as.character(ca_county_compliance$compliance_prop), "%")
 
## Color palette based on categories of compliers
# ca_county_compliance$compliance_grp <- ifelse(ca_county_compliance$complier < 26, "1-25",
#                                               ifelse(ca_county_compliance$complier >= 26 & 
#                                                        ca_county_compliance$complier < 51, "26-50", "51-75"))
# 
# pal <- colorFactor("Blues", domain = ca_county_compliance$compliance_grp)

ca_county_compliance$compliance_prop_group <- ifelse(ca_county_compliance$compliance_prop < 26, "1-25",
                                                     ifelse(ca_county_compliance$compliance_prop >= 26 &
                                                              ca_county_compliance$compliance_prop < 51, "26-50",
                                                            ifelse(ca_county_compliance$compliance_prop >= 51 &
                                                                     ca_county_compliance$compliance_prop < 76, "51-75",
                                                                   "76-100")))

pal2 <- colorFactor("Blues", domain = ca_county_compliance$compliance_prop_group)

ca_county_map <- leaflet() %>%
  #addTiles() %>% # overlay polygon onto general map
  setView(-119.4179, 36.778259, zoom = 5.5) %>%
  addPolygons(data = ca_county_shape,
              popup = ~popup2, 
              color = "#3498DB", # color of lines and fill
              weight = 1, # thickness of lines
              smoothFactor = 0.5, # smoothness of lines
              opacity = 1, # outline opacity
              fillOpacity = 0.5,
              fillColor = ~pal2(ca_county_compliance$compliance_prop_group),
              highlightOptions = highlightOptions(color = "#F4D03F",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  addLegend(pal = pal2,
            values = ca_county_compliance$compliance_prop_group,
            position = "bottomright",
            title = "Cities in Compliance<br>per County")

ca_county_map

