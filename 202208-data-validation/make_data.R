#' A script to take some data from 

library(tidyverse)
library(readxl)
library(here)
library(lubridate)

# read in sample data
df <- read_csv(here::here("202208-data-validation", "data_raw", "tea_leafhopper.csv"),
               col_types = cols(
                 Start.Time = col_character()
               ))

df <-
  df %>%
  rename(time = Start.Time) %>% 
  rename_with(~str_replace(., "S", "shoot_")) %>% 
  rename_with(tolower) %>% 
  mutate(leaves = case_when(
    date %in% c("Jul 1", "Jul 2") ~ 30,
    TRUE ~ 50
  )) %>% 
  mutate(date = mdy(paste(date, "2016")))

# create "mistakes" in the "true" data

df <- df %>% 
  #add a suspiciously high number of leaf hoppers per leaf
  mutate(hoppers = if_else(row_number() %in% c(4, 57), 15, hoppers)) %>% 
  #add a different counter for one day
  mutate(counter = if_else(row_number() == 5, "X", counter)) %>% 
  #change a shoot to be 0 cm (should have marked as NA)
  mutate(shoot_6 = if_else(row_number() == 55, 0, shoot_6)) %>% 
  #add decimal in hoppers column
  mutate(hoppers = if_else(row_number() == 13, hoppers + 0.1, hoppers))
  


df_eric <- df_jessica <- df

# Create data entry errors in Eric's version

df_eric <-
  df_eric %>% 
  mutate(
    # read a 7 as a 1
    shoot_4 = if_else(row_number() == 10, 1, shoot_4),
    # enter a trailing space
    counter = if_else(row_number() == 29, "E ", counter)
  ) %>% 
  # missed the last row
  slice(-60)

# Data entry errors in Jessica's version

df_jessica <-
  df_jessica %>% 
  mutate(
    # swapped two values
    shoot_7 = if_else(row_number() == 27, 3.5, shoot_7),
    shoot_7 = if_else(row_number() == 28, 3.2, shoot_7),
    # forget to enter a decimal
    shoot_3 = if_else(row_number() == 48, shoot_3*10, shoot_3),
    # typo
    plant = if_else(row_number() == 50, 1, plant)
  )

anti_join(df_eric, df_jessica)
anti_join(df_jessica, df_eric)

write_csv(df_eric, here("202208-data-validation", "data", "tea_eric.csv"))
write_csv(df_jessica, here("202208-data-validation", "data", "tea_jessica.csv"))
write_csv(df, here("202208-data-validation", "data", "tea_resolved.csv"))
