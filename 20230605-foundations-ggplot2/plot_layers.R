# Plotting script for `Foundations of ggplot2`
# Layered plot with geom_point() and stat_summary(), 2 ways

library(tidyverse)
library(palmerpenguins)
library(multcompView)

#### Make 2-layer plot with stat_summary ####
# First with raw data input

ggplot(data = penguins %>%
         filter(!is.na(sex)),
       mapping = aes(x = species, 
                     y = body_mass_g,
                     color = sex)) +
  geom_point(alpha = 0.15,
             position = position_jitterdodge()) +
  stat_summary(fun = mean,
               fun.min = function(x) mean(x) - sd(x),
               fun.max = function(x) mean(x) + sd(x),
               position = position_dodge(width = 0.75))
# geom_text(data = cld_df, 
#           mapping = aes(x = species,
#                         y = 6000,
#                         group = sex,
#                         label = letter),
#           hjust = 0.5,
#           position = position_dodge(width = 0.75),
#           color = "black")


# Second by calcluating means and sd
peng_sum <- penguins %>%
  filter(!is.na(sex)) %>%
  group_by(species, sex) %>%
  summarize(body_mass_mean = mean(body_mass_g),
            body_mass_sd = sd(body_mass_g))

ggplot() +
  geom_point(data = penguins %>% filter(!is.na(sex)),
             mapping = aes(x = species,
                           y = body_mass_g,
                           color = sex),
             position = position_jitterdodge(),
             alpha = 0.15) +
  geom_pointrange(data = peng_sum,
                  mapping = aes(x = species,
                                y = body_mass_mean,
                                ymin = body_mass_mean - body_mass_sd,
                                ymax = body_mass_mean + body_mass_sd,
                                color = sex),
                  position = position_dodge(width = 0.75))

#### Conduct ANOVA and add letters ####

# Run two-way ANOVA and get letters
m1 <- aov(body_mass_g ~ species * sex, data = penguins)
cld <- multcompLetters4(m1, TukeyHSD(m1))

# Create dataframe for plot
cld_df <- data.frame(letter = cld$`species:sex`$Letters) %>%
  tibble::rownames_to_column("name") %>%
  mutate(species = word(name, start = 1, sep = ":"),
         sex = word(name, start = 2, sep = ":")) %>%
  select(-name)

# Join to summary dataframe
peng_sum <- peng_sum %>%
  left_join(cld_df, by = c("species", "sex"))

# Add as layer to figure

ggplot() +
  geom_point(data = penguins %>% filter(!is.na(sex)),
             mapping = aes(x = species,
                           y = body_mass_g,
                           color = sex),
             position = position_jitterdodge(),
             alpha = 0.15) +
  geom_pointrange(data = peng_sum,
                  mapping = aes(x = species,
                                y = body_mass_mean,
                                ymin = body_mass_mean - body_mass_sd,
                                ymax = body_mass_mean + body_mass_sd,
                                color = sex),
                  position = position_dodge(width = 0.75)) +
  geom_text(data = peng_sum,
            mapping = aes(x = species,
                          y = body_mass_mean + body_mass_sd,
                          label = letter,
                          group = sex),
            position = position_dodge(width = 0.75),
            vjust = -1)
