library(ratdat)
library(tidyverse)
library(lubridate)

# Download
download.file("https://www.michaelc-m.com/Rewrite-R-ecology-lesson/data/new_data.zip",
              "202303-dplyr-joins/data_raw/new_data.zip")
unzip("202303-dplyr-joins/data_raw/new_data.zip", 
      exdir = "202303-dplyr-joins/data_raw")

# Complete survey data
str(complete_old)
dim(complete_old)
colnames(complete_old)


# Read in 3 new tables
surveys_new <- read_csv("202303-dplyr-joins/data_raw/surveys_new.csv")
problems(surveys_new)
colnames(surveys_new)
surveys_new <- surveys_new %>%
  rename(date = `date (mm/dd/yyyy)`)
summary(surveys_new)


species_new <- read_delim("202303-dplyr-joins/data_raw/species_new.txt",
                          delim = " ", quote = '"')

plots_new <- read_csv("202303-dplyr-joins/data_raw/plots_new.csv")

# Outline steps needed for each table to match complete_old


## surveys_new
# remove accidental character in line 19
# turn weight of 9999 into NA
# separate month, day, and year with lubridate
# remove date column
head(surveys_new, n = 20)

surveys_clean <- surveys_new %>% 
  mutate(hindfoot_length = ifelse(record_id == 16896, 19, hindfoot_length),
         weight = ifelse(weight == 9999, NA, weight), # also possible with na_if()
         date = mdy(date)) 

surveys_new[which(is.na(surveys_clean$date)),] #identify why the dates failed to parse 

surveys_clean <- surveys_clean %>%
  mutate(year = year(date),
         month = month(date),
         day = day(date)) %>%
  select(-date)
  
head(surveys_clean, n = 20)

colnames(complete_old) %in% colnames(surveys_clean)
setdiff(colnames(complete_old), colnames(surveys_clean))

## species_new
# separate species names

head(species_new)
species_clean <- species_new %>%
  separate(species_name, into = c("genus", "species"), sep = " ")

## plots_new
# pivot from wide to long
# isolate numbers from plot_id
# turn from character to numeric

head(plots_new)

plots_clean <- plots_new %>%
  pivot_longer(cols = starts_with("plot"), # or everything()
               names_to = "plot_id",
               values_to = "plot_type") %>%
  mutate(plot_id = str_replace(plot_id, "Plot ", "") %>%
           as.numeric())

str(plots_clean)

# Break 

# Slides

# Join old data with new

## surveys_clean contains the individual level observations
# still lacks 4 columns
setdiff(colnames(complete_old), colnames(surveys_clean))

# needs to be joined with plots_clean to get "plot_type"
# and species_clean to get "genus", "species", and "taxa"

complete_new <- surveys_clean %>%
  left_join(plots_clean, by = "plot_id") %>%
  left_join(species_clean, by = "species_id")

# check years of old and new data
range(complete_old$year)
range(complete_new$year, na.rm = TRUE)

# bind the rows together
surveys_complete <- bind_rows(complete_old, complete_new)

# alternatively, label each row with source of data
surveys_complete <- bind_rows(old = complete_old, new = complete_new,
                            .id = "source")
head(surveys_complete)
tail(surveys_complete)

# write out
if(dir.exists("202303-dplyr-joins/data_clean") == FALSE) {
  dir.create("202303-dplyr-joins/data_clean")
}

write_csv(surveys_complete, file = "202303-dplyr-joins/data_clean/surveys_complete.csv")
