# Required packages
library(car)
library(lmerTest)
library(DHARMa)
library(emmeans)
library(ggplot2)
library(dplyr)
library(multcomp)
library(multcompView)  # for compact letter display (optional)
library(patchwork)  # for combining plots

# Load the tidy dataset
df <- read.csv("C:/Users/labadmin/Documents/Uppsala analyses/bee_nectar_energy_by_individual.csv")
summary(df)
df$bee_id <- as.factor(df$bee_id)
df$colony_id <- as.factor(df$colony_id)
df$event_type <- as.factor(df$event_type)
df$flower_type <- as.factor(df$flower_type)

#Models
mod <- lmer(nectar_volume_ul ~ body_mass_mg * flower_type * event_type + colony_id + (1|bee_id), data = df)
summary(mod)
Anova(mod, type = "3")
drop1(mod)

mod2 <- lmer(nectar_volume_ul ~ body_mass_mg + flower_type + event_type
           + body_mass_mg:flower_type
           + body_mass_mg:event_type
           + flower_type:event_type
           + colony_id + (1|bee_id)
             , data = df)
summary(mod2)
Anova(mod2, type = "3")
drop1(mod2)

mod3 <- lmer(nectar_volume_ul ~ body_mass_mg + flower_type + event_type
           + body_mass_mg:event_type
           + flower_type:event_type
           + colony_id + (1|bee_id)
           , data = df)
summary(mod3)
Anova(mod3, type = "3")
drop1(mod3)
simulateResiduals(mod3, plot = TRUE)

mod4 <- lmer(nectar_volume_ul ~ body_mass_mg + flower_type + event_type
           + body_mass_mg:event_type
           + colony_id + (1|bee_id)
           , data = df)
summary(mod4)
Anova(mod4, type = "3")
drop1(mod4)

mod5 <- lmer(nectar_volume_ul ~ body_mass_mg + flower_type + event_type + colony_id + (1|bee_id)
           , data = df)
summary(mod5)
Anova(mod5, type = "2")
simulateResiduals(mod5, plot = TRUE)
drop1(mod5, test = "Chisq")

MuMIn::r.squaredGLMM(mod5)

plot(resid(mod5) ~ fitted(mod5))

# Get marginal means
emm_flower <- emmeans(mod5, specs = "flower_type")
pairwise_flower <- pairs(emm_flower, adjust = "tukey")
summary(pairwise_flower)

emm_event <- emmeans(mod5, ~ event_type)
pairwise_event <- pairs(emm_event, adjust = "none")
summary(pairwise_event)

