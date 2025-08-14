# First direct quantification of floral handling costs in bees

Repository containing the data, analysis workflows, and figure code for the manuscript:

> **First direct quantification of floral handling costs in bees**  
> Authors: Natacha Rossi, Mario Vallejo-Marín, Elizabeth Nicholls

**Corresponding author:** Natacha Rossi — natasha.rossi@hotmail.fr  
**ORCID:** 0000-0002-3631-9019

---

## What’s in here (and how it fits together)

- **data/**  
  - `raw/` → raw datasets (uploaded here when < 100 MB per file).  
  - `processed/` → intermediate files produced by notebooks.
- **notebooks/** → Python notebooks used to process raw data into analysis-ready tables.  
- **R/** → R scripts that run the statistical analyses and generate the **figures/tables** used in the paper.  
- **figures/** and **results/** → outputs created by the R scripts.

> Figures come from **R scripts**. Notebooks are for **data processing**.

---

## Replication statement

This repository contains everything required to reproduce the analyses and figures from the manuscript, starting from the raw data.

- **Experimental units & sample sizes (as analysed):**  
  21 bees from 3 colonies (≈ 260 floral buzzes; ≈ 213 take-offs). 

- **Inputs & access:**  
  Raw data are provided in `data/raw/` when file sizes permit.  
  If any file exceeds GitHub’s 100 MB limit, it is provided via an external DOI and noted in `data/raw/README_data.txt`.

- **Computing environment:**  
  Python **3.11.13** (Windows 10 Enterprise) for data processing (notebooks).  
  R (version as in Methods of the manuscript) for statistical analyses and figures.

- **Randomness:**  
  No global seed declared here. If any script sets a seed, it is documented within that script/notebook.

- **Manual steps:**  
  Any interactive checks (e.g., verifying event detection) are noted in the relevant notebook/script.

---

## How to reproduce the results

1) **Get the data**
- If data files are present in `data/raw/`, you’re set.  
- If a file is referenced via DOI in `data/raw/README_data.txt`, download it and place it in `data/raw/` with the exact filename indicated.

2) **Run the Python preprocessing (notebooks)**
- Use Python **3.11.13**.  
- Open each notebook in `notebooks/` and run top-to-bottom to create processed files in `data/processed/`.  
  **Suggested order:**
  1. `synchronising signal detection.ipynb`  
  2. `floral buzz extraction.ipynb`  
  3. `plot CO2 buzzing takeoff.ipynb`  
  4. `metabolic rates computation.ipynb`  
  5. `respiratory quotient analysis.ipynb`  
  6. `stpd corrected metabolic rates.ipynb`  
  7. `compute energy from VCO2 and RQ.ipynb`  
  8. `nectar volume computation.ipynb`

3) **Run the R analyses and produce figures**
- Open the scripts in `R/` and run them (e.g., in RStudio), making sure any input paths point to `data/processed/`.  
  Typical workflow:
  - event-level metabolic analyses (`MR analysis event level.R`, `MSMR analysis event level.R`)
  - scaling and individual-level summaries (`metaboling scaling analysis individual level.R`)
  - energy and power outputs (`mean energy expenditure and power output analyses.R`)
  - duration/transition analyses (`dt analysis.R`)
  - nectar calculations (`nectar volume analysis.R`)
- Figures and tables will be written to `figures/` and `results/`.

---

## Data availability

- Small files (< 100 MB each): stored directly in `data/raw/`.  
- Large files: hosted externally (e.g., Zenodo) and linked via DOI in `data/raw/README_data.txt`.

After this GitHub repository is public, it will be archived on Zenodo and its DOI added here.

---

## Citation

Please cite:
- The manuscript (full reference once available).
- The archived snapshot of this repository (Zenodo DOI to be added after release).

---

## Contact

Questions or issues? Open a GitHub Issue or email **natasha.rossi@hotmail.fr**.
