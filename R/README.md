# R/ - Utility Functions and Helpers

This folder contains reusable R functions for the microbiome analysis pipeline.

## Required Packages

All utility files automatically load their dependencies when sourced. Required packages:

**Core microbiome packages:**
- `phyloseq` — Microbiome data structures
- `qiime2R` — QIIME2 format import

**Data manipulation:**
- `dplyr` — Data frame operations
- `tidyr` — Data reshaping
- `tibble` — Modern data frames
- `stringr` — String manipulation

**Analysis:**
- `vegan` — Diversity indices and multivariate analysis
- `ggplot2` — Visualization

**Utilities:**
- `here` — Reproducible file paths

Install all dependencies:
```r
install.packages(c("phyloseq", "qiime2R", "dplyr", "tidyr", "tibble", 
                   "stringr", "vegan", "ggplot2", "here"), 
                 dependencies = TRUE)
```

## Files

### `00_utils_load.R`
Master loader file. Source this at the beginning of any analysis script to load all utility functions:
```r
source(here::here("R", "00_utils_load.R"))
```

### `qiime2_import.R`
Functions for importing QIIME2 output files:

- **`import_qiime2_data()`** — Load OTU table, taxonomy, phylogenetic tree, and metadata in one call
  ```r
  qiime2_data <- import_qiime2_data(
    qiime2_dir = "data/Analysis",
    marker = "16S",
    metadata_path = "data/Metadata/samplesheet_Sugi.csv"
  )
  ```

- **`create_phyloseq()`** — Assemble components into a phyloseq object
  ```r
  physeq <- create_phyloseq(qiime2_data)
  ```

### `phyloseq_utilities.R`
Data manipulation and visualization helpers:

- **`phyloseq_to_tibble()`** — Convert phyloseq to tidy long-format tibble for ggplot2
  ```r
  df <- phyloseq_to_tibble(physeq, abund_type = "relative", taxa_level = "Genus")
  ```

- **`filter_samples()`** — Subset samples by metadata criteria
  ```r
  physeq_summer <- filter_samples(physeq, Season == "Summer")
  ```

- **`remove_rare_taxa()`** — Filter low-abundance taxa
  ```r
  physeq_filt <- remove_rare_taxa(physeq, min_count = 50, min_prevalence = 0.05)
  ```

- **`theme_microbiome()`** — Publication-ready ggplot2 theme
  ```r
  ggplot(data, aes(x, y)) + 
    geom_point() + 
    theme_microbiome(base_size = 12)
  ```

## Quick Start Example

```r
# Load utilities
source(here::here("R", "00_utils_load.R"))

# Import QIIME2 data in one line
qiime2_data <- import_qiime2_data(
  qiime2_dir = "data/Analysis",
  marker = "16S",
  metadata_path = "data/Metadata/samplesheet_Sugi.csv"
)

# Create phyloseq object
physeq <- create_phyloseq(qiime2_data)

# Filter and explore
physeq_filt <- remove_rare_taxa(physeq, min_count = 50, min_prevalence = 0.05)

# Convert to tidy format for visualization
df <- phyloseq_to_tibble(physeq_filt, abund_type = "relative", taxa_level = "Phylum")

# Plot with custom theme
ggplot(df, aes(x = Sample, y = Abundance, fill = Taxon)) +
  geom_col() +
  theme_microbiome() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

## Development Notes

- All functions include roxygen2-style documentation (`#'`) for easy help lookup
- Functions return informative messages about data filtering/processing steps
- Required packages: `phyloseq`, `qiime2R`, `tidyverse`, `vegan`
- File naming: Functions are organized by topic (qiime2, phyloseq) with numeric prefix for load order
