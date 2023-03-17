# Label each survey observation by 
# whether or not the rodent was captured during monsoon season
# Monsoon start is defined as the day on which 
# 10% of the total JAS precip is achieved


library(tidyverse)

# Read in surveys data
surveys_complete <- read_csv("202303-dplyr-joins/data_clean/surveys_complete.csv")
monsoon <- read_csv("202303-dplyr-joins/data_clean/portal-monsoon.csv")

str(surveys_complete)
str(monsoon)

# Create date column
# Use with join_by() function tha thas more flexible specification

surveys_complete <- surveys_complete %>%
  mutate(date = as.Date(paste0(year, "-", month, "-", day)))
  
surveys_monsoon <- 
  inner_join(surveys_complete, monsoon, join_by(date >= m_start, date <= m_end))

# Alternatively, can use the between() helper function
surveys_monsoon2 <- surveys_complete %>%
  mutate(date = as.Date(paste0(year, "-", month, "-", day))) %>%
  inner_join(monsoon, join_by(between(date, m_start, m_end), year))

