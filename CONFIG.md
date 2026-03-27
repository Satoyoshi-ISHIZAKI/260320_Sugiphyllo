# config.R - Project Configuration

Centralized configuration file for all paths, parameters, and settings. Update this file once instead of modifying hardcoded values throughout your scripts.

## Structure

```r
config <- list(
  data = list(...)           # Input data paths
  output = list(...)         # Output directory paths
  analysis = list(...)       # Analysis parameters (thresholds, methods)
  theme = list(...)          # Visualization settings
  project = list(...)        # Project metadata
)
```

## Usage in Scripts

### Option 1: Load everything
```r
source(here::here("R", "00_utils_load.R"))
# This loads config + all utility functions
```

### Option 2: Load only config
```r
source(here::here("config.R"))
qiime2_dir <- config$data$qiime2_dir
output_dir <- config$output$figures
```

### Option 3: Use helper function
```r
source(here::here("config.R"))
qiime2_dir <- get_config("data", "qiime2_dir")
```

## Common Customizations

### Update marker genes
```r
config$analysis$markers <- c("16S", "ITS_paired")
```

### Adjust rarefaction depth
```r
config$analysis$rarefaction_depth$"16S" <- 5000
```

### Change figure output size
```r
config$theme$fig_width <- 12
config$theme$fig_height <- 8
```

## Path Substitution Patterns

The configuration assumes your directory structure matches the initial setup:
```
260320_Sugiphyllo/
├── config.R              # This configuration file
├── data/
│   ├── Analysis/         # QIIME2 results
│   └── Metadata/         # Sample metadata
├── results/              # Output directory (auto-created)
│   ├── figures/
│   ├── tables/
│   └── cached/
└── R/
    └── 00_utils_load.R
```

### To use external data sources:

Uncomment and modify in `config.R`:
```r
external_drive = "G:/マイドライブ/Rproject",
sample_sheet_external = "G:/マイドライブ/samplesheet"
```

Then use in scripts:
```r
external_data_path <- config$data$external_drive
```

## Sensitive Information

⚠️ **IMPORTANT**: Keep `config.R` in `.gitignore` if it contains:
- Personal paths (e.g., external drive locations)
- API keys or credentials
- Institution-specific settings

Check [.gitignore](.gitignore) to verify it's excluded.

## Example: Complete Analysis Setup

```r
# At the start of any analysis script
source(here::here("R", "00_utils_load.R"))

# All of these now work:
qiime2_dir <- config$data$qiime2_dir
output_figs <- config$output$figures
min_count <- config$analysis$filter_rare$min_count
rarefaction_depth <- config$analysis$rarefaction_depth[["16S"]]

# Import and process data
qiime2_data <- import_qiime2_data(
  qiime2_dir = qiime2_dir,
  marker = "16S",
  metadata_path = config$data$metadata
)

physeq <- create_phyloseq(qiime2_data)
physeq_filt <- remove_rare_taxa(physeq, 
                                min_count = min_count,
                                min_prevalence = 0.05)

# Save results to configured paths
saveRDS(physeq_filt, file.path(config$output$cached, "physeq_16S_filtered.rds"))
```

See [01_setup.R](../scripts/01_setup.R) for a complete example of a setup script that uses this configuration.
