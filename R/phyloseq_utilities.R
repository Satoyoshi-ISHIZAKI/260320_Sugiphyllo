# ============================================================================
# Phyloseq Utility Functions
# ============================================================================

# Required packages
library(phyloseq)
library(vegan)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(stringr)

#' Convert Phyloseq Object to Tidy Data Frame
#'
#' Converts phyloseq OTU table, taxonomy, and metadata into a long-format 
#' tibble suitable for tidy data analysis and ggplot2 visualization.
#'
#' @param physeq phyloseq object
#' @param abund_type Character. Type of abundance data: "counts", "relative", or "clr" (centered log-ratio).
#'                    Default: "relative"
#' @param taxa_level Character or NULL. Taxonomic rank to aggregate to (e.g., "Phylum", "Family", "Genus").
#'                   If NULL, uses ASV-level data. Default: NULL
#'
#' @return Tibble with columns: Sample, Abundance, OTU_ID (or taxa_level), Taxonomy (all ranks),
#'         and all sample metadata
#'
#' @examples
#' \dontrun{
#'   df_tidy <- phyloseq_to_tibble(physeq, abund_type = "relative", taxa_level = "Genus")
#'   ggplot(df_tidy, aes(x = Sample, y = Abundance, fill = Genus)) +
#'     geom_col()
#' }
#'
#' @importFrom phyloseq otu_table tax_table sample_data
#' @export
phyloseq_to_tibble <- function(physeq, abund_type = "relative", taxa_level = NULL) {
  
  # Extract components
  otu <- as.data.frame(phyloseq::otu_table(physeq))
  tax <- as.data.frame(phyloseq::tax_table(physeq))
  metadata <- as.data.frame(phyloseq::sample_data(physeq))
  
  # Normalize abundances if requested
  if (abund_type == "relative") {
    otu <- vegan::decostand(t(otu), method = "total")
    otu <- t(otu)
  } else if (abund_type == "clr") {
    # Centered log-ratio transformation (robust to zero counts)
    otu <- apply(otu + 0.5, 2, function(x) log(x / exp(mean(log(x)))))
  }
  
  # Add OTU/ASV IDs as column
  otu$OTU_ID <- rownames(otu)
  
  # Combine with taxonomy
  otu_tax <- otu %>%
    dplyr::left_join(tax %>% tibble::tibble(OTU_ID = rownames(.)), by = "OTU_ID")
  
  # Pivot to long format
  df_long <- otu_tax %>%
    tidyr::pivot_longer(
      cols = -c(OTU_ID, dplyr::all_of(colnames(tax))),
      names_to = "Sample",
      values_to = "Abundance"
    )
  
  # Add metadata
  df_long <- df_long %>%
    dplyr::left_join(
      metadata %>% tibble::tibble(Sample = rownames(.)),
      by = "Sample"
    )
  
  # Aggregate to taxa level if specified
  if (!is.null(taxa_level)) {
    if (!taxa_level %in% colnames(tax)) {
      stop(taxa_level, " not found in taxonomy. Available levels: ", 
           paste(colnames(tax), collapse = ", "))
    }
    
    df_long <- df_long %>%
      dplyr::group_by(Sample, {{ taxa_level }}, dplyr::across(dplyr::starts_with(c("Sample_", "Population")))) %>%
      dplyr::summarise(Abundance = sum(Abundance, na.rm = TRUE), .groups = "drop") %>%
      dplyr::rename(Taxon = {{ taxa_level }})
  }
  
  return(dplyr::as_tibble(df_long))
}


#' Custom Microbiome ggplot2 Theme
#'
#' Publication-ready ggplot2 theme optimized for microbiome visualizations.
#' Includes clean aesthetics with larger fonts and minimal gridlines.
#'
#' @param base_size Numeric. Base font size in points. Default: 12
#' @param legend_position Character. Legend position: "right", "left", "top", "bottom", "none". 
#'                        Default: "right"
#'
#' @return ggplot2 theme object
#'
#' @examples
#' \dontrun{
#'   ggplot(data, aes(x, y)) +
#'     geom_point() +
#'     theme_microbiome(base_size = 14)
#' }
#'
#' @export
theme_microbiome <- function(base_size = 12, legend_position = "right") {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      # Panel and background
      panel.grid.major = ggplot2::element_line(colour = "grey90", size = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      
      # Axes
      axis.line = ggplot2::element_line(colour = "grey40", size = 0.4),
      axis.ticks = ggplot2::element_line(colour = "grey40", size = 0.4),
      axis.text = ggplot2::element_text(colour = "grey30", face = "plain"),
      axis.title = ggplot2::element_text(colour = "grey20", face = "bold", size = rel(1.2)),
      
      # Legend
      legend.position = legend_position,
      legend.title = ggplot2::element_text(face = "bold"),
      legend.background = ggplot2::element_rect(fill = "transparent", colour = NA),
      legend.key = ggplot2::element_rect(fill = "transparent", colour = NA),
      
      # Plot title and subtitle
      plot.title = ggplot2::element_text(face = "bold", size = rel(1.3), hjust = 0, margin = ggplot2::margin(b = 5)),
      plot.subtitle = ggplot2::element_text(size = rel(1), colour = "grey40", hjust = 0),
      
      # Strip (facet labels)
      strip.text = ggplot2::element_text(face = "bold", size = rel(1))
    )
}


#' Filter Phyloseq Object by Sample Characteristics
#'
#' Subset phyloseq object based on sample metadata criteria.
#'
#' @param physeq phyloseq object
#' @param ... Conditions to filter by (same syntax as dplyr::filter)
#'
#' @return Filtered phyloseq object
#'
#' @examples
#' \dontrun{
#'   # Keep only samples from 2023
#'   physeq_2023 <- filter_samples(physeq, Year == 2023)
#' }
#'
#' @export
filter_samples <- function(physeq, ...) {
  metadata <- as.data.frame(phyloseq::sample_data(physeq))
  keep_samples <- metadata %>%
    dplyr::filter(...) %>%
    rownames()
  
  physeq_filtered <- phyloseq::prune_samples(keep_samples, physeq)
  message("Filtered to ", nsamples(physeq_filtered), " samples (from ", nsamples(physeq), ")")
  
  return(physeq_filtered)
}


#' Remove Low-Abundance Taxa
#'
#' Filter out rare taxa based on minimum abundance thresholds.
#'
#' @param physeq phyloseq object
#' @param min_count Numeric. Minimum total count across all samples. Default: 10
#' @param min_prevalence Numeric between 0-1. Minimum proportion of samples where taxa must appear.
#'                       Default: 0.01 (1% of samples)
#'
#' @return Filtered phyloseq object
#'
#' @examples
#' \dontrun{
#'   physeq_filt <- remove_rare_taxa(physeq, min_count = 50, min_prevalence = 0.05)
#' }
#'
#' @export
remove_rare_taxa <- function(physeq, min_count = 10, min_prevalence = 0.01) {
  
  otu <- phyloseq::otu_table(physeq)
  
  # Filter by count
  taxa_keep_count <- names(which(taxa_sums(physeq) >= min_count))
  
  # Filter by prevalence
  prevalence <- colSums(otu > 0) / nrow(otu)
  taxa_keep_prev <- names(which(prevalence >= min_prevalence))
  
  taxa_keep <- intersect(taxa_keep_count, taxa_keep_prev)
  physeq_filt <- phyloseq::prune_taxa(taxa_keep, physeq)
  
  message("Retained ", ntaxa(physeq_filt), " taxa (from ", ntaxa(physeq), ")")
  message("  - Minimum count threshold: ", min_count)
  message("  - Minimum prevalence threshold: ", min_prevalence)
  
  return(physeq_filt)
}
