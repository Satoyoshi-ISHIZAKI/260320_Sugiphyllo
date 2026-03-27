#' Load All Utility Functions and Configuration
#' 
#' This file sources all utility functions and project configuration needed for microbiome analysis.
#' Run this at the start of any analysis script:
#'   source(here::here("R", "00_utils_load.R"))

# Required base packages
library(here)

# Load configuration (paths, parameters, settings)
source(here::here("config.R"))

# Source utility function files
source(here::here("R", "qiime2_import.R"))
source(here::here("R", "phyloseq_utilities.R"))

message("✓ Configuration and utility functions loaded successfully")
message("\n── PACKAGES LOADED ──")
message("  Core: phyloseq, qiime2R, vegan, ggplot2")
message("  Data: dplyr, tidyr, tibble, stringr")
message("  Utilities: here")

message("\n── CONFIGURATION ──")
message("Project: ", config$project$title)
message("Data directory: ", config$data$qiime2_dir)
message("Output directory: ", config$output$base)

message("\n── AVAILABLE FUNCTIONS ──")
message("  Data import:")
message("    - import_qiime2_data()  : Load QIIME2 outputs")
message("    - create_phyloseq()      : Assemble phyloseq object")
message("\n  Data manipulation:")
message("    - phyloseq_to_tibble()   : Convert to tidy long format")
message("    - filter_samples()       : Subset by metadata criteria")
message("    - remove_rare_taxa()     : Filter low-abundance taxa")
message("\n  Visualization:")
message("    - theme_microbiome()     : Publication-ready ggplot2 theme")
message("\n  Configuration:")
message("    - config               : List with all project settings")
message("    - get_config()          : Helper to access config values")
