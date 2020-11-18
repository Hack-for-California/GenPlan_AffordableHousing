## Clears R environment every time you load the script
rm(list = ls())

## Set up working directory 
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd() # Print the working directory to make sure it's correct

## R Packages

## If packages are not installed, remove comments and run this code
# install.packages("tidyverse")
# install.packages("lubridate")

## Mostly for data wrangling and plotting
library(tidyverse)
library(lubridate)

## Import data
tracker <- read.csv("01-raw-data/housing_element_implementation_tracker.csv",
                    stringsAsFactors = FALSE, na.strings = "")

## Rename variables
tracker <- tracker %>%
  rename(COG = Council.of.Government,
         cyc5_projection_period = X5th.Cycle.Housing.Element.Projection.Period,
         cyc5_planning_period = X5th.Cycle.Housing.Element.Planning.Period,
         cyc5_current_compliance = Current.Compliance.Status,
         cyc5_conditional_compliance = Conditional.Compliance.,
         cyc5_cc_cleared = Conditional.Compliance.Date.Cleared,
         cyc5_cc_due = Conditional.Compliance.Due.date,
         cyc5_planning_period_duration = Planning.Period.Duration,
         req_4year_update = If.8.Year..is.a.4.Year.Update.Required.,
         emergency_shelter_zone = SB.2.Emergency.Shelter.Zoning.Completed.,
         cyc4_rezone_program = X1233.Program.Included.,
         cyc4_unit_shortfall = Unit.shortfall,
         cyc4_rezone_acres = Rezone.acres,
         cyc4_rezone_complete = Complete.,
         cyc5_rezone_program = Current.Rezone.Program.Included.,
         cyc5_unit_shortfall = Unit.shortfall.1,
         cyc5_rezone_acres = Rezone.acres.1,
         cyc5_rezone_complete = Complete..1,
         charter_city = Charter.City.,
         apr2013 = X2013,
         apr2014 = X2014,
         apr2015 = X2015,
         apr2016 = X2016,
         apr2017 = X2017,
         apr2018 = X2018)

## Split date variables to convert into different date format
tracker <- tracker %>%
  separate(cyc5_projection_period, c("cyc5_projection_start", 
                                 "cyc5_projection_end"), "-") %>%
  separate(cyc5_planning_period, c("cyc5_planning_start", 
                                 "cyc5_planning_end"), " - ")

## Use mdy() function in lubridate package to change date format
tracker$cyc5_projection_start <- mdy(tracker$cyc5_projection_start)
tracker$cyc5_projection_end <- mdy(tracker$cyc5_projection_end)

tracker$cyc5_planning_start <- mdy(tracker$cyc5_planning_start)
tracker$cyc5_planning_end <- mdy(tracker$cyc5_planning_end)

tracker$cyc5_cc_due <- mdy(tracker$cyc5_cc_due)
tracker$cyc5_cc_cleared <- mdy(tracker$cyc5_cc_cleared)

## Change variable values from Y/N to 1/0
# tracker$cyc5_conditional_compliance <- ifelse(tracker$cyc5_conditional_compliance == "Yes", 1,
#                                           tracker$cyc5_conditional_compliance)
# 
# tracker$req_4year_update <- ifelse(tracker$req_4year_update == "Yes", 1, tracker$req_4year_update)
# 
# tracker$charter_city <- ifelse(tracker$charter_city == "Yes", 1, tracker$charter_city)
# 
# tracker$apr2013 <- ifelse(tracker$apr2013 == "Yes", 1, 0)
# tracker$apr2014 <- ifelse(tracker$apr2014 == "Yes", 1, 0)
# tracker$apr2015 <- ifelse(tracker$apr2015 == "Yes", 1, 0)
# tracker$apr2016 <- ifelse(tracker$apr2016 == "Yes", 1, 0)
# tracker$apr2017 <- ifelse(tracker$apr2017 == "Yes", 1, 0)
# tracker$apr2018 <- ifelse(tracker$apr2018 == "Yes", 1, 0)

## Remove extra whitespace
tracker$cyc5_current_compliance <- str_trim(tracker$cyc5_current_compliance, "right")

tracker$emergency_shelter_zone <- str_trim(tracker$emergency_shelter_zone, "right") 

tracker$cyc4_rezone_program <- str_trim(tracker$cyc4_rezone_program, "right")

tracker$cyc5_rezone_program <- str_trim(tracker$cyc5_rezone_program, "right")

## Change number values from strings to numeric variables
tracker$cyc4_unit_shortfall <- as.integer(tracker$cyc4_unit_shortfall)

tracker$cyc4_rezone_acres <- as.numeric(tracker$cyc4_rezone_acres)

tracker$cyc5_rezone_acres <- as.numeric(tracker$cyc5_rezone_acres)

## Create new variable that codes 1 for compliance, 0 for not (It does not distinguish
## between different types of in and out of compliance so keep the original variable)
tracker$compliance <- ifelse(tracker$cyc5_current_compliance == "in" |
                               tracker$cyc5_current_compliance == "in - conditional", 1, 0)

## Separate out the cities that are not in compliance and save as a new file
cyc5_noncompliance <- subset(tracker, compliance == 0)

write.csv(cyc5_noncompliance, "02-clean-data/HEIT_cycle5_noncompliance.csv")

## Cleaned all cities data
write.csv(tracker, "02-clean-data/HEIT_cycle5_all_cities.csv")