### NEON data access workshop
# March 1, 2021
# devtools::install_github("cboettig/neonstore")
library(neonstore)
library(dplyr)

# Exploring
products <- neon_products()

dim(products) # 181 rows, 24 columns
colnames(products)

unique(products$themes) # 16 themes, many overlapping

mammals_products <- products %>%
  filter(grepl("mammal", productDescription))
plant_products <- products %>% 
  filter(grepl("plant", ignore.case = TRUE, productName))
soil_products <- products %>% 
  filter(grepl("soil", productName))

# Downloading
?neon_download

downloaded_data <- neon_index()

neon_download(mammals_products$productCode[1], site = "HARV")

neon_read(table = downloaded$table[1], product = downloaded$product[1])

foo_downloaded_data <- downloaded_data %>% 
  filter(product == "")

mammal_downloaded <- downloaded %>%
  filter(product = mammals_products$productCode[1])

mammal_harv <- neon_read(table = "")
