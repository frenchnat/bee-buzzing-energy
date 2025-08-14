# R scripts for analyses and figures

Run these after the Python notebooks have created inputs in `data/processed/`.

- `MR analysis event level.R` — event-level metabolic rate analyses (V̇CO₂; mass-specific rates).
- `MSMR analysis event level.R` — mixed-effects models for mass-specific metabolic rates.
- `metaboling scaling analysis individual level.R` — body-size scaling and individual-level summaries.
- `mean energy expenditure and power output analyses.R` — computes energy (J) and power (W/kg) per event.
- `nectar volume analysis.R` — converts energy usage to nectar volume requirements.
- `dt analysis.R` — duration/transition analyses.

Outputs are written to `figures/` and `results/`. Check the top of each script for any paths/settings.
