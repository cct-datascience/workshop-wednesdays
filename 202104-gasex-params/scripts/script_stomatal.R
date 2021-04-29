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
c3_gs <- readr::read_csv("data/Gs/ARTR_20190927.csv")

# plot
ggplot(c3_gs, aes(x = VPDleaf, y = gsw, color = factor(ShrubID))) +
  geom_point()

# Remove outlier
c3_gs <- c3_gs %>%
  filter(gsw > -.025) %>%
  untibble()

# Ball Berry, fit single curve (to multiple individuals)
fit_bb <- fitBB(c3_gs, 
                varnames = list(ALEAF = "A",
                                GS = "gsw",
                                Ca = "Ca",
                                RH = "RHcham"),
                gsmodel = "BallBerry",
                fitg0 = TRUE)
names(fit_bb)
length(fit_bb)
summary(fit_bb$fit)
coef(fit_bb)

# Ball Berry Leuning, fit single curve (to multiple individuals)
fit_bbl <- fitBB(c3_gs, 
                varnames = list(ALEAF = "A",
                                GS = "gsw",
                                Ca = "Ca",
                                VPD = "VPDleaf"),
                gsmodel = "BBLeuning",
                fitg0 = TRUE,
                D0 = 1.6) # ED2 standard for C4 grasses, tropical trees. D0 = 1 kPa for temperate trees

summary(fit_bbl$fit)
coef(fit_bbl)

# Medlyn, fit single curve (to multiple individuals)
fit_m <- fitBB(c3_gs, 
                 varnames = list(ALEAF = "A",
                                 GS = "gsw",
                                 Ca = "Ca",
                                 VPD = "VPDleaf"),
                 gsmodel = "BBOpti",
                 fitg0 = TRUE) 

summary(fit_m$fit)
coef(fit_m)

# Medlyn, fit multiple curves example 
# (but does the data justify this?)
table(c3_gs$ShrubID)
# Probably too few points for many of these, but showing code example here anyhow 
fits_m <- fitBBs(c3_gs,
                  varnames = list(ALEAF = "A",
                                  GS = "gsw",
                                  Ca = "Ca",
                                  VPD = "VPDleaf"),
                  group = "ShrubID",
                  gsmodel = "BBOpti", # aka Medlyn model
                  fitg0 = TRUE)

names(fits_m) # 9 for 9 shrubs
summary(fits_m$'1'$fit)
coef(fits_m$'1')
