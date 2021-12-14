# Cheatgrass counts modeled as Poisson distribution
# Overdispersed, so using observation-level RE nested within block RE

library(rjags)
load.module('dic')
library(mcmcplots)
library(ggplot2)
library(dplyr)

# Read in data
dat <- read.csv("data/count.csv") %>% 
  mutate(grazing = factor(grazing, levels = c("ungrazed",
                                              "fall", 
                                              "spring")),
         fuelbreak = factor(fuelbreak, levels = c("control",
                                                  "herbicide", 
                                                  "greenstrip")))

# Find start and end indices for each block
tapply(as.numeric(row.names(dat)), dat$block, range)

# model matrix
X <- model.matrix( ~ grazing * fuelbreak, data = dat) 
colnames(X)

# Standard deviation among paddocks and blocks
log(sd(tapply(dat$invasive_grass, dat$block, FUN = mean)))

# Assemble model inputs
datlist <- list(counts = dat$invasive_grass,
                area = dat$quadrat/100, # convert to square decimeters
                N = nrow(dat),
                fall = X[,2],
                spring = X[,3],
                herbicide = X[,4],
                greenstrip = X[,5],
                fall_herbicide = X[,6],
                spring_herbicide = X[,7],
                fall_greenstrip = X[,8],
                spring_greenstrip = X[,9],
                nL = ncol(X) - 1, # number of offset levels
                block = as.numeric(dat$block),
                Nb = length(unique(dat$block)),
                Ab = 5) # stand deviation among paddocks and blocks

# Calculate likely intercept value
base <- dat %>%
  filter(grazing == "ungrazed",
         fuelbreak == "control")
log(median(base$invasive_grass))

# Generate random initials for all root nodes
inits <- function(){
  list(alpha = rnorm(1, 0, 10),
       beta = rnorm(ncol(X) - 1, 0, 10),
       tau.Eps = runif(1, 0, 1),
       tau = runif(1, 0, 1))
}
initslist <- list(inits(), inits(), inits())

# Or, use previous starting values + set seed
load("models/count-invasive/inits/inits.Rdata")# saved.state, second element is inits
initslist <- list(append(saved.state[[2]][[1]], list(.RNG.name = array("base::Super-Duper"), .RNG.seed = array(13))),
                  append(saved.state[[2]][[2]], list(.RNG.name = array("base::Wichmann-Hill"), .RNG.seed = array(89))),
                  append(saved.state[[2]][[3]], list(.RNG.name = array("base::Mersenne-Twister"), .RNG.seed = array(18))))

# model
jm <- jags.model(file = "models/count-invasive/Invasive_counts_PoissonOLRE.jags",
                 inits = initslist,
                 n.chains = 3,
                 data = datlist)
# update(jm, 1000)

# params to monitor
params <- c("deviance", "Dsum", # evaluate fit
            "alpha", "beta", # ANOVA parameters
            "tau.Eps", "sig.eps", # precision/variance terms for block RE 
            "tau", "sig", # precision/variance terms for OLRE
            "alpha.star", "eps.star") # identifiable intercept and block RE
            

coda.out <- coda.samples(jm, variable.names = params,
                         n.iter = 100000, thin = 50)

# plot chains
mcmcplot(coda.out, parms = c("deviance", "Dsum", "beta",
                             "alpha.star",  "eps.star", "sig.eps", 
                             "sig"))
traplot(coda.out, parms = "beta")
traplot(coda.out, parms = "alpha.star")
traplot(coda.out, parms = "sig.eps")
traplot(coda.out, parms = "sig")
traplot(coda.out, parms = "eps.star")

caterplot(coda.out, parms = "eps.star", reorder = FALSE)
caterplot(coda.out, parms = "beta", reorder = FALSE)

# dic samples
dic.out <- dic.samples(jm, n.iter = 5000)
dic.out

# convergence?
gel <- gelman.diag(coda.out, multivariate = FALSE)
gel

# If not converged, restart model from final iterations
# newinits <-  initfind(coda.out)
# newinits[[1]]
# saved.state <- removevars(newinits, variables = c(1, 3, 5:7))
# saved.state[[1]]
# save(saved.state, file = "models/count-invasive/inits/inits.Rdata")

save(coda.out, file = "models/count-invasive/coda/coda_OLRE.Rdata")
