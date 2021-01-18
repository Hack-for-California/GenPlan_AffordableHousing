rm(list = ls())

## Set up working directory
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd()

## Packages
library(tidyverse)

## Import data
housing_burden <- read_csv("01-raw-data/housing-burden/housing_cost_burden_2006-2010.csv")

## Add "County" to county name to merge with main dataset
housing_burden$county_name <- ifelse(is.na(housing_burden$county_name) == FALSE, 
                                     paste0(housing_burden$county_name, " County", 
                                            sep = ""),
                                     housing_burden$county_name)

housing_burden <- housing_burden %>%
  filter(!is.na(county_name)) %>%
  mutate(percent_rounded = round(percent, 2)) %>%
  select(county_name,
         region_name,
         region_code,
         ind_definition,
         burden,
         tenure,
         race_eth_code,
         race_eth_name,
         total_households,
         burdened_households,
         percent,
         percent_rounded,
         LL95CI,
         UL95CI,
         SE,
         rse)

## Save to file
write.csv(housing_burden, "02-clean-data/housing_burden.csv")