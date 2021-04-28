# Fitting leaf-level gas exchange parameters
# Workshop Wednesdays, April 28, 2021
# Jessica Guo & Kristina Riemer

# Load and clean data for fitting
library(dplyr)
library(ggplot2)
library(photosynthesis)
library(udunits2)
library(BioCro)

# Function
untibble <- function(tibble) {
  data.frame(unclass(tibble),
             check.names = FALSE,
             stringsAsFactors = FALSE)
}

## ACi 6800 for C3

# Read in for column names
cnames <- readr::read_csv("data/ACi/PIPO_20190823.csv", skip = 13, n_max = 0) %>%
  names()
# Read in data and rename columns
c3_aci <- readr::read_csv("data/ACi/PIPO_20190823.csv", skip = 16, col_names = cnames)

# Plot
ggplot(c3_aci, aes(x = Ci, y = A)) +
  geom_point()

# Round Qin and convert units on Tleaf
c3_aci$Q_2 <- as.factor(round(c3_aci$Qin, digits = 0))
c3_aci$T_leaf <- ud.convert(c3_aci$Tleaf, "Celsius", "Kelvin")
c3_aci <- untibble(c3_aci)

fit <- fit_aci_response(c3_aci[c3_aci$Q_2 == 1500, ],
                        varnames = list(A_net = "A",
                                        T_leaf = "T_leaf",
                                        C_i = "Ci",
                                        PPFD = "Qin"),
                        fitTPU = FALSE)
fit[[1]]
fit[[2]]


# C4
c4_aci <- readr::read_csv("data/ACi/SEVI_20200304.csv")
c4_aq <- readr::read_csv("data/AQ/SEVI_20200304.csv")

# plot
ggplot(c4_aci, aes(x = Ci, y = A, color = factor(rep))) +
  geom_point()

ggplot(c4_aq, aes(x = Qin, y = A, color = factor(rep))) +
  geom_point()

# Format for optimization function
df <- data.frame(A = c(c4_aci$A, c4_aq$A),
                 Qin = c(c4_aci$Qin, c4_aq$Qin), 
                 Tleaf = c(c4_aci$Tleaf, c4_aq$Tleaf), 
                 RH = c(c4_aci$RHcham/100, c4_aq$RHcham/100), 
                 Ci = c(c4_aci$Ci, c4_aq$Ci))
# Fit Collatz model
fit_c4 <- Opc4photo(df)
fit_c4


# Light Response Curve
c4_aq <- readr::read_csv("data/AQ/SEVI_20200304.csv")
# Group by CO2
c4_aq$C_s <- (round(c4_aq$CO2_s, digits = 0))

# Fit single curve (to multiple individuals)
fit2 <- fit_aq_response(untibble(c4_aq[c4_aq$C_s == 400, ]), 
                       varnames = list(A_net = "A",
                                       PPFD = "Qin"))
summary(fit2[[1]])
fit2[[2]]
fit2[[3]]

# Fit multiple curves
fits <- fit_many(data = untibble(c4_aq),
                 varnames = list(A_net = "A",
                                 PPFD = "Qin",
                                 group = "rep"),
                 funct = fit_aq_response,
                 group = "rep")
length(fits)
names(fits)
summary(fits[[1]][[1]])
fits[[1]][[3]]
