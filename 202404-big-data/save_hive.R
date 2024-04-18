library(arrow)
library(dplyr)

birds_arrow_dataset <-
  arrow::open_dataset(
    sources = here::here("202404-big-data",
                         "data",
                         "all_routes_all_stops.csv"),
    format = "csv")

write_csv_dataset(birds_arrow_dataset, here::here("202404-big-data", "data", "hive"),
                  partitioning = "StateNum")
