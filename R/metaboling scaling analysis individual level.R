# Load libraries
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

# Prepare data
data_modelA <- data %>%
  filter(event_type %in% c("buzz", "flight")) %>%
  mutate(
    event_type = case_when(
      event_type == "buzz" ~ "buzz",
      event_type == "flight" ~ "take-off",
      TRUE ~ event_type
    ),
    log_MR = log(metabolic_rate_mL_h),
    log_weight = log(weight_g),
    log_ITS = log(ITS_mm),
    BeeID = as.factor(BeeID),
    ColonyID = as.factor(ColonyID)
  )

# Aggregate to individual-level averages per BeeID and event_type
individual_data <- data_modelA %>%
  group_by(BeeID, ColonyID, event_type) %>%
  summarise(
    avg_log_MR = mean(log_MR, na.rm = TRUE),
    avg_log_weight = mean(log_weight, na.rm = TRUE),
    avg_log_ITS = mean(log_ITS, na.rm = TRUE),
    .groups = "drop"
  )
summary(individual_data)

# Fit mixed model: log(MR) ~ log(weight)
model_individual <- lmer(avg_log_MR ~ avg_log_weight * event_type + ColonyID + (1 | BeeID),
                         data = individual_data)
summary(model_individual)
anova(model_individual, type = "III")
simulateResiduals(model_individual, plot = TRUE)

model_individual2 <- lmer(avg_log_MR ~ avg_log_weight + event_type + ColonyID + (1 | BeeID),
                         data = individual_data)
summary(model_individual2)
anova(model_individual2, type = "II")
simulateResiduals(model_individual2, plot = TRUE)

AIC(model_individual, model_individual2)

emmeans(model_individual2, pairwise ~ event_type, type = "response")

# Plot: log(MR) vs log(weight)
p1_individual <- ggplot(individual_data, aes(x = avg_log_weight, y = avg_log_MR, color = event_type, fill = event_type)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1.2) +
  labs(
    x = "log(Body mass, g)",
    y = "log(CO2 Metabolic rate, mL/h)",
    color = "Behaviour",
    fill = "Behaviour"
  ) +
  theme_classic(base_size = 14) +
  theme(legend.position = "none")

# Fit model: log(MR) ~ log(ITS)
model_individual_ITS <- lmer(avg_log_MR ~ avg_log_ITS * event_type + ColonyID + (1 | BeeID),
                             data = individual_data)
summary(model_individual_ITS)
anova(model_individual_ITS, type = "III")
simulateResiduals(model_individual_ITS, plot = TRUE)

model_individual_ITS2 <- lmer(avg_log_MR ~ avg_log_ITS + event_type + ColonyID + (1 | BeeID),
                             data = individual_data)
summary(model_individual_ITS2)
anova(model_individual_ITS2, type = "II")
simulateResiduals(model_individual_ITS2, plot = TRUE)

AIC(model_individual_ITS, model_individual_ITS2)

# Plot: log(MR) vs log(ITS)
p2_individual <- ggplot(individual_data, aes(x = avg_log_ITS, y = avg_log_MR, color = event_type, fill = event_type)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1.2) +
  labs(
    x = "log(Intertegular span, mm)",
    y = "log(CO2 Metabolic rate, mL/h)",
    color = "Behaviour",
    fill = "Behaviour"
  ) +
  theme_classic(base_size = 14) +
  theme(legend.position = "right")

# Combine plots
combined_individual_plot <- p1_individual + p2_individual +
  plot_layout(ncol = 2) +
  plot_annotation(tag_levels = "A")

# Save plot
ggsave("C:/Users/labadmin/Documents/Uppsala analyses/Manuscript/Figures/Figure2d.png",
       plot = combined_individual_plot, width = 12, height = 6)
