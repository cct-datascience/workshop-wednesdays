# Plotting output from Native cover model

# Plot model outputs and fit
library(coda)
library(broom.mixed)
library(dplyr)
library(ggplot2)
library(cowplot)

# logit and antilogit functions
logit <- function(x) {
  log(x/(1-x))
}
ilogit <- function(x){
  exp(x) / (1 + exp(x))
}

# read in data
dat <- read.csv("data/cover.csv") %>% 
  mutate(grazing = factor(grazing, levels = c("ungrazed",
                                              "fall", 
                                              "spring")),
         fuelbreak = factor(fuelbreak, levels = c("control",
                                                  "herbicide", 
                                                  "greenstrip")))


# Load coda and coda.rep
load(file = "models/cover-native/coda/coda.Rdata") # coda.out

# summarize
sum.out <- tidyMCMC(coda.out, 
                    conf.int = TRUE,
                    conf.level = 0.95) %>%
  mutate(sig = ifelse(conf.low * conf.high > 0, TRUE, FALSE),
         dir = ifelse(sig == FALSE, NA, 
                      ifelse(sig == TRUE & estimate > 0, "pos", "neg")))

#### Create output figures
# All bs
b.labs <- c("fall", "spring", "herbicide", "greenstrip", 
               "fall:herbicide", "spring:herbicide", "fall:greenstrip", "spring:greenstrip")
bs <- filter(sum.out, grepl("^b\\[", term))
fig1a <- ggplot() +
  geom_pointrange(data = bs, 
                  aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high),
                  size = 0.5) +
  geom_point(data = subset(bs, sig == TRUE),
             aes(x = term, y = min(bs$conf.low) - 0.1, col = dir),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous("b terms") +
  scale_x_discrete(labels = b.labs) +
  scale_color_manual(values = c("goldenrod", "forestgreen")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x = element_blank()) +
  guides(color = "none")

# All betas
beta.labs <- c("fall", "spring", "herbicide", "greenstrip", 
               "fall:herbicide", "spring:herbicide", "fall:greenstrip", "spring:greenstrip")
betas <- filter(sum.out, grepl("^beta\\[", term))
fig1b <- ggplot() +
  geom_pointrange(data = betas, 
                  aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high),
                  size = 0.5) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous("Beta terms") +
  scale_x_discrete(labels = beta.labs) +
  # scale_color_manual(values = c("goldenrod", "forestgreen")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x = element_blank()) +
  guides(color = "none")

plot_grid(fig1a, fig1b, ncol = 1, labels = letters)


# Random effects
labs <- c("Block 1", "Block 2", "Block 3")
prob.eps <- filter(sum.out, grepl("eps.star\\[", term))
fig2a <- ggplot(prob.eps, aes(x = term, y = estimate)) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 0, color = "red", lty = 2) +
  theme_bw() +
  scale_x_discrete(labels = labs) +
  scale_y_continuous("Random effect") +
  theme(axis.title.x = element_blank())

prob.eps.c <- filter(sum.out, grepl("eps.star.c\\[", term))
fig2b <- ggplot(prob.eps.c, aes(x = term, y = estimate)) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 0, color = "red", lty = 2) +
  theme_bw() +
  scale_x_discrete(labels = labs) +
  scale_y_continuous("Random effect") +
  theme(axis.title.x = element_blank())

plot_grid(fig2a, fig2b, ncol = 1, labels = letters)


# Calculate total interactions
# convert to probability of absence (b)
# convert to % cover (beta)

labs1 <- c("fall", "spring", "herbicide", "greenstrip")
labs2 <- c("fall:herbicide", "spring:herbicide", 
                    "fall:greenstrip", "spring:greenstrip")
b_main <- filter(sum.out, grepl("Diff\\_b", term))
beta_main <- filter(sum.out, grepl("Diff\\_Beta", term))
b_int <- filter(sum.out, grepl("diff\\_b", term))
beta_int <- filter(sum.out, grepl("diff\\_Beta", term))

fig_3a <- ggplot() +
  geom_pointrange(data = b_main, 
                  aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high),
                  size = 0.5) +
  geom_point(data = subset(b_main, sig == TRUE),
             aes(x = term, y = min(conf.low) - 0.05, col = as.factor(dir)),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, "Probability of absence"))) +
  scale_x_discrete(limits = rev(b_main$term), labels = rev(labs1)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")

fig_3b <- ggplot() +
  geom_pointrange(data = b_int, 
                  aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high),
                  size = 0.5) +
  geom_point(data = subset(b_int, sig == TRUE),
             aes(x = term, y = min(conf.low) - 0.05, col = as.factor(dir)),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, "Probability of absence"))) +
  scale_x_discrete(limits = rev(b_int$term), labels = rev(labs2)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")

fig_3c <- ggplot() +
  geom_pointrange(data = beta_main, 
                  aes(x = term, y = estimate*100, 
                      ymin = conf.low*100, 
                      ymax = conf.high*100),
                  size = 0.5) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, " % cover"))) +
  scale_x_discrete(limits = rev(beta_main$term), labels = rev(labs1)) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank())

fig_3d <- ggplot() +
  geom_pointrange(data = beta_int, 
                  aes(x = term, y = estimate*100, 
                      ymin = conf.low*100, 
                      ymax = conf.high*100),
                  size = 0.5) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, " % cover"))) +
  scale_x_discrete(limits = rev(beta_int$term), labels = rev(labs2)) +
  scale_color_manual(values = c("forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")

plot_grid(fig_3a, fig_3b, fig_3c, fig_3d, ncol = 2, labels = letters)
