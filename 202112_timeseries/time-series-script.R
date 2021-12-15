### Script for time series workshop, 12/15/2021

# Load packages
library(forecast) # range of tools for analysis and viz of timeseries data
library(dplyr) # part of tidyverse, data wrangling
library(lubridate) # part of tidyverse, dates and times
library(broom) # part of tidyverse, cleans model output
library(daymetr) # pulls down historical weather data

# Simulate data
days <- 0:9
mass <- vector(length = 10)
seq_along(days) # outputs index of each element of the vector

for(t in seq_along(days)) { # for loop to generate mass data with some error
  mass[t] <- 1 + 2 * days[t] + rnorm(1, mean = 0, sd = 1)
}


linear_data <- data.frame(day = days, mass = mass)
plot(mass~day, 
     data = linear_data)

mod_linear <- lm(mass ~ 1 + days, data = linear_data) # specifies the intercept
tidy(mod_linear)

# Predict function
newdays <- 10:15
newdat <- data.frame(days = newdays)
preds <- predict(mod_linear, 
                 newdata = newdat)
plot(mass~day, 
     data = linear_data,
     ylab = "mass (g)",
     ylim = c(0, 30),
     xlim = c(0, 15))
points(newdays, preds, col = "red")
abline(coef(mod_linear)) 
abline(confint(mod_linear)[,1], lty = 2)
abline(confint(mod_linear)[,2], lty = 2)

# Simulate a time series
set.seed(211) # recreate the same time series
months <- 1:240

noise <- rnorm(length(months), mean = 0, sd = 1)
lag <- vector(length = length(months))
for(t in 1:length(months)) {
  if(t == 1) {
    lag[t] <- rnorm(1, mean = 0, sd = 1)
  } else {
    lag[t] <- (lag[t-1] + noise[t])/2
  }
}

lag_trend <- lag + months/48

seasonal <- 2 * sin(2 * pi * months / 12) + noise

seasonal_trend <- seasonal + months/48

# Create time series object
all <- ts(
  data = data.frame(noise, lag, lag_trend, seasonal, seasonal_trend),
  start = 1982,
  end = 2001,
  frequency = 12)
class(all) # matrix type is all numeric

methods(class = "ts")

plot(all)

# Examine lags at 1, 3, 6, and 9 months
lag.plot(all, set.lags = c(1, 3, 6, 9))

# Autocorrelation plot - x axis is automatically in year
acf(all[, 'noise'])
acf(all[, 'lag'])
acf(all[, 'seasonal'])

# Plot the seasonal trend
plot(all[,'seasonal_trend'])

# decompose in to seasonal, trend, and noise components using moving averages
# can be additive or multiplicative
?decompose
dec <- decompose(all[,'seasonal_trend'])
class(dec)
summary(dec)
plot(dec)

# The random component of the time series - is it influenced by twigs floating by?
twigs <- rpois(n = length(dec$random), lambda = 4)
hist(twigs)
mean(twigs)

tidy(lm(dec$random ~ twigs))

# Is the trend related to time (months)
tidy(lm(dec$trend ~ months))
length(dec$trend)
length(months)
# different lengths, decomposed time series is shorter
tidy(lm(dec$trend ~ months[1:length(dec$trend)]))


# stl function uses a weighted average
seasonal_stl <- stl(all[,'seasonal_trend'], s.window = 6)
plot(seasonal_stl)
dim(seasonal_stl$time.series)
dim(all)
# the seasonal trend is unique for each year, unlike with `decompose()`

# Forecasting
# Fitting predictive models
# 'tslm' or time series linear model
ts_fit <- tslm(all[,'seasonal_trend'] ~ trend + season)
tidy(ts_fit)

# forecast() works like predict() but with a tslm object
plot(forecast(ts_fit, h = 20))
