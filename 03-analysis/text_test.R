rm(list = ls())

## Working directory
setwd("~/Documents/GitHub/GenPlan_AffordableHousing")
getwd()

## Packages
library(streamR)
library(quanteda)

## Import text
la_plan <- read.delim("01-raw-data/City_Los_Angeles.txt")

## Summary
la_corpus <- corpus(la_plan$CONSERVATION.ELEMENT)
summary(la_corpus, n = 10)

## Keywords in context
kwic(la_corpus, "discrimination", window = 20)[1:5,]

## Convert into document free matrix
la_dfm <- dfm(la_corpus,
              tolower = TRUE,
              stem = FALSE, # can keep stems only if TRUE
              remove_punct = TRUE,
              verbose = TRUE,
              remove = c(stopwords("english"),
                         "�", "$", "^", "n"),
              remove_url = TRUE)

la_dfm[1:5, 1:10]

## Remove stopwords
topfeatures(la_dfm, 25) # Most commonly used words

## Word cloud of commonly used words
textplot_wordcloud(la_dfm, 
                   rotation = 0, 
                   min_size = .75, 
                   max_size = 3, 
                   max_words = 50)






