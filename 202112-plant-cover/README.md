## Modeling plant abundance data

This repository contains an introduction to Bayesian modeling of two kinds of plant abundance data, counts and cover. Plant abundance data are commonly collected as part of vegetation surveys, but due to the clumped nature of plant distributions, can be difficult to model with frequentist tools. Common features include many zeros, non-normality, overdispersion, etc. 

Thus, the models presented here are not simple or straightforward. They include:
1) A Poisson model of count with observation-level random effects nested within block random effects
2) A zero/one inflated beta model of cover with block random effects



### File structure
`Exploring_plant_abundance.Rmd` is a summary of data exploration that informed the Bayesian models and published [here](https://viz.datascience.arizona.edu/content/a10f297c-5740-42c2-b88a-a5b8bbe16a3e/Exploring_plant_abundance.html). 

`data/` contains separate csv files of count and cover

`models/` contains 3 models:
  - `count-invasive/` contains the control and model script for invasive grass counts
  - `cover-invasive/` contains the control and model script for invasive grass cover
  - `cover-native/` contains the control, model, and plotting script for native grass cover
  
Each model folder also contains .Rdata files of the starting values at convergence `inits.Rdata` and the posterior chains `coda.Rdata`. 

### Requirements
The models run in [JAGS](https://mcmc-jags.sourceforge.io/) using the R packages 'rjags', 'coda', 'mcmcplots', 'tidyverse', and optionally, 'broom.mixed', 'ggthemes', and 'cowplot'. 


This repository can be run remotely using [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/az-digitalag/binder-plant-cover/main?urlpath=rstudio)

Note that changes made in the Binder instance must be downloaded in order to be saved. 

