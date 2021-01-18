rm(list = ls())

# Initial set-up ----------------------------------------------------------

## Working directory
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd()

## Packages
library(tidyverse) # wrangling and plotting
library(cowplot) # plotting multiple panels 
library(sf) # spatial anything
library(mapview) # interactive mapping
#library(janitor) # cleaning names
library(tmap) # mapping 
library(tmaptools)
library(OpenStreetMap) # adding base layers to tmaps
library(albersusa) # mapping US counties/boundaries
library(leaflet)


# Import housing burden data ----------------------------------------------

hb <- read_csv("02-clean-data/housing_burden.csv")
hb <- hb %>% select(-X1)


# Create dataset ----------------------------------------------------------

## Grab relevant data from burden variable
# hb_abb <- hb %>%
#   filter(grepl("gross rent or selected housing costs", burden))

## Import CA counties shape file
ca_county_shape <- st_read("01-raw-data/shape-files/CA_Counties/CA_Counties_TIGER2016.shp") %>%
  st_transform("+proj=longlat +datum=WGS84")

## Merge with housing burden data
ca_county_burden <- left_join(ca_county_shape, hb,
                                  by = c("NAMELSAD" = "county_name")) %>%
  st_as_sf()


#popup1 <- paste0("Housing Cost Burden: ", 
#                 as.character(ca_county_burden$percent_rounded), "%")

ca_county_burden$percent_group <- ifelse(ca_county_burden$percent_rounded >= 0.00 &
                                               ca_county_burden$percent_rounded <= 25, "0-25",
                                             ifelse(ca_county_burden$percent_rounded > 25 &
                                                      ca_county_burden$percent_rounded <= 50, "26-50",
                                                    ifelse(ca_county_burden$percent_rounded > 50 &
                                                             ca_county_burden$percent_rounded <= 75, "51-75",
                                                           "76-100")))

ca_county_burden$percent_group <- as.factor(ca_county_burden$percent_group)

pal1 <- colorFactor("Reds", domain = ca_county_burden$percent_group)

ca_housing_burden_map <- leaflet() %>%
  setView(-119.4179, 36.778259, zoom = 5.5) %>%
  addPolygons(data = ca_county_shape,
              #popup = ~popup1, 
              color = "#3498DB", # color of lines and fill
              weight = 1, # thickness of lines
              smoothFactor = 0.5, # smoothness of lines
              opacity = 1, # outline opacity
              fillOpacity = 0.5,
              fillColor = ~pal1(ca_county_burden$percent_group),
              highlightOptions = highlightOptions(color = "#F4D03F",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  addLegend(pal = pal1,
            values = ca_county_burden$percent_group,
            position = "bottomright",
            title = "")

ca_housing_burden_map 