# Plot model outputs and fit
library(postjags)
library(ggplot2)
library(dplyr)
library(cowplot)

# logit and antilogit functions
logit <- function(x) {
  log(x/(1-x))
}
ilogit <- function(x){
  exp(x) / (1 + exp(x))
}

# Read in raw data
load("../../../cleaned_data/cover_all.Rdata") # cover_all
# convert to proportions
dat <- cover_all %>%
  mutate(BRTE = BRTE/100,
         intro_forbs = intro_forbs/100,
         native_grass = native_grass/100,
         native_forbs = native_forbs/100)
str(dat)

# Load coda and coda.rep
load(file = "coda/coda.Rdata") # coda.out
load(file = "coda/coda_rep.Rdata") # coda.rep


# summarize
sum.out <- coda.fast(coda.out, OpenBUGS = FALSE)
sum.out$var <- row.names(sum.out)
sum.out$sig <- ifelse(sum.out$pc2.5*sum.out$pc97.5 > 0, TRUE, FALSE)
sum.out$dir <- ifelse(sum.out$sig == FALSE, NA, 
                      ifelse(sum.out$sig == TRUE & sum.out$mean > 0, "pos", "neg"))


#### Create output figures
# All betas
beta.labs <- c("fall", "spring", "herbicide", "greenstrip", 
               "fall:herbicide", "spring:herbicide", "fall:greenstrip", "spring:greenstrip")
beta.ind <- grep("beta", row.names(sum.out))
betas <- sum.out[beta.ind,]
betas$var <- factor(betas$var, levels = row.names(betas))
str(betas)
fig1 <- ggplot() +
  geom_pointrange(data = betas, 
                  aes(x = var, y = mean, ymin = pc2.5, ymax = pc97.5),
                  size = 0.5) +
  geom_point(data = subset(betas, sig == TRUE),
             aes(x = var, y = min(pc2.5) - 0.1, col = dir),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(beta))) +
  scale_x_discrete(labels = beta.labs) +
  scale_color_manual(values = c("forestgreen", "purple")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x = element_blank()) +
  guides(color = "none")

jpeg(filename = "plots/fig1_betas2.jpg", 
     width = 6, 
     height = 3, 
     units = "in",
     res = 600)
print(fig1)
dev.off()

# Random effects
labs <- c("Block 1", "Block 2", "Block 3")
prob.eps <- grep("eps.star", row.names(sum.out))
ggplot(sum.out[prob.eps,], aes(x = var, y = mean)) +
  geom_pointrange(aes(ymin = pc2.5, ymax = pc97.5)) +
  geom_hline(yintercept = 0, color = "red", lty = 2) +
  scale_x_discrete(labels = labs)

# Only main effect betas
beta.labs2 <- c("fall", "spring", "herbicide", "greenstrip")
beta.ind <- grep("beta", row.names(sum.out))
betas <- sum.out[beta.ind[1:length(beta.labs2)],]
betas$var <- factor(betas$var, levels = row.names(betas))
str(betas)
fig_1a <- ggplot() +
  geom_pointrange(data = betas, 
                  aes(x = var, y = mean, ymin = pc2.5, ymax = pc97.5),
                  size = 0.5) +
  geom_point(data = subset(betas, sig == TRUE),
             aes(x = var, y = min(pc2.5) - 0.1, col = dir),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(beta))) +
  scale_x_discrete(limits = rev(levels(betas$var)), labels = rev(beta.labs2)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")
fig_1a

# Calculate interactions
beta.labs.ints <- c("fall:herbicide", "spring:herbicide", 
                    "fall:greenstrip", "spring:greenstrip")
beta.int.ind <- grep("int_Beta", row.names(sum.out))
beta.ints <- sum.out[beta.int.ind,]
beta.ints$var <- factor(beta.ints$var, levels = row.names(beta.ints))
str(beta.ints)
fig_1b <- ggplot() +
  geom_pointrange(data = beta.ints, 
                  aes(x = var, y = mean, ymin = pc2.5, ymax = pc97.5),
                  size = 0.5) +
  geom_point(data = subset(beta.ints, sig == TRUE),
             aes(x = var, y = min(pc2.5) - 0.1, col = dir),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(sum(beta))) +
  scale_x_discrete(limits = rev(levels(beta.ints$var)), labels = rev(beta.labs.ints)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")
fig_1b

jpeg(filename = "plots/fig1_betas.jpg", 
     width = 6, 
     height = 4, 
     units = "in",
     res = 600)
plot_grid(fig_1a, fig_1b, ncol = 2, rel_widths = c(4, 5), labels = "auto")
dev.off()

# Convert to % cover differences (main and interaction effects)
alph <- sum.out[grep("alpha.star", row.names(sum.out)),]
ilogit(alph[,1:5])

beta.labs2 <- c("fall", "spring", "herbicide", "greenstrip")
beta.ind <- grep("Diff_Beta", row.names(sum.out))
betas <- sum.out[beta.ind[1:length(beta.labs2)],]
betas$var <- factor(betas$var, levels = row.names(betas))
str(betas)
fig_2a <- ggplot() +
  geom_pointrange(data = betas, 
                  aes(x = var, y = mean, ymin = pc2.5, ymax = pc97.5),
                  size = 0.5) +
  geom_point(data = subset(betas, sig == TRUE),
             aes(x = var, y = min(pc2.5) - 0.01, col = as.factor(dir)),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, "BRTE proportion cover"))) +
  scale_x_discrete(limits = rev(levels(betas$var)), labels = rev(beta.labs2)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")

beta.labs.ints <- c("fall:herbicide", "spring:herbicide", 
                    "fall:greenstrip", "spring:greenstrip")
beta.int.ind <- grep("diff_Beta", row.names(sum.out))
beta.ints <- sum.out[beta.int.ind,]
beta.ints$var <- factor(beta.ints$var, levels = row.names(beta.ints))
str(beta.ints)
fig_2b <- ggplot() +
  geom_pointrange(data = beta.ints, 
                  aes(x = var, y = mean, ymin = pc2.5, ymax = pc97.5),
                  size = 0.5) +
  geom_point(data = subset(beta.ints, sig == TRUE),
             aes(x = var, y = min(pc2.5) - .01, col = as.factor(dir)),
             shape = 8) +
  geom_hline(yintercept = 0, lty = 2) +
  scale_y_continuous(expression(paste(Delta, "BRTE proportion cover"))) +
  scale_x_discrete(limits = rev(levels(beta.ints$var)), labels = rev(beta.labs.ints)) +
  scale_color_manual(values = c("goldenrod3", "forestgreen")) +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  guides(color = "none")
fig_2b

jpeg(filename = "plots/fig2_betas.jpg", 
     width = 8, 
     height = 6, 
     units = "in",
     res = 600)
plot_grid(fig_2a, fig_2b, ncol = 2, rel_widths = c(4, 5), labels = "auto")
dev.off()


# Replicated data summary and fit
sum.rep <- coda.fast(coda.rep, OpenBUGS = FALSE)
dis.rep <- sum.rep[grep("y.d.rep", row.names(sum.rep)),]
cont.rep <- sum.rep[grep("y.c.rep", row.names(sum.rep)),]

#align
y.temp <- with(dat, ifelse(BRTE == 1 | BRTE == 0, BRTE, NA))
y.discrete <- ifelse(is.na(y.temp), 0, 1)
which.dis <- which(y.discrete == 1)
which.cont <- which(y.discrete == 0)


fit <- rbind.data.frame(cbind(dat[which.dis, ],
                              mean = dis.rep$mean,
                              median = dis.rep$median,
                              lower = dis.rep$pc2.5,
                              upper = dis.rep$pc97.5),
                        cbind(dat[which.cont, ],
                              mean = cont.rep$mean,
                              median = cont.rep$median,
                              lower = cont.rep$pc2.5,
                              upper = cont.rep$pc97.5)
)

fit.model <- lm(mean ~ BRTE, data = fit)
summary(fit.model)

ggplot(fit, aes(x = BRTE)) +
  geom_abline(slope = 1, intercept = 0, col = "red", lty = 2) +
  geom_errorbar(aes(ymin = lower, ymax = upper)) +
  geom_point(aes(y = mean))
