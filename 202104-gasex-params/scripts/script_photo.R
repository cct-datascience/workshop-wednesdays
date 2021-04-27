# Fitting leaf-level gas exchange parameters
# Workshop Wednesdays, April 28, 2021
# Jessica Guo & Kristina Riemer

# Load and clean data for fitting
library(dplyr)
library(ggplot2)
library(plantecophys)
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
cnames <- readr::read_csv("../data/ACi/ARTR_20200312.csv", skip = 13, n_max = 0) %>%
  names()
# Read in data and rename columns
c3_aci <- readr::read_csv("../data/ACi/ARTR_20200312.csv", skip = 16, col_names = cnames)
# Split into list by ID
c3_aci_list <- split(c3_aci, f = c3_aci$ID)

ggplot(c3_aci, aes(x = Ca, y = A, color = factor(ID))) +
  geom_point()

# Round Qin and convert units on Tleaf
test <- c3_aci_list[[1]]
test$Q_2 <- as.factor(round(test$Qin, digits = 0))
test$T_leaf <- ud.convert(test$Tleaf, "Celsius", "Kelvin")
test <- untibble(test)

fit <- fit_aci_response(test[test$Q_2 == 1500, ],
                        varnames = list(A_net = "A",
                                        T_leaf = "T_leaf",
                                        C_i = "Ci",
                                        PPFD = "Qin"),
                        fitTPU = FALSE)
fit[[1]]
fit[[2]]

# Perform for many curves
c3_aci <- c3_aci %>%
  mutate(Q_2 = as.factor(round(Qin, digits = 0)),
         T_leaf = ud.convert(Tleaf, "Celsius", "Kelvin"))

fits <- fit_many(data = untibble(c3_aci),
                 varnames = list(A_net = "A",
                                 T_leaf = "T_leaf",
                                 C_i = "Ci",
                                 PPFD = "Qin"),
                 funct = fit_aci_response,
                 group = "Q_2")

# C4
c4_aci <- readr::read_csv("../data/ACi/SEVI_20200304.csv")
c4_aq <- readr::read_csv("../data/AQ/SEVI_20200304.csv")
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


# Light Response Curve
c4_aq <- readr::read_csv("../data/AQ/SEVI_20200304.csv")
# Group by CO2
c4_aq$C_s <- (round(c4_aq$CO2_s, digits = 0))

fit <- fit_aq_response(untibble(c4_aq[c4_aq$C_s == 400, ]), 
                       varnames = list(A_net = "A",
                                       PPFD = "Qin"))
summary(fit[[1]])
fit[[2]]
fit[[3]]

# Fit multiple curves
fits <- fit_many(data = untibble(c4_aq),
                 varnames = list(A_net = "A",
                                 PPFD = "Qin",
                                 group = "rep"),
                 funct = fit_aq_response,
                 group = "rep")
length(fits)
names(fits)
fits[[1]][[1]]
