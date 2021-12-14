# Invasive grass cover modeled as zero-or-1 inflated beta
# cover proportions collected on 1x1 m quadrats

library(rjags)
load.module('dic')
library(mcmcplots)
library(ggplot2)
library(dplyr)

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

# model matrix
X <- model.matrix( ~ grazing * fuelbreak, data = dat) 
colnames(X)

# split the data into 0 and continuous components
y.temp <- with(dat, ifelse(invasive_grass == 0, 
                           invasive_grass, NA))
y.0 <- ifelse(is.na(y.temp), 0, 1)

# group discrete response + predictors
y.d <- y.temp[!is.na(y.temp)]
x.d <- X[y.0 == 1,]
n.0 <- length(y.d)
# block.d <- as.numeric(dat$block)[y.0 == 1]

# group continuous response + predictors
which.cont <- which(y.0 == 0)
y.c <- dat$invasive_grass[which.cont]
x.c <- X[which.cont,]
n.cont <- length(y.c)
block.c <- as.numeric(dat$block)[which.cont]

# Assemble model inputs
datlist <- list(N = nrow(dat),
                y.0 = y.0,
                n.cont = n.cont,
                y.c = y.c,
                fall2 = x.c[,2],
                spring2 = x.c[,3],
                herbicide2 = x.c[,4],
                greenstrip2 = x.c[,5],
                fall_herbicide2 = x.c[,6],
                spring_herbicide2 = x.c[,7],
                fall_greenstrip2 = x.c[,8],
                spring_greenstrip2 = x.c[,9],
                block.c = block.c,
                Nb = length(unique(dat$block)),
                nL = ncol(X) - 1)

# likely intercept value
base <- dat %>%
  filter(grazing == "ungrazed",
         fuelbreak == "control")
logit(median(base$invasive_grass))

# generate random initials
inits <- function(){
  list(alpha = rnorm(1, 0, 10),
       beta = rnorm(ncol(X) - 1, 0, 10),
       tau = runif(1, 0, 1),
       tau.eps = runif(1, 0, 1),
       rho = runif(1, 0, 1))
}
initslist <- list(inits(), inits(), inits())

# Or, use previous starting values + set seed
load("models/cover-invasive/inits/inits.Rdata")# saved.state, second element is inits
initslist <- list(append(saved.state[[2]][[1]], list(.RNG.name = array("base::Super-Duper"), .RNG.seed = array(13))),
                  append(saved.state[[2]][[2]], list(.RNG.name = array("base::Wichmann-Hill"), .RNG.seed = array(89))),
                  append(saved.state[[2]][[3]], list(.RNG.name = array("base::Mersenne-Twister"), .RNG.seed = array(18))))

# model
jm <- jags.model(file = "models/cover-invasive/Invasive_cover_zib.jags",
                 inits = initslist,
                 n.chains = 3,
                 data = datlist)
# update(jm, 10000)

# params to monitor
params <- c("deviance", # evaluate fit
            "rho", "alpha", "beta", # parameters
            "tau", "sig", "tau.eps", "sig.eps", # precision/variance terms
            "alpha.star", "eps.star") # identifiable intercept and random effects
           

coda.out <- coda.samples(jm, variable.names = params,
                         n.iter = 5000, thin = 5)

# plot chains
mcmcplot(coda.out, parms = c("deviance", "rho", "beta",
                             "alpha.star",  "eps.star", 
                             "sig", "sig.eps"))

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
# saved.state <- removevars(newinits, variables = c(2, 4, 6:7))
# saved.state[[1]]
# save(saved.state, file = "models/cover-invasive/inits/inits.Rdata")

save(coda.out, file = "models/cover-invasive/coda/coda.Rdata")
