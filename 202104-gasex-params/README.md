# Fitting leaf-level gas exchange parameters

## Workshop presentation

[Slides](https://docs.google.com/presentation/d/1bRNAq2z-rFHGy9rxGCtrS779XMqqeGhLNWu48YY2_jc/edit?usp=sharing) are viewable by anyone at the University of Arizona. 

## Interactive RStudio Environment

Go to RStudio on [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/az-digitalag/binder-gas-exchange-workshop.git/main?urlpath=rstudio)

Software,data, and scripts needed in this workshop are already loaded. 

## Contents

All workshop data and code are contained in this repository:
-`data` Four subfolders of `ACi`, `AQ`, `Bayesian`, and `Gs` containing csv or ASCII files of Licor data (6800 and 6400)
-`scripts` Three scripts for fitting parameters:
  -`script_photo.R` Fitting CO2 and light response curves for C3 ('photosynthesis') and C4 ('BioCro')
  -`script_stomatal.R` Fitting stomatal slope and cuticular conductance ('plantecophys')
  -`script_Bayesian.R` Jointly fitting CO2 and light response curves for C3 ('PEcAn.photosynthesis')
  