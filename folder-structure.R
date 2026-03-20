# Step 2: Set Up Folder Structure for R Project Management

# Define the folder structure
folders <- c(
  "scripts",     # Analysis scripts
  "R",           # Source codes
  "reports"      # Reports (markdowns, PDFs, etc.)
)

# Create each folder if it does not already exist
for (folder in folders) {
  if (!dir.exists(folder)) {
    dir.create(folder, recursive = TRUE)  # recursive = TRUE allows creation of nested directories
    cat("Created folder:", folder, "\n")  # Output a message for each created folder
  } else {
    cat("Folder already exists:", folder, "\n")
  }
}

# Optionally create a README.md file if it doesn't exist
readme_path <- "README.md"
if (!file.exists(readme_path)) {
  file.create(readme_path)
  cat("# Project Overview\n\n", file = readme_path)
  cat("README.md file created.\n")
} else {
  cat("README.md already exists.\n")
}
