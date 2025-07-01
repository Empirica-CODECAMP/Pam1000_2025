# Ensure required packages are installed and loaded
required_packages <- c("dplyr", "readr")
installed_packages <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    install.packages(pkg, dependencies = TRUE)
  }
}
# Load packages with library() calls
library(dplyr)
library(readr)

load_pas12_data <- function() {
# Define desktop path - matches your Django view
desktop_path <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
csv_file_path <- file.path(desktop_path, "pas12_summary.csv")

# Print paths for debugging
print(paste("Desktop path:", desktop_path))
print(paste("Looking for CSV at:", csv_file_path))

# Verify file exists before reading
if (!file.exists(csv_file_path)) {
  stop(paste("CSV file not found at:", csv_file_path, 
             "\nPlease run the Django view first to generate the file."))
}

# Read data from CSV
print("Reading data from CSV...")
pas12_summary_df <- readr::read_csv(csv_file_path)

# Print a sample of the data to verify
print("PAS12 Summary Data (first few rows):")
print(head(pas12_summary_df))

# Check required columns
required_cols <- c("gic_code", "premiums_past", "premiums_current", 
                   "claims_prior_periods", "claims_current_period")
if (!all(required_cols %in% colnames(pas12_summary_df))) {
  stop(paste("Missing columns in the data:", paste(setdiff(required_cols, colnames(pas12_summary_df)), collapse = ", ")))
}

# Perform calculations
summary_stats <- pas12_summary_df
  # group_by(key) %>%
  # summarise(
  #   total_premiums_past = sum(premiums_past, na.rm = TRUE),
  #   total_premiums_current = sum(premiums_current, na.rm = TRUE),
  #   total_claims_past = sum(claims_past, na.rm = TRUE),
  #   total_claims_current = sum(claims_current, na.rm = TRUE),
  #   .groups = 'drop'
  # )

# Print the summary statistics
print("Summary Statistics:")
print(summary_stats)

# Save to CSV on desktop (same location as input)
output_path <- file.path(desktop_path, "pas12_summary_stats.csv")
write.csv(summary_stats, output_path, row.names = FALSE)
print(paste("Summary statistics saved to:", output_path))

return(summary_stats)
}

load_pas12_data()
