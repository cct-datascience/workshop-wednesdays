# If necessary, install packages

if(FALSE) {
  install.packages("palmerpenguins")
  install.packages("dplyr")
  install.packages("ggplot2")
}

# Load packages
library(palmerpenguins)
library(dplyr)
library(ggplot2)

data(penguins)

# Show the top of the `penguins` data frame

head(penguins)

# Calculate average trait measures per species per island

penguins_traits <- penguins |>
  group_by(species, island) |>
  summarize(across(c(ends_with("mm"), ends_with("g")), function(x) mean(x, na.rm = T)))

penguins_traits

# Quarto challenge: Show these tables in the document and supply table legends.
# Quarto challenge: Hide the code that produces these tables.

# Plot density smooths of trait measures per species per island

ggplot(penguins, aes(bill_length_mm, color = species, fill = species)) +
  geom_density(alpha = .4) +
  facet_wrap(vars(island), ncol = 1) +
  theme(legend.position = "bottom") +
  ggtitle("Bill length")


ggplot(penguins, aes(bill_depth_mm, color = species, fill = species)) +
  geom_density(alpha = .4) +
  facet_wrap(vars(island), ncol = 1) +
  theme(legend.position = "bottom") +
  ggtitle("Bill depth")


ggplot(penguins, aes(flipper_length_mm, color = species, fill = species)) +
  geom_density(alpha = .4) +
  facet_wrap(vars(island), ncol = 1) +
  theme(legend.position = "bottom") +
  ggtitle("Flipper length")


ggplot(penguins, aes(body_mass_g, color = species, fill = species)) +
  geom_density(alpha = .4) +
  facet_wrap(vars(island), ncol = 1) +
  theme(legend.position = "bottom") +
  ggtitle("Body mass")

# Quarto challenge: Add figure labels to these plots.

# Quarto challenge: Write a short blurb about these results and reference the figures and tables.


# Quarto challenge: Feature a picture of the penguins.
# Artwork of the penguins (by Allison Horst) available for download here: https://allisonhorst.github.io/palmerpenguins/articles/art.html
# Make sure to attribute Allison!