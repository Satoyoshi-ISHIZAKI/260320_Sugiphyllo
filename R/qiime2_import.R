# ============================================================================
# QIIME2 Data Import Functions
# ============================================================================

# Required packages
library(qiime2R)
library(phyloseq)
library(dplyr)
library(stringr)

#' Import QIIME2 Data Files
#' 
#' Convenience wrapper to load all necessary QIIME2 output files (OTU table, 
#' taxonomy, phylogenetic tree, and metadata) from standardized directory paths.
#'
#' @param qiime2_dir Character. Path to QIIME2 analysis directory (e.g., "data/Analysis")
#' @param marker Character. Marker gene: "16S" or "ITS_paired". Default: "16S"
#' @param metadata_path Character. Path to sample metadata CSV file
#' @param tree_type Character. Phylogenetic tree type: "rooted" or "unrooted". Default: "rooted"
#'
#' @return List containing:
#'   - table: OTU table
#'   - tree: phylogenetic tree
#'   - tax: taxonomy assignments
#'   - metadata: sample metadata data frame
#'
#' @examples
#' \dontrun{
#'   qiime2_data <- import_qiime2_data(
#'     qiime2_dir = "data/Analysis",
#'     marker = "16S",
#'     metadata_path = "data/Metadata/samplesheet_Sugi.csv"
#'   )
#' }
#'
#' @export
import_qiime2_data <- function(qiime2_dir, 
                               marker = "16S",
                               metadata_path,
                               tree_type = "rooted") {
  
  # Construct file paths
  table_file <- file.path(qiime2_dir, "NoContam", paste0("table_", marker, "_nocontam.qza"))
  tree_file <- file.path(qiime2_dir, "phylogeny", paste0("tree_", tree_type, "_", marker, ".qza"))
  tax_file <- file.path(qiime2_dir, "taxa", paste0("classification_", marker, ".qza"))
  
  # Check if files exist
  if (!file.exists(table_file)) stop("OTU table file not found: ", table_file)
  if (!file.exists(tree_file)) stop("Tree file not found: ", tree_file)
  if (!file.exists(tax_file)) stop("Taxonomy file not found: ", tax_file)
  if (!file.exists(metadata_path)) stop("Metadata file not found: ", metadata_path)
  
  # Import files
  message("Loading OTU table from: ", table_file)
  table <- qiime2R::read_qza(table_file, taxa_are_rows = TRUE)
  
  message("Loading tree from: ", tree_file)
  tree <- qiime2R::read_qza(tree_file)
  
  message("Loading taxonomy from: ", tax_file)
  tax <- qiime2R::read_qza(tax_file)
  
  message("Loading metadata from: ", metadata_path)
  metadata <- read.csv(metadata_path)
  
  # Format sample IDs in metadata to match table
  metadata <- metadata %>%
    dplyr::mutate(Sample_Name = formatC(Sample_Name, width = 4, flag = "0")) %>%
    dplyr::filter(Sample_Name %in% colnames(table$data))
  
  # Standardize column names (capitalize first letter)
  colnames(metadata) <- stringr::str_replace_all(colnames(metadata), "^.", toupper)
  
  message("Successfully imported data for marker: ", marker)
  
  return(list(
    table = table,
    tree = tree,
    tax = tax,
    metadata = metadata
  ))
}


#' Create phyloseq Object from QIIME2 Components
#'
#' Assembles OTU table, taxonomy, phylogenetic tree, and metadata into a 
#' phyloseq object for unified microbiome analysis.
#'
#' @param qiime2_list List output from \code{\link{import_qiime2_data}}
#' @param sample_id_col Character. Column name in metadata containing sample IDs. Default: "Sample_Name"
#'
#' @return phyloseq object with OTU table, taxonomy, tree, and sample metadata
#'
#' @examples
#' \dontrun{
#'   qiime2_data <- import_qiime2_data(...)
#'   physeq <- create_phyloseq(qiime2_data)
#' }
#'
#' @export
create_phyloseq <- function(qiime2_list, sample_id_col = "Sample_Name") {
  
  # Extract components
  table <- qiime2_list$table$data
  tree <- qiime2_list$tree$data
  tax <- qiime2_list$tax$data
  metadata <- qiime2_list$metadata
  
  # Create sample data frame with rownames as sample IDs
  sample_df <- metadata
  rownames(sample_df) <- metadata[[sample_id_col]]
  
  # Create phyloseq object
  physeq <- phyloseq::phyloseq(
    phyloseq::otu_table(table, taxa_are_rows = TRUE),
    phyloseq::tax_table(tax),
    phyloseq::phy_tree(tree),
    phyloseq::sample_data(sample_df)
  )
  
  message("Created phyloseq object with:")
  message("  - ", nsamples(physeq), " samples")
  message("  - ", ntaxa(physeq), " taxa")
  message("  - ", nrow(sample_data(physeq)), " metadata variables")
  
  return(physeq)
}
