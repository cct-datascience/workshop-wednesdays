# Fitting leaf-level gas exchange parameters
# Workshop Wednesdays, April 28, 2021
# Jessica Guo & Kristina Riemer

# Simultaneous fitting of ACi and AQ curves in a Bayesian framework
# Currently for C3 only
# Load and clean data for fitting

library(PEcAn.photosynthesis)

## AQ and ACi 6400 data, ASCII format
file_names <- list.files("../data/Bayesian")
file_paths <- paste0("../data/Bayesian/", file_names)
tot <- lapply(file_paths, read_Licor) # read in as a list of 2 Licor files
# Combine into single dataframe
both <- do.call(rbind, tot)

# Fit CO2 and light response curves simultaneously
fitBayes <- fitA(both)

str(fitBayes)
plot(fitBayes$params, auto.layout = FALSE)   
summary(fitBayes$params)
