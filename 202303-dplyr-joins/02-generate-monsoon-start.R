# Obtain rainfall data near portal
# Calculate monsoon start dates
# Create table for non-equi joins
library(tidyverse)

# dat_url <- "https://zenodo.org/record/7735298/files/weecology/PortalData-4.0.0.zip"
# dat_path <- "202303-dplyr-joins/data_raw/portaldata.zip"
# 
# download.file(dat_url, destfile = dat_path)
# unzip(dat_path, exdir = "202303-dplyr-joins/data_raw")
# 

weather <- read_csv("202303-dplyr-joins/data_raw/weecology-PortalData-6017f65/Weather/Portal_weather.csv")
# error can be ignored, not using `soiltemp`
str(weather)

#### Calculate monsoon start ####
# sum to daily
# calculate cumulative JAS
mstart <- weather %>%
  mutate(date = as.Date(timestamp)) %>%
  group_by(date) %>%
  summarize(year = unique(year),
            month = unique(month),
            ppt = sum(precipitation)) %>%
  ungroup() %>%
  filter(month %in% 7:9) %>%
  group_by(year) %>%
  mutate(cumppt = cumsum(ppt),
         totppt = sum(ppt),
         tenthppt = 0.1*totppt,
         exceed = ifelse(cumppt > tenthppt, 1, 0)) %>%
  summarize(m_start = date[min(which(exceed == 1))]) %>%
  ungroup() %>%
  mutate(m_end = as.Date(paste0(year, "-09-30"))) %>%
  drop_na()
  

# Save out
write_csv(mstart,"202303-dplyr-joins/data_clean/portal-monsoon.csv")

