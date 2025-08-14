# Load libraries
library(glmmTMB)
library(lme4)
library(lmerTest)
library(emmeans)
library(DHARMa)
library(dplyr)
library(MuMIn)
library(ggplot2)
library(ggeffects)
library(broom)
library(patchwork)

# Load dataset
data <- read.csv("C:/Users/labadmin/Documents/Uppsala analyses/data/filtered_df_with_colony_and_ITS.csv")
summary(data)
data$BeeID <- as.factor(data$BeeID)
data$event_type <- as.factor(data$event_type)
data$ColonyID <- as.factor(data$ColonyID)

ggplot(data, aes(x = dt)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  theme_minimal() 

# Relationships
ggplot(data, aes(x = event_type, y = dt, fill = event_type)) +
  geom_violin(trim = FALSE, alpha = 0.3) +
  geom_boxplot(width = 0.1, outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.2) +
  scale_fill_manual(values = c("buzz" = "#F8766D", "flight" = "#00BFC4")) +
  labs(x = "Event Type", y = "Bout duration (s)") +
  theme_minimal(base_size = 13)

ggplot(data, aes(x = ColonyID, y = dt, fill = ColonyID)) +
  geom_violin(trim = FALSE, alpha = 0.3) +
  geom_boxplot(width = 0.1, outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.2) +
  labs(x = "Colony ID", y = "Bout duration (s)") +
  theme_minimal(base_size = 13)

mod_gamma <- glmmTMB(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = Gamma(link = "log"),
  data = data
)
simulateResiduals(mod_gamma, plot = TRUE)

mod_gamma2 <- glmmTMB(
  dt ~ event_type * ColonyID + (1 | BeeID),
  family = Gamma(link = "log"),
  data = data
)
simulateResiduals(mod_gamma2, plot = TRUE)

mod_tweedie <- glmmTMB(
  dt ~ event_type * ColonyID + (1 | BeeID),
  family = tweedie(link = "log"), 
  data = data
)
simulateResiduals(mod_tweedie, plot = TRUE)

mod_tweedie_simple <- glmmTMB(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = tweedie(link = "log"),
  data = data
)
simulateResiduals(mod_tweedie_simple, plot = TRUE)

mod_check <- glmmTMB(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = tweedie(link = "log"),
  data = data
)

parameters <- mod_check$fit$par
names(parameters)

mod_tweedie_fixed <- glmmTMB(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = tweedie(link = "log"),
  data = data,
  map = list(psi = factor(NA)),       # Fix power parameter
  start = list(psi = log(1.5))        # Set p = 1.5 (in log scale)
)
simulateResiduals(mod_tweedie_fixed, plot = TRUE)

library(brms)

# Gamma model
brm_gamma <- brm(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = Gamma(link = "log"),
  data = data,
  chains = 4, cores = 4
)
summary(brm_gamma)

brm_lognorm <- brm(
  dt ~ event_type + ColonyID + (1 | BeeID),
  family = lognormal(),
  data = data,
  chains = 4, cores = 4
)
summary(brm_lognorm)

# Compare models
loo(brm_lognorm, brm_gamma)

# Posterior predictive checks
pp_check(brm_gamma)

# Coefficient summaries
summary(brm_gamma)

## Final model: brm_lognorm