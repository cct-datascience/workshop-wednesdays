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

# Read in data and rename columns
c3_gs <- readr::read_csv("../data/Gs/ARTR_20190927.csv")

# plot
ggplot(c3_gs, aes(x = VPDleaf, y = gsw, color = factor(ShrubID))) +
  geom_point()

# Remove outlier
c3_gs[which(c3_gs$gsw < -.025),] <- NA

# Ball Berry, fit single curve (to multiple individuals)
fit_gs <- fitBB(untibble(c3_gs), 
                varnames = list(ALEAF = "A",
                                GS = "gsw",
                                Ca = "Ca",
                                RH = "RHcham"),
                gsmodel = "BallBerry",
                fitg0 = TRUE)

summary(fit_gs$fit)
coef(fit_gs)

# Fit multiple curves
fits_gs <- fitBBs(untibble(c3_gs),
                  varnames = list(ALEAF = "A",
                                  GS = "gsw",
                                  Ca = "Ca",
                                  VPD = "VPDleaf"),
                  group = "ShrubID",
                  gsmodel = "BBOpti",
                  fitg0 = TRUE)

length(fits_gs) # 9 for 9 shrubs
summary(fits_gs[[1]]$fit)
coef(fits_gs[[1]])
