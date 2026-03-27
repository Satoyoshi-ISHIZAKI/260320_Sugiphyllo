# Results Directory

This folder contains all analysis outputs organized by type.

## Subdirectories

### `figures/`
Publication-ready plots and visualizations.
- **Purpose**: Store final figures for presentations, papers, and reports
- **Format**: PNG, PDF, or SVG preferred for publication
- **Naming**: Use descriptive names with analysis type (e.g., `alpha_diversity_boxplot.png`, `beta_diversity_pcoa_16S.pdf`)

### `tables/`
Data tables and summary statistics for supplementary materials or excel export.
- **Purpose**: Spreadsheet-ready outputs, contingency tables, differential abundance results
- **Format**: CSV, TSV, or XLSX
- **Naming**: Descriptive names indicating content (e.g., `taxonomy_summary_16S.csv`, `differential_abundance_ANCOMBC.csv`)

### `cached/`
Processed R objects for workflow efficiency.
- **Purpose**: Cache intermediate phyloseq objects, processed data frames, and model results
- **Format**: `.rds` (R serialized objects)
- **Naming**: Include processing stage (e.g., `phyloseq_16S_decontaminated.rds`, `alpha_div_results.rds`)
- **Usage**: Load with `readRDS()` to skip redundant processing steps

## Suggested Workflow

1. Generate figures → `figures/`
2. Export tables → `tables/`
3. Save phyloseq objects mid-analysis → `cached/`
4. `.gitignore` includes this directory to keep repo size small (raw data stored separately)
