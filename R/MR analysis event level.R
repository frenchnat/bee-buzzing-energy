# Load necessary libraries
library(lme4)
library(lmerTest)
library(DHARMa)
library(emmeans)
library(performance)
library(ggplot2)

# Load the dataset
data <- read.csv("C:/Users/labadmin/Documents/Uppsala analyses/data/filtered_df_with_colony_and_ITS.csv")

summary(data)
data$BeeID <- as.factor(data$BeeID)
data$event_type <- as.factor(data$event_type)
data$ColonyID <- as.factor(data$ColonyID)
summary(data)

# MR distribution
ggplot(data, aes(x = metabolic_rate_mL_h)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  theme_minimal() 

lmm1 <- lmer(metabolic_rate_mL_h ~ event_type + ColonyID + (1 | BeeID), data = data)
simulateResiduals(lmm1, plot = TRUE)

lmm2 <- lmer(log(metabolic_rate_mL_h) ~ event_type + ColonyID + (1 | BeeID), data = data)
simulateResiduals(lmm2, plot = TRUE)
summary(lmm2)
anova(lmm2, type = "II")

emmeans(lmm2, pairwise ~ event_type, type = "response")

icc(lmm2)

# Estimated marginal means on the log scale
em <- emmeans(lmm2, ~ event_type)

# Back-transform to original scale
em_trans <- summary(em, type = "response")  # uses exp() under the hood if response was log-transformed

p_mr <- ggplot(em_trans, aes(x = event_type, y = response)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2) +
  labs(
    x = "Event Type",
    y = "Metabolic Rate (mL/h)"
  ) +
  theme_minimal()
p_mr

# Subset your data for each behaviour
buzz_data <- subset(data, event_type == "buzz")
takeoff_data <- subset(data, event_type == "flight")

# Fit models separately
buzz_model <- lmer(log(metabolic_rate_mL_h) ~ ColonyID + (1 | BeeID), data = buzz_data)
takeoff_model <- lmer(log(metabolic_rate_mL_h) ~ ColonyID + (1 | BeeID), data = takeoff_data)

# Calculate ICCs
icc(buzz_model)
icc(takeoff_model)

