
library(dplyr)
library(ggplot2)



## ----download files--------------------------------------------------------------------------------

download.file("https://raw.githubusercontent.com/cct-datascience/CALS-workshops/2023-quarto-reports/202312-quarto-reports/portal_mouse_data.csv", destfile = "mouse_data.csv")
download.file("https://raw.githubusercontent.com/cct-datascience/CALS-workshops/2023-quarto-reports/202312-quarto-reports/portal_ref.bib", destfile = "portal_ref.bib")



## ----load mouse data-------------------------------------------------------------------------------

mouse_data <- read.csv("mouse_data.csv") |>
  mutate(censusdate = as.Date(censusdate))



## --------------------------------------------------------------------------------------------------

ggplot(mouse_data, aes(censusdate, abundance, color = scientificname)) +
  geom_line() +
  theme(legend.position = "bottom") +
  xlab("Census date") +
  ylab("Species abundance")



## --------------------------------------------------------------------------------------------------

mouse_data_ranked <- mouse_data |>
  group_by(scientificname) |>
  summarize(totalabundance = sum(abundance)) |>
  ungroup() |>
  arrange(desc(totalabundance))

head(mouse_data_ranked)

## Link to DM: https://github.com/cct-datascience/CALS-workshops/blob/2023-quarto-reports/202312-quarto-reports/merriams.JPG?raw=true


