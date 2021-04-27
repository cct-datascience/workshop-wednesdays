# Fitting leaf-level gas exchange parameters
# Workshop Wednesdays, April 28, 2021
# Jessica Guo & Kristina Riemer

# Fitting of stomatal parameters

library(dplyr)
library(ggplot2)
library(plantecophys)

# Function
untibble <- function(tibble) {
  data.frame(unclass(tibble),
             check.names = FALSE,
             stringsAsFactors = FALSE)
}

# Read in for column names
cnames <- readr::read_csv("../data/ACi/ARTR_20200312.csv", skip = 13, n_max = 0) %>%
  names()
# Read in data and rename columns
c3_gs <- readr::read_csv("../data/ACi/ARTR_20200312.csv", skip = 16, col_names = cnames)

# plot
ggplot(c3_gs, aes(x = VPDleaf, y = gsw, color = factor(ID))) +
  geom_point()

# Ball Berry
fit_gs <- fitBB(untibble(c3_gs), varnames = list(ALEAF = "A",
                                       GS = "gsw",
                                       VPD = "VPDleaf",
                                       Ca = "Ca",
                                       RH = "RHcham"),
                gsmodel = "BallBerry",
                fitg0 = TRUE)

summary(fit_gs$fit)
coef(fit_gs)
