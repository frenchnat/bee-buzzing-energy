# Required packages
library(car)
library(DHARMa)
library(emmeans)
library(ggplot2)
library(dplyr)
library(multcomp)
library(multcompView)  # for compact letter display (optional)
library(patchwork)  # for combining plots
library(glmmTMB)
library(performance)

df <- read.csv("C:/Users/labadmin/Documents/Uppsala analyses/mean_energy_per_bee.csv")
summary(df)

df$BeeID <- as.factor(df$BeeID)
df$colony_id <- as.factor(df$colony_id)
df$event_type <- as.factor(df$event_type)

### Mass-specific energy expenditure ###
# Distribution
hist(df$mean_energy_J_per_kg, breaks = 40, main = "Mass-specific Mean Energy Expenditure (J/kg)", xlab = "J/kg")

# Relationship
ggplot(df, aes(x = event_type, y = mean_energy_J_per_kg, fill = event_type)) +
  geom_boxplot(outlier.shape = NA, width = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  facet_wrap(~ colony_id) +
  labs(y = "Mass-specific Mean energy expenditure (J/kg)", x = "Event Type") +
  theme_minimal()

# Models
mod_mean_jkg <- glmmTMB(mean_energy_J_per_kg ~ event_type + colony_id + (1 | BeeID),
                        data = df,
                        family = Gamma(link = "log"))
simulateResiduals(mod_mean_jkg, plot = TRUE)
Anova(mod_mean_jkg, type = "II")

# Estimated marginal means for event_type
emm_event1 <- emmeans(mod_mean_jkg, ~ event_type)
emm_event_resp1 <- summary(emm_event1, type = "response")
emmeans(mod_mean_jkg, specs = ~ event_type, type = "response")
contrast_event1 <- pairs(emm_event1)
contrast_event1

# Plot
ee <- ggplot(emm_event_resp1, aes(x = event_type, y = response, color = event_type)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL), width = 0.2, size = 1) +
  scale_color_manual(values = c("buzz" = "#F8766D", "takeoff" = "#00BFC4")) +
  labs(
    x = "Behaviour",
    y = "Predicted mass-specific energy expenditure (J/kg)"
  ) +
  theme_classic(base_size = 13) +
  theme(legend.position = "none") +
  annotate("text", x = 1.5, y = 622, label = bquote("NS"~italic(p)==0.274), size = 4) +
  expand_limits(y = 0) + 
  scale_x_discrete(labels = c("buzz" = "buzz", "takeoff" = "take-off"))

ee


### Mass-specific power output ###
# Distribution
hist(df$mean_power_W_per_kg, breaks = 40, main = "Mass-specific Mean Power Output (W/kg)", xlab = "W/kg")

# Relationship
ggplot(df, aes(x = event_type, y = mean_power_W_per_kg, fill = event_type)) +
  geom_boxplot(outlier.shape = NA, width = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  facet_wrap(~ colony_id) +
  labs(y = "Mass-specific Mean Power Output (W/kg)", x = "Event Type") +
  theme_minimal()

# Models
mod_mean_wkg <- glmmTMB(mean_power_W_per_kg ~ event_type + colony_id + (1 | BeeID),
                        data = df,
                        family = Gamma(link = "log"))
simulateResiduals(mod_mean_wkg, plot = TRUE)
Anova(mod_mean_wkg, type = "II")

# Estimated marginal means for event_type
emm_event <- emmeans(mod_mean_wkg, ~ event_type)
emm_event_resp <- summary(emm_event, type = "response")
emmeans(mod_mean_wkg, specs = ~ event_type, type = "response")
contrast_event <- pairs(emm_event)
contrast_event

# Plot
po <- ggplot(emm_event_resp, aes(x = event_type, y = response, color = event_type)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL), width = 0.2, size = 1) +
  scale_color_manual(values = c("buzz" = "#F8766D", "takeoff" = "#00BFC4")) +
  labs(
    x = "Behaviour",
    y = "Predicted mass-specific power output (W/kg)"
  ) +
  theme_classic(base_size = 13) +
  theme(legend.position = "none") +
  annotate("text", x = 1.5, y = 422, label = bquote("*"~italic(p)==0.037), size = 4) +
  expand_limits(y = 0) + 
  scale_x_discrete(labels = c("buzz" = "buzz", "takeoff" = "take-off"))

po

# Combine with shared legend above
combined_plot_ee_po <- ee + po +
  plot_layout(ncol = 2, guides = "collect") +
  plot_annotation(tag_levels = "A")
combined_plot_ee_po

# Save to file
ggsave("C:/Users/labadmin/Documents/Uppsala analyses/Manuscript/Figures/Figure3.png",
       combined_plot_ee_po,
       width = 10, height = 5, dpi = 300)
