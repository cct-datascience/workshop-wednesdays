# Native grass cover modeled as zero-or-1 inflated beta
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
y.temp <- with(dat, ifelse(native_grass == 0, 
                           native_grass, NA))
y.0 <- ifelse(is.na(y.temp), 0, 1)

# group discrete response + predictors
y.d <- y.temp[!is.na(y.temp)]
x.d <- X[y.0 == 1,]
n.0 <- length(y.d)
# block.d <- as.numeric(dat$block)[y.0 == 1]

# group continuous response + predictors
which.cont <- which(y.0 == 0)
y.c <- dat$native_grass[which.cont]
x.c <- X[which.cont,]
n.cont <- length(y.c)
block.c <- as.numeric(dat$block)[which.cont]

# Assemble model inputs
datlist <- list(N = nrow(dat),
                y.0 = y.0,
                # n.0 = n.0,
                # y.d = y.d, 
                fall = X[,2],
                spring = X[,3],
                herbicide = X[,4],
                greenstrip = X[,5],
                fall_herbicide = X[,6],
                spring_herbicide = X[,7],
                fall_greenstrip = X[,8],
                spring_greenstrip = X[,9],
                block = as.numeric(dat$block),
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
logit(median(base$native_grass))

# generate random initials
inits <- function(){
  list(a = rnorm(1, 0, 10),
       b = rnorm(ncol(X) - 1, 0, 10), 
       alpha = rnorm(1, 0, 10),
       beta = rnorm(ncol(X) - 1, 0, 10),
       tau = runif(1, 0, 1),
       tau.eps = runif(1, 0, 1),
       tau.eps.c = runif(1, 0, 1))
}
initslist <- list(inits(), inits(), inits())

# Or, use previous starting values + set seed
load("models/cover-native/inits/inits.Rdata")# saved.state, second element is inits
initslist <- list(append(saved.state[[2]][[1]], list(.RNG.name = array("base::Super-Duper"), .RNG.seed = array(13))),
                  append(saved.state[[2]][[2]], list(.RNG.name = array("base::Wichmann-Hill"), .RNG.seed = array(89))),
                  append(saved.state[[2]][[3]], list(.RNG.name = array("base::Mersenne-Twister"), .RNG.seed = array(18))))

# model
jm <- jags.model(file = "models/cover-native/Native_cover_zib.jags",
                 inits = initslist,
                 n.chains = 3,
                 data = datlist)
# update(jm, 10000)

# params to monitor
params <- c("deviance", # evaluate fit
            "a", "b", "alpha", "beta", # parameters
            "tau", "sig", # precision/variance terms
            "tau.eps", "sig.eps", "tau.eps.c", "sig.eps.c", 
            "a.star", "eps.star.c",# identifiable intercept and random effects
            "alpha.star", "eps.star",
            "Diff_b", "diff_b", "Diff_Beta", "diff_Beta", # differences
            "rho.ungrazed.control", "rho.ungrazed.herbicide", "rho.ungrazed.greenstrip",
            "rho.fall.control", "rho.fall.herbicide", "rho.fall.greenstrip",
            "rho.spring.control", "rho.spring.herbicide", "rho.spring.greenstrip",
            "m.ungrazed.control", "m.ungrazed.herbicide", "m.ungrazed.greenstrip",
            "m.fall.control", "m.fall.herbicide", "m.fall.greenstrip", 
            "m.spring.control", "m.spring.herbicide", "m.spring.greenstrip")
           

coda.out <- coda.samples(jm, variable.names = params,
                         n.iter = 5000, thin = 5)

# plot chains
mcmcplot(coda.out, parms = c("deviance", "b", "beta",
                             "a.star", "alpha.star",  
                             "eps.star", "eps.star.c",
                             "sig", "sig.eps", "sig.eps.c"))

caterplot(coda.out, parms = "eps.star", reorder = FALSE)
caterplot(coda.out, parms = "eps.star.c", reorder = FALSE)

caterplot(coda.out, parms = "b", reorder = FALSE)
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
# saved.state <- removevars(newinits, variables = c(2, 4, 7:29))
# saved.state[[1]]
# save(saved.state, file = "models/cover-native/inits/inits.Rdata")

save(coda.out, file = "models/cover-native/coda/coda.Rdata")
