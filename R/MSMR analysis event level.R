# Load necessary libraries
library(lme4)
library(lmerTest)
library(emmeans)
library(DHARMa)
library(performance)
library(ggplot2)

# Load the dataset
data <- read.csv("C:/Users/labadmin/Documents/Uppsala analyses/data/filtered_df_with_colony_and_ITS.csv")

summary(data)
data$BeeID <- as.factor(data$BeeID)
data$event_type <- as.factor(data$event_type)
data$ColonyID <- as.factor(data$ColonyID)
summary(data)
colnames(data)

# MSMR distribution
ggplot(data, aes(x = mass_specific_mL_g_h)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  theme_minimal() 

ggplot(data, aes(x = weight_g, y = log(mass_specific_mL_g_h), color = event_type)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "loess", se = TRUE) +
  facet_wrap(~ ColonyID) +
  theme_minimal()

ggplot(data, aes(x = ITS_mm, y = log(mass_specific_mL_g_h), color = event_type)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "loess", se = TRUE) +
  facet_wrap(~ ColonyID) +
  theme_minimal()

ggplot(data, aes(x = event_type, y = log(mass_specific_mL_g_h))) +
  geom_violin(trim = FALSE, fill = "lightblue") +
  geom_jitter(width = 0.1, alpha = 0.3) +
  facet_wrap(~ ColonyID)

# Models
model <- lmer(mass_specific_mL_g_h ~ event_type + ColonyID + (1 | BeeID), data = data)
sim_res <- simulateResiduals(model, plot = TRUE)

model_log <- lmer(log(mass_specific_mL_g_h) ~ event_type + ColonyID + (1 | BeeID), data = data)
simulateResiduals(model_log, plot = TRUE)
summary(model_log)
anova(model_log, type = "II")

icc(model_log)  # for mass-specific metabolic rate

emmeans(model_log, pairwise ~ event_type, type = "response")

aggregate(weight_g ~ ColonyID, data = data, FUN = mean)


emm <- emmeans(model_log, ~ event_type)
summary(emm)
contrast(emm, method = "pairwise", adjust = "none")  # No multiple testing correction needed here

emm_df <- as.data.frame(summary(emm, type = "response"))

p_msmr <- ggplot(emm_df, aes(x = event_type, y = response)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2) +
  labs(x = "Event Type", y = "Mass-Specific Metabolic Rate (mL/g/h)") +
  theme_minimal(base_size = 14)
p_msmr

# Subset your data for each behaviour
buzz_data <- subset(data, event_type == "buzz")
takeoff_data <- subset(data, event_type == "flight")

# Fit models separately
buzz_model <- lmer(log(mass_specific_mL_g_h) ~ ColonyID + (1 | BeeID), data = buzz_data)
takeoff_model <- lmer(log(mass_specific_mL_g_h) ~ ColonyID + (1 | BeeID), data = takeoff_data)

# Calculate ICCs
icc(buzz_model)
icc(takeoff_model)

# Create a unique bee-level dataset
bee_data <- data[!duplicated(data$BeeID), c("BeeID", "weight_g", "ITS_mm", "ColonyID")]

aggregate(weight_g ~ ColonyID, data = bee_data, FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
aggregate(ITS_mm ~ ColonyID, data = bee_data, FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))

# Fit body mass model and test
mass_model_bee <- lm(weight_g ~ ColonyID, data = bee_data)
anova(mass_model_bee)
simulateResiduals(mass_model_bee, plot = TRUE)

# Load multcomp for compact letter display (optional)
library(multcomp)

# Run Tukey HSD
tukey_results <- TukeyHSD(aov(mass_model_bee))
print(tukey_results)

# Fit body size model and test
size_model_bee <- lm(ITS_mm ~ ColonyID, data = bee_data)
anova(size_model_bee)
simulateResiduals(size_model_bee, plot = TRUE)

# Run Tukey HSD
tukey_results_size <- TukeyHSD(aov(size_model_bee))
print(tukey_results_size)

msmr_model_cov2 <- lmer(log(mass_specific_mL_g_h) ~ event_type + ColonyID + weight_g + ITS_mm + (1 | BeeID), data = data)
anova(msmr_model_cov2, type = "II")
simulateResiduals(msmr_model_cov2, plot = TRUE)

library(car)
vif(lm(log(mass_specific_mL_g_h) ~ event_type + ColonyID + weight_g + ITS_mm, data = data))
