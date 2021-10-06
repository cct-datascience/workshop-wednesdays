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
dat <- read.csv("data/cover.csv")

# model matrix
X <- model.matrix( ~ grazing * fuelbreak, data = dat) 
colnames(X)

# split the data into discrete and continuous components
y.temp <- with(dat, ifelse(invasive_grass == 1 | invasive_grass == 0, 
                           invasive_grass, NA))
y.discrete <- ifelse(is.na(y.temp), 0, 1)

# group discrete response + predictors
y.d <- y.temp[!is.na(y.temp)]
x.d <- X[y.discrete == 1,]
n.discrete <- length(y.d)
block.d <- as.numeric(dat$block)[y.discrete == 1]

# group continuous response + predictors
which.cont <- which(y.discrete == 0)
y.c <- dat$invasive_grass[which.cont]
x.c <- X[which.cont,]
n.cont <- length(y.c)
block.c <- as.numeric(dat$block)[which.cont]

# Assemble model inputs
datlist <- list(N = nrow(dat),
                y.discrete = y.discrete,
                n.discrete = n.discrete,
                y.d = y.d, 
                fall = x.d[,2],
                spring = x.d[,3],
                herbicide = x.d[,4],
                greenstrip = x.d[,5],
                fall_herbicide = x.d[,6],
                spring_herbicide = x.d[,7],
                fall_greenstrip = x.d[,8],
                spring_greenstrip = x.d[,9],
                block.d = block.d,
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
jm <- jags.model(file = "models/cover-invasive/Invasive_cover_zoib.jags",
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


# Model fit
params <- c("y.discrete.rep", "y.d.rep", "y.c.rep") #monitor replicated data
coda.rep <- coda.samples(jm, variable.names = params,
                         n.iter = 15000, thin = 5)

