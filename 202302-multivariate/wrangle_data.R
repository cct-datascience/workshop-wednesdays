nofrosting_raw <- read_rds("https://github.com/Aariq/cupcakes-vs-muffins/raw/master/data/nofrosting_wide.rds") 
nofrosting_raw
#set old RNG
RNGversion("3.1.1")
set.seed(888)
nofrosting <-
  nofrosting_raw %>%
  sample_n(30) %>%
  #puts factor names in title case for prettier plots
  mutate(type = fct_relabel(type, tools::toTitleCase)) |> 
  #remove ingredient columns that are all 0's
  select_if(~!all(. == 0))

write_csv(nofrosting, "202302-multivariate/baked_goods.csv")
