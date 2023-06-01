# Plotting script for `Foundations of ggplot2`
# Faceted plot with all points (grey) and faceted points(color)

library(tidyverse)
library(palmerpenguins)

ggplot(penguins, aes(x = body_mass_g,
                     y = flipper_length_mm)) +
  geom_point(data = dplyr::select(penguins, -species), color = "grey") +
  geom_point(aes(color = species)) +
  facet_wrap(~species)