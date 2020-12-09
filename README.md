# General Plan Map - Affordable Housing

## About

Each city and county in California is required to produce a General Plan, a document that outlines and commits local governments to long-term development goals. Planning laws in the State of California mandate that every General Plan address a common set of issues, including Land Use, Conservation, and Housing. However, such laws do not specify where in the General Plan such issues need to be addressed or the format of the Plan overall. Thus, while General Plans offer the most comprehensive blueprint for future visioning of cities and counties throughout California, the structure and format of the Plans vary considerably across cities and counties. This makes it difficult to readily compare planning approaches across the state, to comparatively evaluate progress towards planning goals, and to set benchmarks for policy success. The [General Plan Map](https://critical-data-analysis.org/general-plan-map/) provides access to the text of all California city General Plans and enables users to query for a single search term to determine the plans in which that term is referenced. Upon searching, the tool filters a map to the cities in CA with General Plans that reference the word, offering a geospatial representation of the term's use. The tool also links to the plans that reference the term. Users can click through to the plans and search within the page for the term.

In this project, we have two primary goals: first, to understand to what extent cities are following through on proposed planning around affordable housing. Cities are required to list how they plan to address affordable housing in their general plans and to date there has been no systematic way to compare their blueprint in the Plans to what they actually produce. The General Plan Map now allows this, so we hope to use it to facilitate this research. The second goal is to demonstrate how the General Plan Mapping Tool can be used in support of policy research and outline any issues that we experience along the way.


## Contributors
| Contributions  | Name |
| -----------    | ---- |
|                |      |
|                |      |
|  [🤔](https://github.com/Hack-for-California/GenPlan_AffordableHousing) [🔣](https://github.com/Hack-for-California/GenPlan_AffordableHousing)              |   Ninh Nguyen   |
|  [🤔](https://github.com/Hack-for-California/GenPlan_AffordableHousing) [🔣](https://github.com/Hack-for-California/GenPlan_AffordableHousing)              |   Makenna Harrison   |  

(For a key to the contribution emoji or more info on this format, check out [“All Contributors.”](https://allcontributors.org/docs/en/emoji-key))

## How to Provide Feedback
Questions, bug reports, and feature requests can be submitted to this repo's [issue queue](https://github.com/Hack-for-California/GenPlan_AffordableHousing/issues).

## Copyrights
All code in this repo is licensed with a GNU General Public License 3.0. Please see the license file for details.

All written materials are licensed with a Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0). Please see this [license](https://creativecommons.org/licenses/by-sa/3.0/) for details.

## Have Questions?
Contact hack-for-california@ucdavis.edu

## Definitions and Data Sources
* Housing Implementation Tracker: sourced from [CA Housing and Community Development](https://www.hcd.ca.gov/community-development/housing-element/index.shtml).
* Housing Cost Burden: sourced from [CA Open Data Portal](https://data.ca.gov/dataset/housing-cost-burden).
* CA Affordable Housing and Sustainable Communities: sourced from [CA Open Data Portal](https://data.ca.gov/dataset/california-affordable-housing-and-sustainable-communities).
* CA Geographic Boundaries: sourced from [CA Open Data Portal](https://data.ca.gov/dataset/ca-geographic-boundaries).
* CA Latitude and Longitude Map: sourced from [Maps of World](https://www.mapsofworld.com/usa/states/california/lat-long.html).
* CA Quick Facts: sourced from [US Census Bureau](https://www.census.gov/quickfacts/fact/dashboard/CA/PST120219#PST120219).
* CA Annual Planning Survey Results: sourced from [CA Governor's Office of Planning and Research](https://opr.ca.gov/publications.html).

## Data Collection and Update Process

## Progress
* Text analysis: explored text file structure in R, and created wordclouds for six California city General Plans
* Data visualization: cleaned Housing Implementation Tracker data, started interactive map of California

## Plans
* Text analysis: clean text data, find missing General Plans, check if out of compliance cities are really out of compliance, develop key words, natural language processing
* Data visualization: collect demographic data, collect city specific data, and collect RHNA data

## Repository Structure

1. 01-raw-data: contains the raw data collected and sources
2. 02-clean-data: includes cleaning script and cleaned data
3. 03-analysis: R script for creating data analysis and visuals
4. 04-output: all final outputs from project

## How to Contribute

* File an issue via this repo's issue queue.
* Write code to fix issues or to create new features. When contributing code, please be sure to:
* Review the Hack for California Documentation Guidelines.
* Fork this repository, create a remote to this repo, and ensure your forked repo is constantly consistent with this repo.
* Modify the code, following this project's coding style (using Ratliffe indentation style; snake_case for variable, function names, and file names; dash-case for directory names, and commenting above each function).
* Commit code often and follow the recommendations in the Documentation Guidelines for formatting commit messages.
* Test your code locally before issuing a pull request.
* Issue a pull request for each change.
