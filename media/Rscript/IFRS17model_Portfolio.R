################################################# OUTPUT BY YEAR ############################################
RunCSM_StartTime <- Sys.time()

list.of.packages <- c("dplyr", "here", "data.table", "readr", "lubridate", "RODBC", "reshape", "stringr", "openxlsx", "quantmod", "ggplot2", "tools", "readxl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages)) install.packages(new.packages)
library("dplyr")
library("jsonlite")
library("rlang")
library("data.table")
library("readr") # import read_csv
library("lubridate") # working with dates
library("RODBC") # import and export SQL data
library("reshape") # converting AIDS tables into long format
library("openxlsx") # to have Excel input tables
library("stringr")
library("quantmod") # quantitative analysis
library("ggplot2")
library("tools") # For file_path_sans_ext
library("readxl")

library(here)
here()
here::i_am("Calculations\\Rscript\\IFRS17model_Portfolio.R")

# Accept command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Parse arguments (expected: Run_Nr, PrevRun_Nr, NBRun_Nr)
Run_Nr <- as.integer(args[1])
PrevRun_Nr <- as.integer(args[2])
NBRun_Nr <- as.integer(args[3])
Portf <- readxl::read_excel(excel_file, sheet = "Setup", range = "B27", col_names = FALSE)
Portf <- 1
# Try to read the value from the specified cell
Stress <- tryCatch(
  {
    # Use a valid cell reference
    readxl::read_excel(excel_file, sheet = "ORSA setup", range = "C1000000", col_names = FALSE)
  },
  error = function(e) {
    # If an error occurs, return "Base"
    return("Base")
  }
)

# Check if the read value is empty or NULL
if (is.character(Stress) && Stress == "Base") {
  message("Failed to read value from Excel, setting Stress to 'Base'.")
} else if (is.null(Stress) || (is.data.frame(Stress) && (nrow(Stress) == 0 || ncol(Stress) == 0)) || all(is.na(Stress))) {
  Stress <- "Base"
} else if (is.data.frame(Stress) && nrow(Stress) > 0 && ncol(Stress) > 0) {
  Stress <- Stress[1, 1] # Extract the first cell's value
}

Run_Nr <- as.integer(Run_Nr)
Run_Nr <- 2024
NBRun_Nr <- as.integer(NBRun_Nr)
NBRun_Nr <- 2024
PrevRun_Nr <- as.integer(PrevRun_Nr)
PrevRun_Nr <- 2024
Portf <- as.character(Portf)
Stress <- as.character(Stress)

# Print the values
print(PrevRun_Nr)
print(NBRun_Nr)
print(Run_Nr)
print(Stress)

paste0("Selected Portfolio: ", Portf, " ", Stress)
# Run_Nr <- 2024
# PrevRun_Nr <- 2024
# NBRun_Nr <- 2024

# library(profvis)
#
# profvis({
# Your code here

# RunCSM <- function(PrevRun_Nr,NBRun_Nr,Run_Nr)
# {)
# Load necessary library
library(stringr)
print(paste0("Sorting User Input files ", Sys.time()))
# Define the base directory
base_dir <- here("Inputs", Stress)

# Define source and target directories
source_dir <- file.path(base_dir, "User Inputs")
source_fcs_dir <- file.path(source_dir, "FCFs")
excel_dir <- file.path(base_dir, "Excel")
if_dir <- file.path(excel_dir, "IF")
nb_dir <- file.path(excel_dir, "NB")
insurance_if_dir <- file.path(if_dir, "Insurance")
reinsurance_if_dir <- file.path(if_dir, "Reinsurance")
insurance_nb_dir <- file.path(nb_dir, "Insurance")
reinsurance_nb_dir <- file.path(nb_dir, "Reinsurance")

# Create the main directories if they don't exist
dir.create(source_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(source_fcs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(excel_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(if_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(nb_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(insurance_if_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reinsurance_if_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(insurance_nb_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reinsurance_nb_dir, recursive = TRUE, showWarnings = FALSE)

# List all Excel files in the source directories
files <- list.files(source_dir, pattern = "\\.xlsx$", full.names = TRUE)
files_fcs <- list.files(source_fcs_dir, pattern = "\\.xlsx$", full.names = TRUE)

# Combine the lists of files
all_files <- c(files, files_fcs)

# Function to determine target directory
get_target_dir <- function(file) {
  filename <- basename(file)
  cat("Processing file:", filename, "\n") # Debugging statement

  # Extract the year from the file name
  year <- str_extract(filename, "^\\d{4}")
  if (is.na(year)) {
    cat(" - No valid year found in filename\n")
    return(NULL)
  }

  # Determine if file belongs to IF or NB
  if (str_detect(filename, "IF")) {
    cat(" - This is an IF file\n") # Debugging statement
    # Determine if file belongs to INSURANCE or REINSURANCE
    if (str_detect(filename, "Reins") || str_detect(filename, "Reinsurance")) {
      cat(" - This is a REINSURANCE file\n") # Debugging statement
      target_dir <- file.path(reinsurance_if_dir, year)
      dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
      return(target_dir)
    } else if (str_detect(filename, "ins")) {
      cat(" - This is an INSURANCE file\n") # Debugging statement
      target_dir <- file.path(insurance_if_dir, year)
      dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
      return(target_dir)
    }
  } else if (str_detect(filename, "NB")) {
    cat(" - This is a NB file\n") # Debugging statement
    # Determine if file belongs to INSURANCE or REINSURANCE
    if (str_detect(filename, "Reins") || str_detect(filename, "Reinsurance")) {
      cat(" - This is a REINSURANCE file\n") # Debugging statement
      target_dir <- file.path(reinsurance_nb_dir, year)
      dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
      return(target_dir)
    } else if (str_detect(filename, "ins")) {
      cat(" - This is an INSURANCE file\n") # Debugging statement
      target_dir <- file.path(insurance_nb_dir, year)
      dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
      return(target_dir)
    }
  }

  cat(" - No target directory found\n") # Debugging statement
  return(NULL)
}

# Move files to their respective target directories
for (file in all_files) {
  target_dir <- get_target_dir(file)
  if (!is.null(target_dir)) {
    cat("Moving", basename(file), "to", target_dir, "\n") # Debugging statement
    file.rename(file, file.path(target_dir, basename(file)))
  } else {
    cat("No valid target directory for", basename(file), "\n") # Debugging statement
  }
}

# Print completion message
cat("Files sorted successfully.\n")

# Load required packages
if (!requireNamespace("httr", quietly = TRUE)) {
  install.packages("httr")
}
library(httr)

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
library(jsonlite)

if (!requireNamespace("here", quietly = TRUE)) {
  install.packages("here")
}
library(here)

# Define the main folder path
main_folder <- here("Output")

print(paste("Run", Run_Nr, "Declaration of global variables", Sys.time()))

setwd(here())
url <- "http://127.0.0.1:8000/configuration/runsettings/"
# Fetch data from Flask API instead of reading from Excel
response <- GET(url)
# RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
# RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
# Check if the request was successful
if (http_type(response) != "application/json") {
  stop("Error: No valid JSON response received")
}

# Parse the JSON response and convert it to a data frame
data <- content(response, as = "text", encoding = "UTF-8")
RunSettings <- as.data.frame(fromJSON(data))

# Print the fetched data for verification
print(RunSettings)


# Import run setting file for current run
# RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

RunSettingsRowNr <- which(round(RunSettings$NBRun_Nr, 5) == NBRun_Nr)

RiskAdjustmentApproach <- RunSettings$RiskAdj[RunSettingsRowNr]
RiskAdjustmentFactor <- RunSettings$RiskAdjustmentFac[RunSettingsRowNr]

# Define the subfolders and folders
subfolders <- c("NB", "IF", "Locked/IF")
folders <- c("Insurance", "Reinsurance")

# Function to delete all files within each specified subfolder and folder
delete_files_in_subfolders <- function(main_folder, subfolders, folders) {
  for (subfolder in subfolders) {
    subfolder_path <- file.path(main_folder, subfolder)

    for (folder in folders) {
      # Construct the path to each folder within the subfolders
      folder_path <- file.path(subfolder_path, folder)

      # Check if the folder exists before trying to list and delete files
      if (dir.exists(folder_path)) {
        # List all files in the current folder, including those in subfolders
        files <- list.files(folder_path, full.names = TRUE, recursive = TRUE)

        # Loop through each file and delete it
        for (file in files) {
          file.remove(file)
        }

        # Optionally, remove the folder itself if you want it completely cleared
        # Be careful with this as it will remove the directory structure too
        # unlink(folder_path, recursive = TRUE, force = TRUE)
      }
    }
  }

  # Print a message indicating completion
  cat("All files in specified subfolders and folders have been deleted.\n")
}

# Run the function to delete files
delete_files_in_subfolders(main_folder, subfolders, folders)


print(paste("Run", NBRun_Nr, "Preparation of yield curves data", Sys.time()))

# Directory paths
excel_directory <- here("Assumptions/TABLES/Curves", Stress, "Excel/")
Csv_directory <- here("Assumptions/TABLES/Curves", Stress, "Csv")

# List all Excel or CSV files in the directory
excel_files <- list.files(path = excel_directory, pattern = "\\.(xlsx|csv)$", full.names = TRUE)

# Function to check if data is already in the correct format
is_already_formatted <- function(data) {
  expected_columns <- c("ProjM", "NominalForwardRate", "RealForwardRate")
  return(all(expected_columns %in% colnames(data)))
}

# Process each Excel or CSV file
for (file_path in excel_files) {
  # Read Excel or CSV file
  if (grepl("\\.xlsx$", file_path, ignore.case = TRUE)) {
    original_data <- read.xlsx(file_path)
  } else if (grepl("\\.csv$", file_path, ignore.case = TRUE)) {
    original_data <- read.csv(file_path, sep = ";", skip = 2, header = FALSE)
  } else {
    warning(paste("Unsupported file format: ", file_path))
    next
  }

  # Print information about the data
  print(file_path)
  print(str(original_data))

  # Ensure the structure of the data
  if (!is.data.frame(original_data) || ncol(original_data) < 3) {
    warning(paste("Invalid data structure in file: ", file_path))
    next
  }

  # Check if the data is already formatted
  if (is_already_formatted(original_data)) {
    message(paste("Data already formatted, skipping transformation for file:", file_path))
  } else {
    # Convert to data frame
    original_data <- as.data.frame(original_data)

    # Delete the first column
    original_data <- original_data[, -1, drop = FALSE]

    # Change the headings
    colnames(original_data) <- c("ProjM", "NominalForwardRate", "RealForwardRate")

    # Adjust ProjM to start at 1
    original_data$ProjM <- seq_len(nrow(original_data))

    # Divide NominalForwardRate and RealForwardRate by 100
    original_data$NominalForwardRate <- as.numeric(original_data$NominalForwardRate) / 100
    original_data$RealForwardRate <- as.numeric(original_data$RealForwardRate) / 100
  }

  # Extract file name without extension
  file_name <- tools::file_path_sans_ext(basename(file_path))

  # Save the original data as CSV in the new directory
  csv_path <- here("Assumptions/TABLES/Curves", Stress, paste0(file_name, ".csv"))
  write.csv(original_data, csv_path, row.names = FALSE, quote = FALSE)
}
# invisible(utils::memory.limit(64000))

# define output list for RunCSM function
RunCSMListOutput <- list()

################# FUNCTIONS ###############################

elapsed_months <- function(end_date, start_date) {
  ed <- as.POSIXlt(end_date)
  sd <- as.POSIXlt(start_date)
  (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
}

################# RUN SETTINGS ##########################

# Specify the root directory containing subdirectories with Excel files

print(paste("Run", NBRun_Nr, "Data conversion from Excel FCF to comma separated for NB", Sys.time()))

root_dir <- here("Inputs", Stress, "Excel/NB/Insurance")

root_dir <- file.path(root_dir, as.character(NBRun_Nr))

root_dir <- as.character(root_dir)

# Prompt the user for the valuation year
valuation_year <- as.integer(NBRun_Nr)

# Get a list of all Excel files in the root directory and its subdirectories
excel_files <- list.files(path = root_dir, pattern = "\\.[Xx][Ll][SsXx]{1,2}$", full.names = TRUE, recursive = TRUE)

print(paste("Run", NBRun_Nr, "Data conversion from Excel FCF to comma separated for NB3", Sys.time()))

for (file in excel_files) {
  year_match <- regmatches(excel_files, regexpr("\\d{4}", excel_files))

  if (length(year_match) > 0) {
    year <- as.integer(year_match[[1]])
  } else {
    cat("Error: Could not extract the year from", excel_files, "\n")
    next # Skip this file and continue with the next one
  }
}
output_dir <- file.path(here("Inputs", Stress, "NB/Insurance"), as.character(NBRun_Nr))

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
setwd(output_dir)

print(paste("test"))

# List all files in the output directory
output_files <- list.files(full.names = TRUE)

file.remove(output_files)

# Loop through each Excel file
for (excel_file in excel_files) {
  # Extract the base name of the file without the extension
  file_base_name <- tools::file_path_sans_ext(basename(excel_file))

  # Extract the first three characters of the file name
  first_three_chars <- substr(file_base_name, 1, 3)

  # Get the names of all sheets in the Excel file
  sheet_names <- excel_sheets(excel_file)

  # Filter and process sheets in the current Excel file
  filtered_sheet_names <- sheet_names[grepl("^[0-9]{4} NB", sheet_names) &
    as.integer(sub("^([0-9]{4}) .*", "\\1", sheet_names)) <= valuation_year &
    !sheet_names %in% c("Input", "Description")]

  # Loop through each filtered sheet in the current Excel file
  for (sheet_name in filtered_sheet_names) {
    # Sanitize the sheet name to remove any invalid characters
    sanitized_sheet_name <- gsub("[^A-Za-z0-9._-]", "_", sheet_name)

    sanitized_sheet_name <- paste0(sanitized_sheet_name, "_", first_three_chars)


    # Generate a CSV file name based on the sanitized sheet name and year
    csv_file_name <- file.path(output_dir, paste0(sanitized_sheet_name, ".csv"))

    # Read data from the current Excel sheet
    sheet_data <- read_excel(excel_file, sheet = sheet_name, skip = 3)

    # Write data to the CSV file
    write.csv(sheet_data, file = csv_file_name, row.names = FALSE)

    cat("Saved", sheet_name, "from", excel_file, "as", csv_file_name, "\n")
  }
}

cat("Extraction and conversion completed.\n")

print(paste("Run", NBRun_Nr, "Data preparation for NB Gross Insurance cashflows completed", Sys.time()))

print(paste("Run", Run_Nr, "Data conversion from Excel FCF to comma separated for IF", Sys.time()))

# Specify the root directory containing subdirectories with Excel files
root_dir <- here("Inputs", Stress, "Excel/IF/Insurance")

root_dir <- file.path(root_dir, as.character(Run_Nr))

# Prompt the user for the valuation year
valuation_year <- as.integer(Run_Nr)

# Get a list of all Excel files in the root directory and its subdirectories
# Assuming root_dir is defined
excel_files <- list.files(path = root_dir, pattern = "\\.[Xx][Ll][SsXx]{1,2}$", full.names = TRUE, recursive = TRUE)

# Loop over each file
for (excel_file in excel_files) {
  # Try to extract the year from the filename
  year_match <- regmatches(excel_file, regexpr("\\d{4}", excel_file))

  if (length(year_match) > 0) {
    year <- as.integer(year_match[[1]])
    cat("Processing file:", excel_file, "for year:", year, "\n")
    # Add your file processing code here
  } else {
    cat("Error: Could not extract the year from", excel_file, "\n")
    next # Skip this file and continue with the next one
  }
}

output_dir <- file.path(here("Inputs", Stress, "IF/Insurance"), Run_Nr)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
setwd(output_dir)

# List all files in the output directory
output_files <- list.files(full.names = TRUE)

file.remove(output_files)


# Loop through each Excel file
for (excel_file in excel_files) {
  # Extract the base name of the file without the extension
  file_base_name <- tools::file_path_sans_ext(basename(excel_file))

  # Extract the first three characters of the file name
  first_three_chars <- substr(file_base_name, 1, 3)
  # Get the names of all sheets in the Excel file
  sheet_names <- excel_sheets(excel_file)

  filtered_sheet_names <- sheet_names[grepl("^[0-9]{4}", sheet_names) & as.integer(sub("^([0-9]{4}) .*", "\\1", sheet_names)) <= valuation_year & !sheet_names %in% c("Input", "Description")]
  # Loop through each sheet in the Excel file

  # Create the output directory based on the year
  output_dir <- file.path(here("Inputs", Stress, "IF/Insurance"), Run_Nr)

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Check if the file name contains "Input" and the sheet name is not "Description"

  for (sheet_name in filtered_sheet_names) {
    # Sanitize the sheet name to remove any invalid characters
    sanitized_sheet_name <- gsub("[^A-Za-z0-9._-]", "_", sheet_name)

    # Append the first three characters of the file name to the sanitized sheet name
    sanitized_sheet_name <- paste0(sanitized_sheet_name, "_", first_three_chars)

    # Generate a CSV file name based on the sanitized sheet name and year
    csv_file_name <- file.path(output_dir, paste0(sanitized_sheet_name, ".csv"))

    # Read data from Excel sheet
    sheet_data <- read_excel(excel_file, sheet = sheet_name, skip = 3)

    # Write data to CSV file
    write.csv(sheet_data, file = csv_file_name, row.names = FALSE)

    cat("Saved", sheet_name, "from", excel_files, "as", csv_file_name, "\n")
  }
}

cat("Extraction and conversion completed.\n")

print(paste("Run", Run_Nr, "Data preparation for IF Gross Insurance cashflows completed", Sys.time()))

################# FUNCTIONS ###############################

elapsed_months <- function(end_date, start_date) {
  ed <- as.POSIXlt(end_date)
  sd <- as.POSIXlt(start_date)
  (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
}

######################################################### Note from the IFRS17 standard ###########################################

# An entity shall divide portfolios of reinsurance contracts held applying
# paragraphs 14–24, except that the references to onerous contracts in those
# paragraphs shall be replaced with a reference to contracts on which there is a
# net gain on initial recognition. ~ source: Incorporating the June 2020 amendments(61)

################# RUN SETTINGS ##########################

# Specify the root directory containing subdirectories with Excel files

print(paste("Run", NBRun_Nr, "Data conversion from Excel FCF to comma separated for NB", Sys.time()))

root_dir <- here("Inputs", Stress, "Excel/NB/Reinsurance")

root_dir <- file.path(root_dir, as.character(NBRun_Nr))

root_dir <- as.character(root_dir)


# Prompt the user for the valuation year
valuation_year <- as.integer(NBRun_Nr)

# Get a list of all Excel files in the root directory and its subdirectories
excel_files <- list.files(path = root_dir, pattern = "\\.[Xx][Ll][SsXx]{1,2}$", full.names = TRUE, recursive = TRUE)
year_match <- regmatches(excel_files, regexpr("\\d{4}", excel_files))
# for (year in year_match) added possible error
for (year in year_match) {
  year_match <- regmatches(excel_files, regexpr("\\d{4}", excel_files))

  if (length(year_match) > 0) {
    year <- as.integer(year_match[[1]])
  } else {
    cat("Error: Could not extract the year from", excel_files, "\n")
    next # Skip this file and continue with the next one
  }
}
output_dir <- file.path(here("Inputs", Stress, "NB/Reinsurance"), NBRun_Nr)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
setwd(output_dir)

# List all files in the output directory
output_files <- list.files(full.names = TRUE)

file.remove(output_files)

# Loop through each Excel file
for (excel_file in excel_files) {
  file_base_name <- tools::file_path_sans_ext(basename(excel_file))

  # Extract the first three characters of the file name
  first_three_chars <- substr(file_base_name, 1, 3)

  # Get the names of all sheets in the Excel file
  sheet_names <- excel_sheets(excel_file)

  # Filter and process sheets in the current Excel file
  filtered_sheet_names <- sheet_names[grepl("^[0-9]{4} NB", sheet_names) &
    as.integer(sub("^([0-9]{4}) .*", "\\1", sheet_names)) <= valuation_year &
    !sheet_names %in% c("Input", "Description")]

  # Loop through each filtered sheet in the current Excel file
  for (sheet_name in filtered_sheet_names) {
    # Sanitize the sheet name to remove any invalid characters
    sanitized_sheet_name <- gsub("[^A-Za-z0-9._-]", "_", sheet_name)

    # Append the first three characters of the file name to the sanitized sheet name
    sanitized_sheet_name <- paste0(sanitized_sheet_name, "_", first_three_chars)


    # Generate a CSV file name based on the sanitized sheet name and year
    csv_file_name <- file.path(output_dir, paste0(sanitized_sheet_name, ".csv"))

    # Read data from the current Excel sheet
    sheet_data <- read_excel(excel_file, sheet = sheet_name, skip = 3)

    # Write data to the CSV file
    write.csv(sheet_data, file = csv_file_name, row.names = FALSE)

    cat("Saved", sheet_name, "from", excel_file, "as", csv_file_name, "\n")
  }
}

cat("Extraction and conversion completed.\n")

print(paste("Run", Run_Nr, "Reinsurance", "Data preparation for NB  Reinsurance cashflows completed", Sys.time()))

print(paste("Run", Run_Nr, "Reinsurance", "Data conversion from Excel FCF to comma separated for IF", Sys.time()))

# Specify the root directory containing subdirectories with Excel files
root_dir <- here("Inputs", Stress, "Excel/IF/Reinsurance")
root_dir <- file.path(root_dir, as.character(NBRun_Nr))

root_dir <- as.character(root_dir)

# Prompt the user for the valuation year
valuation_year <- as.integer(Run_Nr)

# Get a list of all Excel files in the root directory and its subdirectories
excel_files <- list.files(path = root_dir, pattern = "\\.[Xx][Ll][SsXx]{1,2}$", full.names = TRUE, recursive = TRUE)


year_match <- regmatches(excel_files, regexpr("\\d{4}", excel_files))

if (length(year_match) > 0) {
  year <- as.integer(year_match[[1]])
} else {
  cat("Error: Could not extract the year from", excel_files, "\n")
  next # Skip this file and continue with the next one
}

output_dir <- file.path(here("Inputs", Stress, "IF/Reinsurance"), Run_Nr)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
setwd(output_dir)

# List all files in the output directory
output_files <- list.files(full.names = TRUE)

file.remove(output_files)


# Loop through each Excel file
for (excel_file in excel_files) {
  file_base_name <- tools::file_path_sans_ext(basename(excel_file))

  # Extract the first three characters of the file name
  first_three_chars <- substr(file_base_name, 1, 3)

  # Check if the file name contains "Input" and the sheet name is not "Description"

  # Create the output directory based on the year
  output_dir <- file.path(here("Inputs", Stress, "IF/Reinsurance"), Run_Nr)

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }


  # Get the names of all sheets in the Excel file
  sheet_names <- excel_sheets(excel_file)
  year_sheet_names <- grepl("^[0-9]{4}", sheet_names)

  # Apply the sub function only to sheet names that start with a four-digit year
  year_numbers <- sub("^([0-9]{4}).*", "\\1", sheet_names[year_sheet_names])

  # Convert the extracted year strings to integers
  year_numbers_as_int <- as.integer(year_numbers)

  # Filter out the sheet names using the year condition and excluding specific names
  filtered_sheet_names <- sheet_names[year_sheet_names &
    (year_numbers_as_int <= valuation_year) &
    !sheet_names %in% c("Input", "Description")]

  # Output the filtered sheet names
  # filtered_sheet_names <- sheet_names[grepl("^[0-9]{4}", sheet_names) & as.integer(sub("^([0-9]{4}) .*", "\\1", sheet_names)) <= valuation_year & !sheet_names %in% c("Input", "Description")]
  # Loop through each sheet in the Excel file
  for (sheet_name in filtered_sheet_names) {
    # Sanitize the sheet name to remove any invalid characters
    sanitized_sheet_name <- gsub("[^A-Za-z0-9._-]", "_", sheet_name)

    # Append the first three characters of the file name to the sanitized sheet name
    sanitized_sheet_name <- paste0(sanitized_sheet_name, "_", first_three_chars)

    # Generate a CSV file name based on the sanitized sheet name and year
    csv_file_name <- file.path(output_dir, paste0(sanitized_sheet_name, ".csv"))

    # Read data from Excel sheet
    sheet_data <- read_excel(excel_file, sheet = sheet_name, skip = 3)

    # Write data to CSV file
    write.csv(sheet_data, file = csv_file_name, row.names = FALSE)

    cat("Saved", sheet_name, "from", excel_files, "as", csv_file_name, "\n")
  }
}


cat("Extraction and conversion completed.\n")

print(paste("Run", Run_Nr, "Reinsurance", "Data preparation for IF Reinsurance cashflows completed", Sys.time()))

GrossCSM <- function(PrevRun_Nr, NBRun_Nr, Run_Nr) {
  ################################################### GROSS OF REINSURANCE ####################################################

  ############################### NEW BUSINESS ##############################
  # NBrun <- function(NBRun_Nr){
  print(paste("Run", NBRun_Nr, "New business Start of CSM calculations", Sys.time()))
  # Library{r}
  list.of.packages <- c("dplyr", "data.table", "readr", "lubridate", "RODBC", "reshape", "stringr", "openxlsx", "quantmod", "ggplot2", "tools", "readxl")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
  if (length(new.packages)) install.packages(new.packages)
  library("dplyr")
  library("data.table")
  library("readr") # import read_csv
  library("lubridate") # working with dates
  library("RODBC") # import and export SQL data
  library("reshape") # converting AIDS tables into long format
  library("openxlsx") # to have Excel input tables
  library("stringr")
  library("quantmod") # quantitative analysis
  library("ggplot2")
  library("tools") # For file_path_sans_ext
  library("readxl")


  print(paste("Run", Run_Nr, "Beginning of PM10000 IFRS17 runs", Sys.time()))

  setwd(here())
  url <- "http://127.0.0.1:8000/configuration/runsettings/"
  reponse <- GET(url)

  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  if (http_type(response) != "application/json") {
    stop("Error: No valid JSON response received")
  }

  # Parse the JSON response and convert it to a data frame
  data <- content(response, as = "text", encoding = "UTF-8")
  RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)

  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which(round(RunSettings$NBRun_Nr, 5) == NBRun_Nr)

  # RunSettingsRowNr <- which(round(RunSettings$NBRun_Nr,5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12

  ForwardInterestRatesName <- RunSettings$ForwardInterestRatesName_NB[RunSettingsRowNr]
  EconomicAssumptionsName <- RunSettings$EconomicAssumptionsName[RunSettingsRowNr]
  RiskAdjustmentApproach <- RunSettings$RiskAdj[RunSettingsRowNr]
  RiskAdjustmentFactor <- RunSettings$RiskAdjustmentFac[RunSettingsRowNr]
  IncurredAcqCotsPeriod <- RunSettings$IncurredAcqCotsPeriod[RunSettingsRowNr]
  print(paste("Run", NBRun_Nr, "New business All run settings applied", Sys.time()))

  # EconomicAssumptions
  EconomicAssumptions <- data.frame(read_csv(
    file = paste0("./Assumptions/TABLES/Economic/", EconomicAssumptionsName),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  # Interest rates
  # ForwardInterestRates <- data.frame(read_csv(paste0("./Assumptions/TABLES/Curves/",ForwardInterestRatesName),
  #                                             col_types = cols(ProjM              = col_integer(),
  #                                                              NominalForwardRate = col_double(),
  #                                                              RealForwardRate    = col_double())))
  #
  ForwardInterestRates <- data.frame(read_csv(paste0("./Assumptions/TABLES/Curves/", Stress, "/", ForwardInterestRatesName),
    col_types = cols(
      ProjM = col_integer(),
      NominalForwardRate = col_double(),
      RealForwardRate = col_double()
    )
  ))
  ForwardInterestRates <- ForwardInterestRates %>%
    filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
  ForwardInterestRates <- ForwardInterestRates %>%
    mutate(ProjM = row_number()) # Resets ProjM to start at 1

  print(paste("Run", NBRun_Nr, "Assumptions read successfully", Sys.time()))

  # RiskPremium
  RiskPremium <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "RiskPremium"]
  # Inflation risk premium
  IRP <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "IRP"]

  # curve manipulations
  NominalForwardRate <- ForwardInterestRates$NominalForwardRate
  RealForwardRate <- ForwardInterestRates$RealForwardRate


  RDR_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  RDR_PC_Rel_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Rel_Sens <- 0 # no sensitivies yet in the model

  print(paste("Run", NBRun_Nr, "New business Calibration of discountfactors", Sys.time()))

  # RiskDiscountRate   <- (NominalForwardRate + RiskPremium + RDR_PC_Abs_Sens) * (1 + RDR_PC_Rel_Sens) # both an absolute and relative sensitivity is built in for the risk discount rate
  RiskDiscountRate <- NominalForwardRate # set the RDR to the nominal forward rate
  InflationCurve <- NominalForwardRate - RealForwardRate - IRP

  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRate[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRate[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period
  # Find the last numeric (non-NA) value
  last_numeric_valueStart <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueStart

  last_numeric_valueEnd <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueEnd

  InflationCurveAbsShock <- InflationCurve + ExpenseInfl_PC_Abs_Sens
  InflationCurveRelShock <- InflationCurve * (1 + ExpenseInfl_PC_Rel_Sens)

  InflationCurve <- pmax(InflationCurveAbsShock, InflationCurveRelShock)

  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)

  print(paste("Run", NBRun_Nr, "New business reading of fulfilment cashflows", Sys.time()))

  inwd <- here()

  outwd <- file.path(inwd, paste0("Output/", NBRun_Nr, "/", Portf, "/", Stress, "/NB/Insurance"))
  file_list <- list.files(outwd, full.names = TRUE)
  file.remove(file_list)

  # Set the working directory to a subdirectory of the input directory using paste0()
  run_dir <- file.path(inwd, "Inputs", Stress, "NB/Insurance", NBRun_Nr)
  setwd(run_dir)

  # Get the list of files
  files <- list.files()

  print(paste("Initial Portf:", Portf))
  print("Initial files:")
  print(files)

  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)

    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)

  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 35)
  CFResults_List <- list()
  InsuranceCFResults_List <- list()

  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-insurance-data"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Print debugging information
  print("Debugging Information:")
  print(paste("URL:", url))
  print(paste("HTTP Status:", http_type(response)))

  # Check if the request was successful
  if (http_type(response) != "application/json") {
    # Print HTTP status code if not application/json
    cat("HTTP Status Code:", http_status(response)$status_code, "\n")
    # Print error message if available
    if (!is.null(response$status_message)) {
      cat("Error Message:", response$status_message, "\n")
    }
    stop("Error: No valid JSON response received")
  }

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Print the retrieved data
  print("Data Retrieved Successfully:")
  print(jsonData)

  # Convert JSON to data frame
  FCFVars <- as.data.frame(jsonData)
  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    file_r <- fread(files[i])

    file_r <- file_r[, -1]

    file_r[file_r == "-"] <- 0

    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r

    # Check if 'PREM_INC' and 'V_PREM_INC' exist in 'file', and if not, initialize them to zero
    # if (!"PREM_INC" %in% names(file)) {
    # file$PREM_INC <- rep(0, nrow(file))
    # }
    # if (!"V_PREM_INC" %in% names(file)) {
    # file$V_PREM_INC <- rep(0, nrow(file))
    # }
    Premiums <- rep(0, nrow(file_r))
    # Calculate 'Premiums'
    # Premiums <- as.numeric(file$PREM_INC) + as.numeric(file$V_PREM_INC)
    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }

    # Initialize columns if they do not exist to avoid errors in calculations
    needed_columns <- c("INIT_EXP", "INIT_COMM", "INIT_VAL_EXP", "TOT_VAL_COMM", "REN_EXP", "REN_VAL_EXP", "REN_COMM")
    for (col in needed_columns) {
      if (!col %in% names(file)) {
        file[[col]] <- rep(0, nrow(file))
      }
    }


    # Calculate CurrAcqCFS
    CurrAcqCFS <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13], na.rm = TRUE)

    # Calculate FutAcq
    FutAcq <- file$INIT_COMM[14:600] + file$INIT_VAL_EXP[14:600]

    Adm <- rep(0, nrow(file_r)) # Initialize Adm outside the loop
    # Calculate Adm
    # Adm <- as.numeric(file$REN_EXP) + as.numeric(file$REN_VAL_EXP) + file$TOT_VAL_COMM + file$REN_COMM
    # Calculate 'Adm' using columns specified in FCFVars$Adm
    for (adm_col in FCFVars$Adm) {
      if (adm_col %in% names(file)) {
        Adm <- Adm + as.numeric(file[[adm_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Adm Column", adm_col, "not found\n")
      }
    }
    # Calculate Acq
    Acq <- rep(0, nrow(file_r))
    # Calculate 'Acq' using columns specified in FCFVars$Acq
    for (acq_col in FCFVars$Acq) {
      if (acq_col %in% names(file)) {
        Acq <- Acq + as.numeric(file[[acq_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Acq Column", acq_col, "not found\n")
      }
    }
    # Acq <- file$INIT_EXP[2:600] + file$INIT_COMM[2:600] + file$INIT_VAL_EXP[2:600]
    # Acq <- sum(DiscountFactorsStart[2:600] * Acq, na.rm = TRUE)

    # Calculate Comm
    Commission <- file$INIT_COMM

    # Calculate RenComm
    RenComm <- file$REN_COMM

    # Calculate InitExp
    InitExp <- file$INIT_EXP

    # Calculate ExpCurrAcq similar to CurrAcqCFS
    ExpCurrAcq <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13])
    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]

    # Define the columns you need
    columns_needed <- c(
      "V_DEATH_OUTGO", "A_DISAB_OUTGO(1)", "V_PHIBEN_OUTGO", "V_PHIBEN_OUTGO_BLL", "A_CR_OUTGO(1)",
      "A_RETR_OUTGO(1)", "A_DTH_OUTGO(1)", "A_DREADDIS_OUTGO(1)", "A_TEMPDIS_OUTGO(1)", "DEATH_OUTGO",
      "DISAB_OUTGO", "PHIBEN_OUTGO", "PHIBEN_OUTGO_BLL", "CR_BEN_OUTGO", "RETR_OUTGO", "DTH_OUTGO",
      "DREADDIS_OUTGO", "TEMPDIS_OUTGO", "RIDERC_OUTGO"
    )

    # Filter to ensure only existing columns are used
    # columns_needed <- columns_needed[columns_needed %in% names(file)]


    # for (col in columns_needed) {
    # if (!col %in% names(file)) {
    #   file[[col]] <- rep(0, nrow(file))
    #  }
    # }
    Claims <- rep(0, nrow(file_r)) # Initialize Claims outside the loop
    # Calculate 'Claims'
    # Claims <- file[, rowSums(.SD, na.rm = TRUE), .SDcols = columns_needed]


    # Claims <- file$V_DEATH_OUTGO + file$`A_DISAB_OUTGO(1)` + file$V_PHIBEN_OUTGO + file$V_PHIBEN_OUTGO_BLL + file$`A_CR_OUTGO(1)` + file$`A_RETR_OUTGO(1)` + file$`A_DTH_OUTGO(1)` + file$`A_DREADDIS_OUTGO(1)` + file$`A_TEMPDIS_OUTGO(1)` + file$DEATH_OUTGO + file$DISAB_OUTGO + file$PHIBEN_OUTGO + file$PHIBEN_OUTGO_BLL + file$CR_BEN_OUTGO + file$RETR_OUTGO + file$DTH_OUTGO + file$DREADDIS_OUTGO + file$TEMPDIS_OUTGO + file$RIDERC_OUTGO

    # Calculate 'Claims' using columns specified in FCFVars$Claims
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }
    ClaimsAndExp <- Claims + Adm
    print(paste("Run", NBRun_Nr, "passed", Sys.time()))
    ##### Preparations for Experience variances
    ExpReceivedPremiums <- sum(Premiums[2:13])
    CurrClaimsAndExpCFS <- sum(ClaimsAndExp[2:13])

    ExpFutAcq <- sum(DiscountFactorsStart[14:600] * FutAcq)

    PVRenComm <- sum(discountfacStart * RenComm[2:600])
    CurrInitComm <- sum(Commission[2:13])
    CurrInitExp <- sum(InitExp[2:13])
    PVCommission <- sum(discountfacStart * Commission[2:600])
    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    PVClaims <- sum(discountfacStart * Claims[2:600])
    PVAcq <- sum(discountfacStart * Acq)
    PVInitExp <- sum(discountfacStart * InitExp[2:600])
    PVClaimsFut <- sum(DiscountFactorsStart[14:600] * Claims[14:600])
    PVClaimsandExp <- sum(discountfacStart * ClaimsAndExp[2:600])
    PVRenExpenses <- sum(discountfacStart * file$REN_EXP[2:600] + discountfacStart * file$REN_VAL_EXP[2:600])
    # Error:object 'PVExpenses' not found now added
    PVExpenses <- sum(discountfacStart * Adm[2:600])
    # PVRenExpenses = sum(discountfacStart*Adm[2:600])
    BELsums[i, 19] <- PVClaims
    BELsums[i, 20] <- PVRenExpenses
    BELsums[i, 21] <- ExpReceivedPremiums
    BELsums[i, 22] <- CurrAcqCFS
    BELsums[i, 23] <- CurrClaimsAndExpCFS
    BELsums[i, 25] <- PVCommission
    BELsums[i, 26] <- PVPremiums
    BELsums[i, 27] <- PVAcq
    BELsums[i, 28] <- PVInitExp
    BELsums[i, 32] <- PVRenComm
    BELsums[i, 33] <- CurrInitComm
    BELsums[i, 34] <- CurrInitExp

    current_df <- data.frame(
      Month = 1:599,
      Premiums = Premiums[2:600],
      Claims = Claims[2:600],
      Commission = Commission[2:600] + RenComm[2:600],
      Acq = Acq[2:600],
      Ren = Adm[2:600]
    )
    CFResults_List[[i]] <- current_df



    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * PVClaimsandExp
      CU <- file$COVERAGE_UNITS
      Estimates_FCFinf <- Premiums[2:600]

      FCF0 <- Premiums[2:600] - Adm[2:600]
      COHORT <- year

      print(paste("Run", NBRun_Nr, "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0, discountfacStart, Premiums[14:600],Claims[14:600], discountfacStart)

      print(paste("Run", NBRun_Nr, "New business Discounting applied to future claims at end of period", Sys.time()))

      print(paste("Run", NBRun_Nr, "New business Discounting applied to future cashflows at start of period", Sys.time()))
      BELinf <- sum(Estimates_FCFinf * discountfacStart)
      BELout <- -PVClaimsandExp
      BELAcq <- -PVAcq
      pv <- data.frame(Present_Value = BELinf + BELout + BELAcq - RA, BEL = BELinf + BELout + BELAcq, Pvpremiums = sum(Premiums[2:600] * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      print(paste("Run", NBRun_Nr, Portf, "New business Unbulding of acqusition costs for Analysis of CSM", Sys.time()))

      BELsums[i, 8] <- RA
    } else {
      RA <- file$RISK_ADJ
      CU <- file$COVERAGE_UNITS
      Estimates_FCF <- Premiums[2:600] - FutAcq - Adm
      FCF0 <- Premiums - FutAcq - Adm - RA
      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart) - ExpCurrAcq, BEL = sum(Estimates_FCF * discountfacStart) - PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      print(paste("Run", NBRun_Nr, Portf, "New business Unbulding of acqusition costs for Analysis of CSM", Sys.time()))

      BELsums[i, 8] <- pv$RA
    }

    # AcqCosts = sum(Acq[1:IncurredAcqCotsPeriod])
    BELsums[i, 29] <- BELinf
    BELsums[i, 30] <- BELout
    BELsums[i, 31] <- BELAcq
    BELsums[i, 6] <- ExpCurrAcq
    BELsums[i, 16] <- ExpFutAcq
    # BELsums[i,8] <-  length(unique_policies)

    BELsums[i, 7] <- sum(pv$Pvpremiums)


    print(paste("Run", NBRun_Nr, Portf, "New business Estimate of future cashflows", Sys.time()))

    BELsums[i, 9] <- pv$BEL

    BEL_i <- Pv_cashflows$Present_Value
    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    BELsums[i, 2] <- sum(BEL_i)

    IA_fac_1 <- DiscountFactorsStart[1]
    IA_fac_12 <- DiscountFactorsStart[12]

    print(paste("Run", NBRun_Nr, Portf, "Interest accretion on NB CSM", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 2]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 5] <- Interest_accretion

    print(paste("Run", NBRun_Nr, Portf, "Interest accretion on NB BEL", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 9]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 12] <- Interest_accretion

    print(paste("Run", NBRun_Nr, Portf, "Interest accretion on NB RA", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 8]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 13] <- Interest_accretion
    BELsums[i, 15] <- sum(Premiums[2:13] * DiscountFactorsStart[2:13])
    BELsums[i, 18] <- sum(Premiums[14:600] * DiscountFactorsStart[14:600])
    BELsums[i, 24] <- RiskAdjustmentFactor * CurrClaimsAndExpCFS
    print(paste("Run", NBRun_Nr, Portf, "New business Calibration of coverage units", Sys.time()))

    CU <- file$COVERAGE_UNITS[2:1301]

    CU[is.na(CU)] <- 0

    print(paste("Run", NBRun_Nr, Portf, "New business Discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    # CU <- unlist(result)
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))

    CoverageUnits_fac <- sum(CU[2:13]) / sum(CU)
    BELsums[i, 3] <- CoverageUnits_fac

    if (BELsums[i, 2] > 0) {
      print(paste("Run", NBRun_Nr, Portf, "CSM is being released to Income Statement", Sys.time()))

      CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
      BELsums[i, 4] <- CSM_release
      ExpClaimsandRenExp <- sum(Adm[2:13]) + sum(Claims[2:13])
      ExpFutClaimsExp <- sum(Adm[14:600] * DiscountFactorsStart[14:600]) + sum(Claims[14:600] * DiscountFactorsStart[14:600])
      BELsums[i, 14] <- ExpClaimsandRenExp
      BELsums[i, 17] <- ExpFutClaimsExp
    } else {
      ##################################################### systematic allocation ratio (SAR)

      print(paste("Run", NBRun_Nr, Portf, "Loss component (LC) reversal according to the SAR", Sys.time()))

      # Worked example{

      # Similarly, the SAR to apply for year 2 is calculated as:
      # loss component at beginning of year 2
      # ________________________________________ =   R68.6/R70 = 98% = year2 SAR
      # PV expected claims/expenses at start of year 2
      # a) The amounts above have been calculated by applying the SAR applicable in that year to the release of the expected claims and maintenance expenses in revenue that year.
      # For example:
      # R29.4 = R30 (amount released in revenue) x 98% (year 1 SAR)
      # R68.6 = R70 (amount released in revenue) x 98% (year 2 SAR)
      # }

      ExpClaimsandRenExp <- sum(Adm[2:13] * discountfacStart[2:13]) + sum(Claims[2:13] * discountfacStart[2:13])
      ExpFutClaimsExp <- sum(Adm[14:600] * DiscountFactorsStart[14:600]) + sum(Claims[14:600] * DiscountFactorsStart[14:600])
      BELsums[i, 14] <- ExpClaimsandRenExp
      BELsums[i, 17] <- ExpFutClaimsExp
      LC_reversal <- as.numeric(ExpClaimsandRenExp / (PVClaims + PVExpenses) * as.numeric(BELsums[i, 2]))
      BELsums[i, 4] <- LC_reversal

      print(paste("Run", NBRun_Nr, Portf, "Loss component recovery (LCR) quantified", Sys.time()))

      Reinsceding_rate <- as.numeric(0.9)

      BELsums[i, 10] <- as.numeric(BELsums[i, 9]) * Reinsceding_rate

      print(paste("Run", NBRun_Nr, Portf, "Calculation of reversal of LCR", Sys.time()))


      # ExpClaimsandRenExp <- sum(Adm[2:13])+sum(Claims[2:13])
      LCRecov_armotisation <- as.numeric(ExpClaimsandRenExp / (PVClaims + PVExpenses) * as.numeric(BELsums[i, 10]))
      BELsums[i, 11] <- LCRecov_armotisation
    }

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 20)
    NewCol <- as.data.frame(rep(pn, length(Pv_cashflows[[2]])))
    colname <- as.data.frame("GROUPING")
    Prophprod <- c(colname, NewCol)
  }

  # InsuranceCFS_df <- do.call(rbind, CFResults_List)

  # Combine all data frames in the list into one data frame
  combined_df <- bind_rows(CFResults_List)

  # Summing the "Premiums", "Claims", and "Commission" by "Month"
  InsuranceCFS_df <- combined_df %>%
    group_by(Month) %>%
    summarise(
      Total_Premiums = sum(Premiums, na.rm = TRUE),
      Total_Claims = sum(Claims, na.rm = TRUE),
      Total_Commission = sum(Commission, na.rm = TRUE),
      Total_Ren = sum(Ren, na.rm = TRUE),
      Total_Adm = sum(Adm, na.rm = TRUE)
    )


  outwd <- file.path(inwd, paste0("Output/", NBRun_Nr, "/", Portf, "/", Stress, "/NB/Insurance"))
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)
  # InsuranceCFS_df<- aggregate(. ~ Month, data = InsuranceCFS_df, sum)
  # InsuranceCFS_df <- colSums(InsuranceCFS_df)

  SumsofBELS_NB_Ins <- as.numeric(BELsums[, 2])
  CurrRA <- as.numeric(BELsums[, 24])
  TotCurrRA <- sum(CurrRA)
  Exp_NB_Premiums <- as.numeric(BELsums[, 15])
  PVCommission <- as.numeric(BELsums[, 25])
  TotPVComm <- sum(PVCommission)
  PVClaimsAll <- as.numeric(BELsums[, 19])
  TotPVClaims <- sum(PVClaimsAll)
  PVPremiums <- as.numeric(BELsums[, 26])
  TotPVPrem <- sum(PVPremiums)
  PVAcq <- as.numeric(BELsums[, 27])
  TotPVAcq <- sum(PVAcq)
  PVInitExp <- as.numeric(BELsums[, 28])
  TotPVInitExp <- sum(PVInitExp)
  BELinf <- as.numeric(BELsums[, 29])
  TotBELinf <- sum(BELinf)
  BELout <- as.numeric(BELsums[, 30])
  TotBELout <- sum(BELout)
  BELAcq <- as.numeric(BELsums[, 31])
  TotBELAcq <- sum(BELAcq)
  PVRenComm <- as.numeric(BELsums[, 32])
  TotPVRenComm <- sum(PVRenComm)
  CurrInitComm <- as.numeric(BELsums[, 33])
  TotCurrInitComm <- sum(CurrInitComm)
  CurrInitExp <- as.numeric(BELsums[, 34])
  TotCurrInitExp <- sum(CurrInitExp)
  PremExptobeReceived <- as.numeric(BELsums[, 21])
  TotPremsExpReceived <- sum(PremExptobeReceived)
  PVRenExpenses <- as.numeric(BELsums[, 20])
  TotRenExpenses <- sum(PVRenExpenses)
  TotExp_NB_Premiums <- sum(Exp_NB_Premiums)
  SubtotalofBELS_NB_Ins <- sum(SumsofBELS_NB_Ins)
  IFRS17_group_NB_Ins <- c(Item_names, "Total")
  FutExpClaimsExp <- as.numeric(BELsums[, 17])
  TotFutExpClaimsExp <- sum(FutExpClaimsExp)
  CU_NB_Ins <- as.numeric(BELsums[, 3])
  FutExpPremiums <- as.numeric(BELsums[, 18])
  TotFutExpPremiums <- sum(FutExpPremiums)
  Interest_accretion_NB_Ins <- as.numeric(BELsums[, 5])
  CurrAcqCFS <- as.numeric(BELsums[, 22])
  TotCurrAcqCFS <- sum(CurrAcqCFS)
  Interest_accBEL_NB_Ins <- as.numeric(BELsums[, 12])
  CurrClaimsExp <- as.numeric(BELsums[, 23])
  TotCurrClaimsExp <- sum(CurrClaimsExp)
  TotIABEL_NB_Ins <- sum(Interest_accBEL_NB_Ins)

  Interest_accRA_NB_Ins <- as.numeric(BELsums[, 13])

  ClaimsandExp_NB_Ins <- as.numeric(BELsums[, 14])

  TotPVClaimsandExp_NB_Ins <- sum(ClaimsandExp_NB_Ins)

  TotIARA_NB_Ins <- sum(Interest_accRA_NB_Ins)

  PVFP_NB_Ins <- as.numeric(BELsums[, 7])

  BELs_NB_Ins <- as.numeric(BELsums[, 9])

  LCRecov_NB_Ins <- as.numeric(BELsums[, 10])

  TotLCRecov_NB_Ins <- sum(LCRecov_NB_Ins)

  ReversalofLCRecov_NB_Ins <- as.numeric(BELsums[, 11])

  TotReversalofLCRecov_NB_Ins <- sum(ReversalofLCRecov_NB_Ins)

  TotFCF_NB_Ins <- sum(BELs_NB_Ins)

  RiskAdj_NB_Ins <- as.numeric(BELsums[, 8])

  TotRiskAdj_NB_Ins <- sum(RiskAdj_NB_Ins)

  TotPVFP_NB_Ins <- sum(PVFP_NB_Ins)

  ExpCurrAcq_NB_Ins <- as.numeric(BELsums[, 6])
  ExpFutAcq_NB_Ins <- as.numeric(BELsums[, 16])
  TotExpFutAcq <- sum(ExpFutAcq_NB_Ins)
  TotExpCurrAcq <- sum(ExpCurrAcq_NB_Ins)
  TotInterestAccret_NB_Ins <- sum(Interest_accretion_NB_Ins)

  CSMrelease_NB_Ins <- as.numeric(BELsums[, 4])

  TotalCSMrelease_NB_Ins <- sum(CSMrelease_NB_Ins)

  avgCU_NB_Ins <- mean(CU_NB_Ins)

  SumofBELs_df_NB_Ins <- data.frame(IFRS17_group_NB_Ins,
    CSM_LCpergroup = c(SumsofBELS_NB_Ins, SubtotalofBELS_NB_Ins), CurrPremCFS = c(PremExptobeReceived, TotPremsExpReceived), CurrAcqCFS = c(CurrAcqCFS, TotCurrAcqCFS), CurrRA = c(CurrRA, TotCurrRA), CurrInitComm = c(CurrInitComm, TotCurrInitComm), CurrInitExp = c(CurrInitExp, TotCurrInitExp), PVRenExpenses = c(PVRenExpenses, TotRenExpenses), CurrExpPremiumsPV = c(Exp_NB_Premiums, TotExp_NB_Premiums), FutExpPremiumsPV = c(FutExpPremiums, TotFutExpPremiums), CoverageUnits = c(CU_NB_Ins, avgCU_NB_Ins), CSM_LC_released_reversal = c(CSMrelease_NB_Ins, TotalCSMrelease_NB_Ins), Interest_Accreted_NB = c(Interest_accretion_NB_Ins, TotInterestAccret_NB_Ins), InterestAccBEL = c(Interest_accBEL_NB_Ins, TotIABEL_NB_Ins), Interest_accRA = c(Interest_accRA_NB_Ins, TotIARA_NB_Ins), PVFPrems = c(PVFP_NB_Ins, TotPVFP_NB_Ins), RA = c(RiskAdj_NB_Ins, TotRiskAdj_NB_Ins), BEL = c(BELs_NB_Ins, TotFCF_NB_Ins), LossCRecov = c(LCRecov_NB_Ins, TotLCRecov_NB_Ins), ReversalofLCRecov = c(ReversalofLCRecov_NB_Ins, TotReversalofLCRecov_NB_Ins),
    ExpFutAcq = c(ExpFutAcq_NB_Ins, TotExpFutAcq), ExpCurrAcq = c(ExpCurrAcq_NB_Ins, TotExpCurrAcq), CurrClaimsandExps = c(CurrClaimsExp, TotCurrClaimsExp), FutExpClaimsExp = c(FutExpClaimsExp, TotFutExpClaimsExp), TotRenExp = c(PVRenExpenses, TotRenExpenses), TotPVClaims = c(PVClaimsAll, TotPVClaims), TotPVComm = c(PVCommission, TotPVComm), TotPVAcq = c(PVAcq, TotPVAcq), TotPVPrem = c(PVPremiums, TotPVPrem), TotPVInitExp = c(PVInitExp, TotPVInitExp), TotBELinf = c(BELinf, TotBELinf), TotBELout = c(BELout, TotBELout), TotBELAcq = c(BELAcq, TotBELAcq), TotPVRenComm = c(PVRenComm, TotPVRenComm)
  )
  write.csv(SumofBELs_df_NB_Ins, paste(NBRun_Nr, Portf, "_NB BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  ################################################ NB RECOGNITION REPORT################################################################
  output_dir <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports"))
  output_file <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports/Report 1.3 NB Recognition.xlsx"))

  # Create the directory if it does not exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  wb <- loadWorkbook(here("Reports/Templates/Report 1.3 NB Recognition.xlsx"))
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = sum(SumofBELs_df_NB_Ins$BEL[c(1, 3)]), startCol = 2, startRow = 17) # NON ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = SumofBELs_df_NB_Ins$BEL[2], startCol = 2, startRow = 18) # ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = sum(SumofBELs_df_NB_Ins$RA[c(1, 3)]), startCol = 3, startRow = 17) # NON ONEROUS CONTRACTS RA
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = SumofBELs_df_NB_Ins$RA[2], startCol = 3, startRow = 18) # ONEROUS CONTRACTS RA

  csm_nononerous <- sum(SumofBELs_df_NB_Ins$BEL[c(1, 3)]) + sum(SumofBELs_df_NB_Ins$RA[c(1, 3)])
  csm_onerous <- SumofBELs_df_NB_Ins$BEL[2] + SumofBELs_df_NB_Ins$RA[2]
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = sum(SumofBELs_df_NB_Ins$BEL[c(1, 3)]), startCol = 5, startRow = 17) # NON ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = SumofBELs_df_NB_Ins$BEL[2], startCol = 5, startRow = 18) # ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = sum(SumofBELs_df_NB_Ins$RA[c(1, 3)]), startCol = 6, startRow = 17) # NON ONEROUS CONTRACTS RA
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = SumofBELs_df_NB_Ins$RA[2], startCol = 6, startRow = 18) # ONEROUS CONTRACTS RA
  # Write the calculated values to the Excel sheet
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = csm_nononerous, startCol = 4, startRow = 17) # NON ONEROUS CONTRACTS CSM
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = csm_onerous, startCol = 4, startRow = 18) # ONEROUS CONTRACTS CSM
  message1 <- paste0("This report shows a summary of the Insurance Contracts Recognised in ", Run_Nr, " for the Portfolio: ", Portf)
  message2 <- paste0("This report shows a summary of the Reinsurance Contracts Recognised in ", Run_Nr, " for the Portfolio: ", Portf)
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = message1, startCol = 1, startRow = 13)
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = message2, startCol = 1, startRow = 13)

  # Save the workbook
  saveWorkbook(wb, output_file, overwrite = TRUE)

  print(paste("Run", NBRun_Nr, Portf, "NB CSM calculations done", Sys.time()))
  # }
  run_dir <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS/NB/Insurance/NB Insurance CFs")

  if (!dir.exists(run_dir)) {
    dir.create(run_dir, recursive = TRUE)
  }

  # Set the working directory
  setwd(run_dir)
  results_Ins_NB <- list(
    SumofBELs_df_NB_Ins = SumofBELs_df_NB_Ins,
    SumsofBELS_NB_Ins = as.numeric(BELsums[, 2]),
    SubtotalofBELS_NB_Ins = sum(SumsofBELS_NB_Ins),
    IFRS17_group_NB_Ins = c(Item_names, "Total"),
    Exp_NB_Premiums = as.numeric(BELsums[, 15]),
    TotExp_NB_Premiums = sum(Exp_NB_Premiums),
    FutExpPremiums = as.numeric(BELsums[, 18]),
    TotFutExpPremiums = sum(FutExpPremiums),
    CU_NB_Ins = as.numeric(BELsums[, 3]),
    Interest_accretion_NB_Ins = as.numeric(BELsums[, 5]),
    Interest_accBEL_NB_Ins = as.numeric(BELsums[, 12]),
    TotIABEL_NB_Ins = sum(Interest_accBEL_NB_Ins),
    FutExpClaimsExp = as.numeric(BELsums[, 17]),
    TotFutExpClaimsExp = sum(FutExpClaimsExp),
    Interest_accRA_NB_Ins = as.numeric(BELsums[, 13]),
    CurrClaimsandExp_NB_Ins = as.numeric(BELsums[, 14]),
    TotPVClaimsandExp_NB_Ins = sum(ClaimsandExp_NB_Ins),
    TotIARA_NB_Ins = sum(Interest_accRA_NB_Ins),
    PVFP_NB_Ins = as.numeric(BELsums[, 7]),
    BELs_NB_Ins = as.numeric(BELsums[, 9]),
    LCRecov_NB_Ins = as.numeric(BELsums[, 10]),
    TotLCRecov_NB_Ins = sum(LCRecov_NB_Ins),
    ReversalofLCRecov_NB_Ins = as.numeric(BELsums[, 11]),
    TotReversalofLCRecov_NB_Ins = sum(ReversalofLCRecov_NB_Ins),
    TotFCF_NB_Ins = sum(BELs_NB_Ins),
    RiskAdj_NB_Ins = as.numeric(BELsums[, 8]),
    TotRiskAdj_NB_Ins = sum(RiskAdj_NB_Ins),
    TotPVFP_NB_Ins = sum(PVFP_NB_Ins),
    ExpCurrAcq_NB_Ins <- as.numeric(BELsums[, 6]),
    TotExpFutAcq <- sum(ExpFutAcq_NB_Ins),
    ExpFutAcq_NB_Ins <- as.numeric(BELsums[, 16]),
    TotExpFutAcq <- sum(ExpFutAcq_NB_Ins),
    TotInterestAccret_NB_Ins = sum(Interest_accretion_NB_Ins),
    CSMrelease_NB_Ins = as.numeric(BELsums[, 4]),
    TotalCSMrelease_NB_Ins = sum(CSMrelease_NB_Ins),
    avgCU_NB_Ins = mean(CU_NB_Ins)
  )

  write.csv(InsuranceCFS_df, paste(Run_Nr, Portf, "NB Insurance CFs.csv"), append = FALSE, row.names = FALSE, sep = ",")


  ############################################################# Closing IN FORCE at locked in rates ############################################


  print(paste("Run", Run_Nr, Portf, "Inforce at end Start of CSM calculations", Sys.time()))

  ################# FUNCTIONS ###############################

  elapsed_months <- function(end_date, start_date) {
    ed <- as.POSIXlt(end_date)
    sd <- as.POSIXlt(start_date)
    (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
  }

  ################# RUN SETTINGS ##########################

  setwd(here())
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "http://127.0.0.1:8000/configuration/runsettings/"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Convert JSON to data frame
  RunSettings <- as.data.frame(jsonData)
  # url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-inspect-data"
  # reponse <- GET(url)

  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  # if (http_type(response) != "application/json") {
  # stop("Error: No valid JSON response received")
  # }

  # Parse the JSON response and convert it to a data frame
  # data <- content(response, as = "text", encoding = "UTF-8")
  # RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)
  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which((RunSettings$Run_Nr) == Run_Nr)
  # RunSettingsRowNr <- which(round(RunSettings$Run_Nr,5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12


  print(paste("Run", Run_Nr, "Inforce at end All run settings applied", Sys.time()))

  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  ######## Assumption / Parameter manipulations to be used by model

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)


  print(paste("Run", Run_Nr, "Inforce at reading of FCFs", Sys.time()))

  inwd <- here()

  outwd <- file.path(inwd, "Output", Run_Nr, Portf, Stress, "IF")
  file_list <- list.files(outwd, full.names = TRUE)
  file.remove(file_list)

  run_dir <- file.path(inwd, "Inputs", Stress, "IF/Insurance", Run_Nr)
  if (!dir.exists(run_dir)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(run_dir)

  # Get the list of files
  files <- list.files()
  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)


  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 29)

  print(paste("Run", Run_Nr, Portf, "Locking the yield curve for each cohort", Sys.time()))
  #
  # COHORT <- numeric(4)
  #
  # yield_curvesStart <- list()
  # yield_curvesEnd <- list()
  #
  # master_results <- data.frame()
  CFResults_List <- list()
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-insurance-data"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Print debugging information
  print("Debugging Information:")
  print(paste("URL:", url))
  print(paste("HTTP Status:", http_type(response)))

  # Check if the request was successful
  if (http_type(response) != "application/json") {
    # Print HTTP status code if not application/json
    cat("HTTP Status Code:", http_status(response)$status_code, "\n")
    # Print error message if available
    if (!is.null(response$status_message)) {
      cat("Error Message:", response$status_message, "\n")
    }
    stop("Error: No valid JSON response received")
  }

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Print the retrieved data
  print("Data Retrieved Successfully:")
  print(jsonData)

  # Convert JSON to data frame
  FCFVars <- as.data.frame(jsonData)
  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    year_match <- as.integer(sub("^(\\d{4})_.*\\.csv$", "\\1", files[i]))

    COHORT <- year_match

    # Interest Rate Data Reading
    ForwardInterestRatesNameLockedCohort <- paste0("Forw_", COHORT, ".csv")
    filepath <- file.path(here("Assumptions/TABLES/Curves", Stress), ForwardInterestRatesNameLockedCohort)
    ForwardInterestRatesLocked <- read_csv(filepath, col_types = cols(ProjM = col_integer(), NominalForwardRate = col_double(), RealForwardRate = col_double()))

    ForwardInterestRatesLocked <- ForwardInterestRatesLocked %>%
      filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
    ForwardInterestRatesLocked <- ForwardInterestRatesLocked %>%
      mutate(ProjM = row_number()) # Resets ProjM to start at 1


    # Print Log Information
    print(paste("Run", Run_Nr, Portf, "Calibration of discount factors using Locked-in curves for interest accretion on IF", Sys.time()))

    # Extracting Interest Rates
    RiskDiscountRatesLocked <- ForwardInterestRatesLocked$NominalForwardRate
    RealForwardRatesLocked <- ForwardInterestRatesLocked$RealForwardRate

    # Calculate Discount Factors
    DiscountFactorsStartLocked <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRatesLocked[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
    DiscountFactorsStartLocked <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRatesLocked[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period

    last_numeric_valueStartLocked <- tail(na.omit(DiscountFactorsStartLocked), 1)

    # Replace NA values with the last numeric value
    DiscountFactorsStartLocked[is.na(DiscountFactorsStartLocked)] <- last_numeric_valueStartLocked

    last_numeric_valueEndLocked <- tail(na.omit(DiscountFactorsStartLocked), 1)

    # Replace NA values with the last numeric value
    DiscountFactorsStartLocked[is.na(DiscountFactorsStartLocked)] <- last_numeric_valueEndLocked


    file_r <- fread(files[i])
    # file = read.xlsx(files[i], sheet = sheetname)

    file_r <- file_r[, -1]

    file_r[file_r == "-"] <- 0



    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r



    # Check if 'PREM_INC' and 'V_PREM_INC' exist in 'file', and if not, initialize them to zero
    # if (!"PREM_INC" %in% names(file)) {
    #  file$PREM_INC <- rep(0, nrow(file))
    # }
    # if (!"V_PREM_INC" %in% names(file)) {
    #  file$V_PREM_INC <- rep(0, nrow(file))
    # }
    Premiums <- rep(0, nrow(file_r))
    # Calculate 'Premiums'
    # Premiums <- as.numeric(file$PREM_INC) + as.numeric(file$V_PREM_INC)
    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }

    # Initialize columns if they do not exist to avoid errors in calculations
    needed_columns <- c("INIT_EXP", "INIT_COMM", "INIT_VAL_EXP", "TOT_VAL_COMM", "REN_EXP", "REN_VAL_EXP")
    for (col in needed_columns) {
      if (!col %in% names(file)) {
        file[[col]] <- rep(0, nrow(file))
      }
    }


    # Calculate CurrAcqCFS
    CurrAcqCFS <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13], na.rm = TRUE)

    # Calculate FutAcq
    FutAcq <- file$INIT_COMM[14:600] + file$INIT_VAL_EXP[14:600]

    Adm <- rep(0, nrow(file_r))
    # Calculate Adm
    # Adm <- as.numeric(file$REN_EXP) + as.numeric(file$REN_VAL_EXP) + file$TOT_VAL_COMM + file$REN_COMM
    # Calculate 'Adm' using columns specified in FCFVars$Adm
    for (adm_col in FCFVars$Adm) {
      if (adm_col %in% names(file)) {
        Adm <- Adm + as.numeric(file[[adm_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Adm Column", adm_col, "not found\n")
      }
    }
    # Calculate Acq
    Acq <- rep(0, nrow(file_r))
    # Calculate 'Acq' using columns specified in FCFVars$Acq
    for (acq_col in FCFVars$Acq) {
      if (acq_col %in% names(file)) {
        Acq <- Acq + as.numeric(file[[acq_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Acq Column", acq_col, "not found\n")
      }
    }
    # Acq <- file$INIT_EXP[2:600] + file$INIT_COMM[2:600] + file$INIT_VAL_EXP[2:600] + file$TOT_VAL_COMM[2:600]
    # Acq <- sum(DiscountFactorsStart[2:600] * Acq, na.rm = TRUE)

    # Calculate ExpCurrAcq similar to CurrAcqCFS
    ExpCurrAcq <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13])
    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]

    # Calculate Comm
    Commission <- file$INIT_COMM

    # Calculate InitExp
    InitExp <- file$INIT_EXP

    # Calculate RenComm
    RenComm <- file$REN_COMM

    # Define the columns you need
    columns_needed <- c(
      "V_DEATH_OUTGO", "A_DISAB_OUTGO(1)", "V_PHIBEN_OUTGO", "V_PHIBEN_OUTGO_BLL", "A_CR_OUTGO(1)",
      "A_RETR_OUTGO(1)", "A_DTH_OUTGO(1)", "A_DREADDIS_OUTGO(1)", "A_TEMPDIS_OUTGO(1)", "DEATH_OUTGO",
      "DISAB_OUTGO", "PHIBEN_OUTGO", "PHIBEN_OUTGO_BLL", "CR_BEN_OUTGO", "RETR_OUTGO", "DTH_OUTGO",
      "DREADDIS_OUTGO", "TEMPDIS_OUTGO", "RIDERC_OUTGO"
    )

    # Filter to ensure only existing columns are used
    # columns_needed <- columns_needed[columns_needed %in% names(file)]
    print("Columns to be used for row sums:")
    # for (col in columns_needed) {
    # if (!col %in% names(file)) {
    #  file[[col]] <- rep(0, nrow(file))
    # }
    # }
    Claims <- rep(0, nrow(file_r)) # Initialize Claims outside the loop

    # Calculate 'Claims'
    # Claims <- file[, rowSums(.SD, na.rm = TRUE), .SDcols = columns_needed]
    # Claims <- file$V_DEATH_OUTGO + file$`A_DISAB_OUTGO(1)` + file$V_PHIBEN_OUTGO + file$V_PHIBEN_OUTGO_BLL + file$`A_CR_OUTGO(1)` + file$`A_RETR_OUTGO(1)` + file$`A_DTH_OUTGO(1)` + file$`A_DREADDIS_OUTGO(1)` + file$`A_TEMPDIS_OUTGO(1)` + file$DEATH_OUTGO + file$DISAB_OUTGO + file$PHIBEN_OUTGO + file$PHIBEN_OUTGO_BLL + file$CR_BEN_OUTGO + file$RETR_OUTGO + file$DTH_OUTGO + file$DREADDIS_OUTGO + file$TEMPDIS_OUTGO + file$RIDERC_OUTGO
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }


    ClaimsAndExp <- Claims + Adm
    CurrClaimsAndExpCFS <- sum(Claims[2:13]) + sum(Adm[2:13])
    ExpFutClaimsandExp <- sum(ClaimsAndExp[14:600] * DiscountFactorsStartLocked[14:600])
    ##### Preparations for Experience variances
    PVClaims <- sum(discountfacStart * Claims[2:600])
    CurrInitComm <- sum(Commission[2:13])
    CurrInitExp <- sum(InitExp[2:13])
    PVCommission <- sum(discountfacStart * Commission[2:600])
    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    PVAcq <- sum(discountfacStart * Acq)
    PVInitExp <- sum(discountfacStart * InitExp[2:600])
    PVClaimsandExp <- sum(discountfacStart * ClaimsAndExp[2:600])
    PVExpenses <- sum(discountfacStart * Adm[2:600])
    PVRenExpenses <- sum(discountfacStart * file$REN_EXP[2:600] + discountfacStart * file$REN_VAL_EXP[2:600] + discountfacStart * file$TOT_VAL_COMM[2:600])
    # as.numeric(file$REN_EXP) + as.numeric(file$REN_VAL_EXP)+ file$TOT_VAL_COMM + file$REN_COMM

    # PVRenExpenses <- sum(discountfacStart*Adm[2:600])
    PVRenComm <- sum(discountfacStart * RenComm[2:600])

    BELsums[i, 12] <- sum(Premiums[2:13])
    BELsums[i, 13] <- sum(Premiums[14:600] * DiscountFactorsStartLocked[14:600])
    BELsums[i, 14] <- CurrClaimsAndExpCFS
    BELsums[i, 15] <- ExpFutClaimsandExp
    BELsums[i, 18] <- PVCommission
    BELsums[i, 19] <- PVClaims
    BELsums[i, 20] <- PVPremiums
    BELsums[i, 21] <- PVAcq
    BELsums[i, 22] <- PVInitExp
    BELsums[i, 25] <- PVRenExpenses
    BELsums[i, 26] <- PVRenComm
    BELsums[i, 27] <- CurrInitComm
    BELsums[i, 28] <- CurrInitExp

    current_df <- data.frame(
      Month = 1:599,
      Premiums = Premiums[2:600],
      Acq = Acq[2:600],
      Ren = Adm[2:600],
      Claims = Claims[2:600],
      Commission = Commission[2:600]
    )
    CFResults_List[[i]] <- current_df


    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * (PVClaims + PVExpenses)
      CU <- file$COVERAGE_UNITS
      Estimates_FCF <- Premiums - Adm
      # Estimates_FCF = Premiums - Acq - Adm
      FCF0 <- Premiums - Adm
      COHORT <- year
      BELinf <- sum(Premiums[2:600] * discountfacStart)
      BELout <- -PVClaimsandExp

      print(paste("Run", NBRun_Nr, Portf, "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0[14:600], discountfacStart, Premiums[14:600],Claims[14:600], discountfacStart)

      print(paste("Run", NBRun_Nr, Portf, "New business Discounting applied to future claims at end of period", Sys.time()))

      print(paste("Run", NBRun_Nr, Portf, "New business Discounting applied to future cashflows at start of period", Sys.time()))

      pv <- data.frame(Present_Value = BELinf + BELout - RA, BEL = BELinf + BELout - PVAcq, Pvpremiums = sum(Premiums[2:600] * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value - Pv_cashflows$PVClaims

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      print(paste("Run", NBRun_Nr, Portf, "New business Unbulding of acqusition costs for Analysis of CSM", Sys.time()))

      BELsums[i, 7] <- RA
    } else {
      RA <- file$RISK_ADJ
      CU <- file$COVERAGE_UNITS
      Estimates_FCF <- Premiums - Acq - Adm
      FCF0 <- Premiums - Acq - Adm - RA
      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart), BEL = sum(Estimates_FCF * discountfacStart) - PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value - Pv_cashflows$PVClaims

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      print(paste("Run", NBRun_Nr, Portf, "New business Unbulding of acqusition costs for Analysis of CSM", Sys.time()))

      BELsums[i, 7] <- pv$RA
    }


    BELsums[i, 23] <- BELinf
    BELsums[i, 24] <- BELout
    BEL_i <- Pv_cashflows$NPV
    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    # BELsums[, 1] <- files
    BELsums[i, 2] <- sum(BEL_i)
    CurrRA <- RiskAdjustmentFactor * CurrClaimsAndExpCFS
    BELsums[i, 16] <- CurrRA
    IA_fac_1 <- DiscountFactorsStartLocked[1]
    IA_fac_12 <- DiscountFactorsStartLocked[12]

    print(paste("Run", Run_Nr, Portf, "Inforce at locked in rates CSM Interest accretion", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 2]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 5] <- Interest_accretion

    BELsums[i, 6] <- pv$BEL

    print(paste("Run", Run_Nr, Portf, "Inforce at locked in rates interest accretion on BEL", Sys.time()))

    Interest_accBEL <- as.numeric(BELsums[i, 6]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 8] <- Interest_accBEL

    print(paste("Run", Run_Nr, Portf, "Inforce at locked in rates end interest accretion on RA", Sys.time()))

    Interest_accRA <- as.numeric(BELsums[i, 7]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 9] <- Interest_accRA

    BELsums[i, 11] <- sum(Premiums[2:600] * DiscountFactorsStart[2:600])


    print(paste("Run", Run_Nr, Portf, "Inforce at end Calibration of coverage units", Sys.time()))

    CU[is.na(CU)] <- 0

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 15)

    print(paste("Run", Run_Nr, Portf, pn, "Inforce at end discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    # CU <- unlist(result)
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))

    CoverageUnits_fac <- sum(CU[2:13]) / sum(CU)
    BELsums[i, 3] <- CoverageUnits_fac

    if (BELsums[i, 2] > 0) {
      print(paste("Run", Run_Nr, Portf, "CSM released to the Income Statement", Sys.time()))

      CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
      BELsums[i, 4] <- CSM_release

      ExpClaimsandRenExp <- sum(Adm[2:13]) + sum(Claims[2:13])
      BELsums[i, 10] <- ExpClaimsandRenExp
    } else {
      ##################################################### systematic allocation ratio (SAR)

      print(paste("Run", Run_Nr, Portf, "Loss component (LC) calculated according to the SAR", Sys.time()))

      # Worked example{

      # Similarly, the SAR to apply for year 2 is calculated as:
      # loss component at beginning of year 2
      # ________________________________________ =   R68.6/R70 = 98% = year2 SAR
      # PV expected claims/expenses at start of year 2
      # a) The amounts above have been calculated by applying the SAR applicable in that year to the release of the expected claims and maintenance expenses in revenue that year.
      # For example:
      # R29.4 = R30 (amount released in revenue) x 98% (year 1 SAR)
      # R68.6 = R70 (amount released in revenue) x 98% (year 2 SAR)
      # }

      ExpClaimsandRenExp <- sum(Adm[2:13]) + sum(Claims[2:13])
      BELsums[i, 10] <- ExpClaimsandRenExp
      LC_reversal <- as.numeric(ExpClaimsandRenExp / (PVClaims + PVExpenses) * as.numeric(BELsums[i, 2]))
      BELsums[i, 4] <- LC_reversal

      print(paste("Run", Run_Nr, Portf, "Loss component moved to the Income Statement", Sys.time()))
    }

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 7)
  }
  outwd <- file.path(inwd, paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Locked/IF/Insurance"))
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)

  # Combine all data frames in the list into one data frame
  combined_df <- bind_rows(CFResults_List)

  # Summing the "Premiums", "Claims", and "Commission" by "Month"
  InsuranceCFS_df <- combined_df %>%
    group_by(Month) %>%
    summarise(
      Total_Premiums = sum(Premiums, na.rm = TRUE),
      Total_Acq = sum(Acq, na.rm = TRUE),
      Total_Ren = sum(Ren, na.rm = TRUE),
      Total_Claims = sum(Claims, na.rm = TRUE),
      Total_Commission = sum(Commission, na.rm = TRUE)
    )

  SumsofBELS_IF_InsCLS_LIYC <- as.numeric(BELsums[, 2])
  CurrRA <- as.numeric(BELsums[, 16])
  TotCurrRA <- sum(CurrRA)
  PVCommission <- as.numeric(BELsums[, 18])
  TotPVComm <- sum(PVCommission)
  PVClaimsAll <- as.numeric(BELsums[, 19])
  TotPVClaims <- sum(PVClaimsAll)
  PVPremiums <- as.numeric(BELsums[, 20])
  TotPVPrem <- sum(PVPremiums)
  PVAcq <- as.numeric(BELsums[, 21])
  TotPVAcq <- sum(PVAcq)
  PVInitExp <- as.numeric(BELsums[, 22])
  TotPVInitExp <- sum(PVInitExp)
  BELinf <- as.numeric(BELsums[, 23])
  TotBELinf <- sum(BELinf)
  BELout <- as.numeric(BELsums[, 24])
  TotBELout <- sum(BELout)
  PVRenExpenses <- as.numeric(BELsums[, 25])
  TotPVRenExpenses <- sum(PVRenExpenses)
  PVRenComm <- as.numeric(BELsums[, 26])
  TotPVRenComm <- sum(PVRenComm)
  CurrInitComm <- as.numeric(BELsums[, 27])
  CurrInitExp <- as.numeric(BELsums[, 28])
  TotCurrInitExp <- sum(CurrInitExp)
  TotCurrInitComm <- sum(CurrInitComm)
  FutExpPremiums <- as.numeric(BELsums[, 13])
  TotFutExpPremiums <- sum(FutExpPremiums)
  CurrPrems <- as.numeric(BELsums[, 12])
  TotCurrPrem <- sum(CurrPrems)
  CurrClaimsExp <- as.numeric(BELsums[, 14])
  TotCurrClaimsExp <- sum(CurrClaimsExp)
  FutExpClaimsExp <- as.numeric(BELsums[, 15])
  TotFutExpClaimsExp <- sum(FutExpClaimsExp)
  ExpPrems_IF_InsCLS_LIYC <- as.numeric(BELsums[, 11])
  TotalExpPrems_IF_InsCLS_LIYC <- sum(ExpPrems_IF_InsCLS_LIYC)
  SubtotalofBELS_IF_InsCLS_LIYC <- sum(SumsofBELS_IF_InsCLS_LIYC)
  IFRS17_group_IF_InsCLS_LIYC <- c(Item_names, "Total")
  CU_IF_InsCLS_LIYC <- as.numeric(BELsums[, 3])
  Interest_accretion_IF_InsCLS_LIYC <- as.numeric(BELsums[, 5])
  TotInterestAccret_IF_InsCLS_LIYC <- sum(Interest_accretion_IF_InsCLS_LIYC)
  Interest_accBEL_IF_InsCLS_LIYC <- as.numeric(BELsums[, 8])
  TotIA_BEL_IF_InsCLS_LIYC <- sum(Interest_accBEL_IF_InsCLS_LIYC)
  Interest_accRA_IF_InsCLS_LIYC <- as.numeric(BELsums[, 9])
  ClaimsandExp_IF_InsCLS_LIYC <- as.numeric(BELsums[, 10])
  TotPVClaimsandExp_IF_InsCLS_LIYC <- sum(ClaimsandExp_IF_InsCLS_LIYC)
  TotIA_RA_IF_InsCLS_LIYC <- sum(Interest_accRA_IF_InsCLS_LIYC)
  CSMrelease_IF_InsCLS_LIYC <- as.numeric(BELsums[, 4])
  BELs_IF_InsCLS_LIYC <- as.numeric(BELsums[, 6])
  TotFCF_IF_InsCLS_LIYC <- sum(BELs_IF_InsCLS_LIYC)
  RiskAdj_IF_InsCLS_LIYC <- as.numeric(BELsums[, 7])
  TotRiskAdj_IF_InsCLS_LIYC <- sum(RiskAdj_IF_InsCLS_LIYC)
  TotalCSMrelease_IF_InsCLS_LIYC <- sum(CSMrelease_IF_InsCLS_LIYC)
  avgCU_IF_InsCLS_LIYC <- as.numeric(mean(CU_IF_InsCLS_LIYC))

  SumofBELs_df_IF_InsCLS_LIYC <- data.frame(IFRS17_group_IF_InsCLS_LIYC, CoverageUnits = c(CU_IF_InsCLS_LIYC, avgCU_IF_InsCLS_LIYC), CurrRA = c(CurrRA, TotCurrRA), CurrInitComm = c(CurrInitComm, TotCurrInitComm), CurrInitExp = c(CurrInitExp, TotCurrInitExp), CurrPrems = c(CurrPrems, TotCurrPrem), FutPrems = c(FutExpPremiums, TotFutExpPremiums), PvPrems = c(ExpPrems_IF_InsCLS_LIYC, TotalExpPrems_IF_InsCLS_LIYC), CurrClaimsandExp = c(CurrClaimsExp, TotCurrClaimsExp), FutExpClaimsExp = c(FutExpClaimsExp, TotFutExpClaimsExp), CSM_LC_released_reversal = c(CSMrelease_IF_InsCLS_LIYC, TotalCSMrelease_IF_InsCLS_LIYC), Interest_Accreted_IF = c(Interest_accretion_IF_InsCLS_LIYC, TotInterestAccret_IF_InsCLS_LIYC), Interest_accBEL = c(Interest_accRA_IF_InsCLS_LIYC, TotIA_RA_IF_InsCLS_LIYC), Interest_accRA = c(Interest_accRA_IF_InsCLS_LIYC, TotIA_RA_IF_InsCLS_LIYC), RA = c(RiskAdj_IF_InsCLS_LIYC, TotRiskAdj_IF_InsCLS_LIYC), BEL = c(BELs_IF_InsCLS_LIYC, TotFCF_IF_InsCLS_LIYC), ClaimsandExp = c(ClaimsandExp_IF_InsCLS_LIYC, TotPVClaimsandExp_IF_InsCLS_LIYC), TotPVClaims = c(PVClaimsAll, TotPVClaims), TotPVComm = c(PVCommission, TotPVComm), TotPVAcq = c(PVAcq, TotPVAcq), TotPVPrem = c(PVPremiums, TotPVPrem), TotPVInitExp = c(PVInitExp, TotPVInitExp), TotBELinf = c(BELinf, TotBELinf), TotBELout = c(BELout, TotBELout), TotPVRenExpenses = c(PVRenExpenses, TotPVRenExpenses), TotPVRenComm = c(PVRenComm, TotPVRenComm))
  print(paste("Run", Run_Nr, Portf, "Printing Start year valuaion results to CSV file", Sys.time()))
  write.csv(SumofBELs_df_IF_InsCLS_LIYC, paste(Run_Nr, Portf, "Insurance Locked_BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  print(paste("Run", Run_Nr, Portf, "CSM for IF calculations done", Sys.time()))
  # }
  ######################################################### CSM run-off report################################################################
  wb <- loadWorkbook(here("Reports/Templates/Report 1.2 CSM run-off.xlsx"))
  writeData(wb, sheet = "METADATA", x = CU, startCol = 2, startRow = 3)
  writeData(wb, sheet = "Report 1.2 - CSM release", x = paste0("This report shows the Projected release of the CSM into the Income Statement at the Current and Prior reporting periods. Portfolio: ", Portf), startCol = 1, startRow = 14)
  output_dir <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports"))
  output_file <- here(paste0("Output", Run_Nr, "/", Portf, "/", Stress, "Reports/Report 1.2 CSM run-off.xlsx"))
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  saveWorkbook(wb, output_file, overwrite = TRUE)
  run_dir <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS/Locked/IF/Insurance/IF Insurance CFs")

  if (!dir.exists(run_dir)) {
    dir.create(run_dir, recursive = TRUE)
  }

  # Set the working directory
  setwd(run_dir)
  # write.csv(InsuranceCFS_df,paste(Run_Nr, 'Insurance CFs.csv'),append = FALSE, row.names = FALSE, sep = "," )

  results_IF_InsCLS_LIYC <- list(
    SumofBELs_df_IF_InsCLS_LIYC = SumofBELs_df_IF_InsCLS_LIYC,
    SumsofBELS_IF_InsCLS_LIYC = as.numeric(BELsums[, 2]),
    SubtotalofBELS_IF_InsCLS_LIYC = sum(SumsofBELS_IF_InsCLS_LIYC),
    IFRS17_group_IF_InsCLS_LIYC = c(Item_names, "Total"),
    CU_IF_InsCLS_LIYC = as.numeric(BELsums[, 3]),
    Interest_accretion_IF_InsCLS_LIYC = as.numeric(BELsums[, 5]),
    TotInterestAccret_IF_InsCLS_LIYC = sum(Interest_accretion_IF_InsCLS_LIYC),
    Interest_accBEL_IF_InsCLS_LIYC = as.numeric(BELsums[, 8]),
    TotIA_BEL_IF_InsCLS_LIYC = sum(Interest_accBEL_IF_InsCLS_LIYC),
    Interest_accRA_IF_InsCLS_LIYC = as.numeric(BELsums[, 9]),
    ClaimsandExp_IF_InsCLS_LIYC = as.numeric(BELsums[, 10]),
    TotPVClaimsandExp_IF_InsCLS_LIYC = sum(ClaimsandExp_IF_InsCLS_LIYC),
    TotIA_RA_IF_InsCLS_LIYC = sum(Interest_accRA_IF_InsCLS_LIYC),
    CSMrelease_IF_InsCLS_LIYC = as.numeric(BELsums[, 4]),
    BELs_IF_InsCLS_LIYC = as.numeric(BELsums[, 6]),
    TotFCF_IF_InsCLS_LIYC = sum(BELs_IF_InsCLS_LIYC),
    RiskAdj_IF_InsCLS_LIYC = as.numeric(BELsums[, 7]),
    TotRiskAdj_IF_InsCLS_LIYC = sum(RiskAdj_IF_InsCLS_LIYC),
    TotalCSMrelease_IF_InsCLS_LIYC = sum(CSMrelease_IF_InsCLS_LIYC),
    avgCU_IF_InsCLS_LIYC = mean(CU_IF_InsCLS_LIYC)
  )



  ####################################### VALUATION at the end  ##########################################################

  print(paste("Run", Run_Nr, "Closing Inforce at Current rates", Sys.time()))

  ################# FUNCTIONS ###############################

  elapsed_months <- function(end_date, start_date) {
    ed <- as.POSIXlt(end_date)
    sd <- as.POSIXlt(start_date)
    (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
  }

  ################# RUN SETTINGS ##########################

  setwd(here())
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "http://127.0.0.1:8000/configuration/runsettings/"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Convert JSON to data frame
  RunSettings <- as.data.frame(jsonData)
  # url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-inspect-data"
  # reponse <- GET(url)
  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  # if (http_type(response) != "application/json") {
  # stop("Error: No valid JSON response received")
  # }

  # Parse the JSON response and convert it to a data frame
  # data <- content(response, as = "text", encoding = "UTF-8")
  # RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)
  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which((RunSettings$Run_Nr) == Run_Nr)
  # RunSettingsRowNr <- which(round(RunSettings$Run_Nr,5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12

  ForwardInterestRatesName <- RunSettings$ForwardInterestRatesName_IFend[RunSettingsRowNr]
  EconomicAssumptionsName <- RunSettings$EconomicAssumptionsName[RunSettingsRowNr]

  print(paste("Run", Run_Nr, Portf, "Inforce at end All run settings applied", Sys.time()))

  # EconomicAssumptions
  EconomicAssumptions <- data.frame(read_csv(
    file = paste0("./Assumptions/TABLES/Economic/", EconomicAssumptionsName),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  # Interest rates
  ForwardInterestRates <- data.frame(read_csv(paste0("./Assumptions/TABLES/Curves/", Stress, "/", ForwardInterestRatesName),
    col_types = cols(
      ProjM = col_integer(),
      NominalForwardRate = col_double(),
      RealForwardRate = col_double()
    )
  ))

  ForwardInterestRates <- ForwardInterestRates %>%
    filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
  ForwardInterestRates <- ForwardInterestRates %>%
    mutate(ProjM = row_number()) # Resets ProjM to start at 1

  # RiskPremium
  RiskPremium <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "RiskPremium"]
  # Inflation risk premium
  IRP <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "IRP"]

  # curve manipulations
  NominalForwardRate <- ForwardInterestRates$NominalForwardRate
  RealForwardRate <- ForwardInterestRates$RealForwardRate


  RDR_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  RDR_PC_Rel_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Rel_Sens <- 0 # no sensitivies yet in the model

  print(paste("Run", Run_Nr, Portf, "Inforce at end Calibration of discountfactors", Sys.time()))

  # RiskDiscountRate   <- (NominalForwardRate + RiskPremium + RDR_PC_Abs_Sens) * (1 + RDR_PC_Rel_Sens) # both an absolute and relative sensitivity is built in for the risk discount rate
  RiskDiscountRate <- NominalForwardRate # set the RDR to the nominal forward rate
  InflationCurve <- NominalForwardRate - RealForwardRate - IRP

  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRate[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRate[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period
  # DiscountFactorsStart          = sapply(X = 1:(MaxProjM), FUN = function(x) if(x == 1) 1 else prod((1+RiskDiscountRate[1:(x-1)])^(-1))) # used for cashflows at the start of the projection period
  # DiscountFactorsStart            = sapply(X = 1:(MaxProjM), FUN = function(x)                   prod((1+RiskDiscountRate[1: x   ])^(-1))) # used for cashflows at the end   of the projection period
  last_numeric_valueStart <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueStart

  last_numeric_valueEnd <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueEnd
  InflationCurveAbsShock <- InflationCurve + ExpenseInfl_PC_Abs_Sens
  InflationCurveRelShock <- InflationCurve * (1 + ExpenseInfl_PC_Rel_Sens)

  InflationCurve <- pmax(InflationCurveAbsShock, InflationCurveRelShock)

  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  ######## Assumption / Parameter manipulations to be used by model

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)


  print(paste("Run", Run_Nr, Portf, "Inforce at reading of FCFs", Sys.time()))

  inwd <- here()

  run_dir <- file.path(inwd, "Inputs", Stress, "IF/Insurance", Run_Nr)
  if (!dir.exists(run_dir)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(run_dir)

  # Get the list of files
  files <- list.files()
  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)


  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 28)


  CFResults_List <- list()
  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    file_r <- fread(files[i])
    # file = read.xlsx(files[i], sheet = sheetname)
    file_r <- file_r[, -1]
    file_r[file_r == "-"] <- 0



    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r
    # Check if 'PREM_INC' and 'V_PREM_INC' exist in 'file', and if not, initialize them to zero
    # if (!"PREM_INC" %in% names(file)) {
    # file$PREM_INC <- rep(0, nrow(file))
    # }
    # if (!"V_PREM_INC" %in% names(file)) {
    # file$V_PREM_INC <- rep(0, nrow(file))
    # }
    Premiums <- rep(0, nrow(file_r))
    # Calculate 'Premiums'
    # Premiums <- as.numeric(file$PREM_INC) + as.numeric(file$V_PREM_INC)
    # Calculate 'Premiums' using columns specified in FCFVars$Premiums
    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }

    # Initialize columns if they do not exist to avoid errors in calculations
    needed_columns <- c("INIT_EXP", "INIT_COMM", "INIT_VAL_EXP", "TOT_VAL_COMM", "REN_EXP", "REN_VAL_EXP")
    for (col in needed_columns) {
      if (!col %in% names(file)) {
        file[[col]] <- rep(0, nrow(file))
      }
    }


    # Calculate CurrAcqCFS
    CurrAcqCFS <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13])

    # Calculate FutAcq
    FutAcq <- file$INIT_COMM[14:600] + file$INIT_VAL_EXP[14:600]
    Adm <- rep(0, nrow(file_r))
    # Calculate Adm
    # Adm <- as.numeric(file$REN_EXP) + as.numeric(file$REN_VAL_EXP) + file$TOT_VAL_COMM + file$REN_COMM
    for (adm_col in FCFVars$Adm) {
      if (adm_col %in% names(file)) {
        Adm <- Adm + as.numeric(file[[adm_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Adm Column", adm_col, "not found\n")
      }
    }


    # Calculate Acq
    Acq <- rep(0, nrow(file_r))
    # Calculate 'Acq' using columns specified in FCFVars$Acq
    for (acq_col in FCFVars$Acq) {
      if (acq_col %in% names(file)) {
        Acq <- Acq + as.numeric(file[[acq_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Acq Column", acq_col, "not found\n")
      }
    }
    # file$INIT_EXP[2:600] + file$INIT_COMM[2:600] + file$INIT_VAL_EXP[2:600]
    # Acq <- sum(DiscountFactorsStart[2:600] * Acq, na.rm = TRUE)

    # Calculate ExpCurrAcq similar to CurrAcqCFS
    ExpCurrAcq <- sum(file$INIT_EXP[2:13], na.rm = TRUE) +
      sum(file$INIT_COMM[2:13], na.rm = TRUE) +
      sum(file$INIT_VAL_EXP[2:13])
    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]

    # Calculate Comm
    Commission <- file$INIT_COMM

    # Calculate InitExp
    InitExp <- file$INIT_EXP

    # Calculate RenComm
    RenComm <- file$REN_COMM

    # Define the columns you need
    columns_needed <- c(
      "V_DEATH_OUTGO", "A_DISAB_OUTGO(1)", "V_PHIBEN_OUTGO", "V_PHIBEN_OUTGO_BLL", "A_CR_OUTGO(1)",
      "A_RETR_OUTGO(1)", "A_DTH_OUTGO(1)", "A_DREADDIS_OUTGO(1)", "A_TEMPDIS_OUTGO(1)", "DEATH_OUTGO",
      "DISAB_OUTGO", "PHIBEN_OUTGO", "PHIBEN_OUTGO_BLL", "CR_BEN_OUTGO", "RETR_OUTGO", "DTH_OUTGO",
      "DREADDIS_OUTGO", "TEMPDIS_OUTGO", "RIDERC_OUTGO"
    )

    # Filter to ensure only existing columns are used
    # columns_needed <- columns_needed[columns_needed %in% names(file)]
    # print("Columns to be used for row sums:")
    # for (col in columns_needed) {
    # if (!col %in% names(file)) {
    #  file[[col]] <- rep(0, nrow(file))
    # }
    # }

    Claims <- rep(0, nrow(file_r))
    # Calculate 'Claims'
    # Claims <- file[, rowSums(.SD, na.rm = TRUE), .SDcols = columns_needed]


    # Claims <- file$V_DEATH_OUTGO + file$`A_DISAB_OUTGO(1)` + file$V_PHIBEN_OUTGO + file$V_PHIBEN_OUTGO_BLL + file$`A_CR_OUTGO(1)` + file$`A_RETR_OUTGO(1)` + file$`A_DTH_OUTGO(1)` + file$`A_DREADDIS_OUTGO(1)` + file$`A_TEMPDIS_OUTGO(1)` + file$DEATH_OUTGO + file$DISAB_OUTGO + file$PHIBEN_OUTGO + file$PHIBEN_OUTGO_BLL + file$CR_BEN_OUTGO + file$RETR_OUTGO + file$DTH_OUTGO + file$DREADDIS_OUTGO + file$TEMPDIS_OUTGO + file$RIDERC_OUTGO
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }

    ClaimsAndExp <- Claims + Adm
    print(paste("Run", NBRun_Nr, "passed", Sys.time()))
    ##### Preparations for Experience variances
    ExpReceivedPremiums <- sum(Premiums[2:13])
    CurrClaimsAndExpCFS <- sum(ClaimsAndExp[2:13])

    ExpFutAcq <- sum(DiscountFactorsStart[14:600] * FutAcq)
    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]
    CurrInitComm <- sum(Commission[2:13])
    CurrInitExp <- sum(InitExp[2:13])
    PVCommission <- sum(discountfacStart * Commission[2:600])
    PVClaims <- sum(discountfacStart * Claims[2:600])
    PVAcq <- sum(discountfacStart * Acq)
    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    PVInitExp <- sum(discountfacStart * InitExp[2:600])
    PVRenExpenses <- sum(discountfacStart * file$REN_EXP[2:600] + discountfacStart * file$REN_VAL_EXP[2:600])
    Adm <- rep(0, nrow(file_r))
    # Adm <- as.numeric(file$REN_EXP) + as.numeric(file$REN_VAL_EXP) + file$TOT_VAL_COMM + file$REN_COMM
    # Calculate 'Adm' using columns specified in FCFVars$Adm
    for (adm_col in FCFVars$Adm) {
      if (adm_col %in% names(file)) {
        Adm <- Adm + as.numeric(file[[adm_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Adm Column", adm_col, "not found\n")
      }
    }


    # PVExpenses = sum(discountfacStart*Adm[2:600])
    PVExpenses <- sum(discountfacStart * file$REN_EXP[2:600] + discountfacStart * file$REN_VAL_EXP[2:600] + discountfacStart * file$TOT_VAL_COMM[2:600] + discountfacStart * file$REN_COMM[2:600])
    ClaimsAndExp <- Claims + Adm
    # RenExp <- Adm
    # RenExps <- file$REN_EXP
    CurrClaimsAndExpCFS <- sum(Claims[2:13]) + sum(Adm[2:13])
    ExpFutClaimsandExp <- sum(ClaimsAndExp[14:600] * DiscountFactorsStart[14:600])
    PVClaimsandExp <- sum(discountfacStart * ClaimsAndExp[2:600])
    PVRenExp <- sum(discountfacStart * file$REN_EXP)

    CurrClaims <- sum(Claims[2:13])
    BELsums[i, 26] <- CurrClaims

    CurrRenewalExpenses <- sum(Adm[2:13])
    BELsums[i, 27] <- CurrRenewalExpenses
    ## Redundant code
    # PVRenExpenses <- sum(discountfacStart*RenExps)
    PVRenComm <- sum(discountfacStart * RenComm[2:600])
    BELsums[i, 13] <- PVRenExp
    BELsums[i, 7] <- PVClaimsandExp

    BELsums[i, 10] <- sum(Premiums[14:600] * DiscountFactorsStartLocked[14:600])
    BELsums[i, 11] <- ExpFutClaimsandExp
    BELsums[i, 15] <- PVCommission
    BELsums[i, 16] <- PVClaims
    BELsums[i, 17] <- PVPremiums
    BELsums[i, 18] <- PVAcq
    BELsums[i, 19] <- PVInitExp
    BELsums[i, 22] <- PVRenExpenses
    BELsums[i, 23] <- PVExpenses
    BELsums[i, 24] <- PVRenComm
    BELsums[i, 25] <- CurrInitComm
    BELsums[i, 28] <- CurrInitExp

    current_df <- data.frame(
      Month = 1:599,
      Premiums = Premiums[2:600],
      Acq = Acq[2:600],
      Ren = Adm[2:600],
      Claims = Claims[2:600],
      Commission = Commission[2:600]
    )
    CFResults_List[[i]] <- current_df

    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * (PVClaims + PVExpenses)
      CU <- file$COVERAGE_UNITS
      # Estimates_FCF = Premiums - Acq - Adm
      # FCF0 = Premiums - Acq - Adm
      # COHORT <- year
      BELinf <- sum(Premiums[2:600] * discountfacStart)
      BELout <- PVClaimsandExp
      print(paste("Run", NBRun_Nr, Portf, "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0[14:600], discountfacStart, Premiums[14:600],Claims[14:600], discountfacStart)

      print(paste("Run", NBRun_Nr, Portf, "New business Discounting applied to future claims at end of period", Sys.time()))

      print(paste("Run", NBRun_Nr, Portf, "New business Discounting applied to future cashflows at start of period", Sys.time()))
      Pvpremiums <- sum(Premiums[2:600] * discountfacStart)
      # pv <-  data.frame(Present_Value = BELinf + BELout + BELAcq - RA, BEL = BELinf + BELout + BELAcq, Pvpremiums =sum(Premiums[2:600]* discountfacStart))
      pv <- data.frame(Present_Value = BELinf - BELout - RA - PVAcq, BEL = BELinf - BELout - PVAcq, Pvpremiums = sum(Premiums[2:600] * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV
      BELsums[i, 5] <- RA
    } else {
      RA <- file$RISK_ADJ
      CU <- file$COVERAGE_UNITS
      Estimates_FCF <- Premiums - Acq - Adm
      FCF0 <- Premiums - Acq - Adm - RA
      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart), BEL = sum(Estimates_FCF * discountfacStart) - PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value - Pv_cashflows$PVClaims

      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      print(paste("Run", NBRun_Nr, Portf, "New business Unbulding of acqusition costs for Analysis of CSM", Sys.time()))

      BELsums[i, 5] <- pv$RA
    }
    BELsums[i, 20] <- BELinf
    BELsums[i, 21] <- BELout

    BEL_i <- pv$BEL
    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    # BELsums[, 1] <- files
    BELsums[i, 2] <- sum(BEL_i)
    BELsums[i, 12] <- RiskAdjustmentFactor * CurrClaimsAndExpCFS

    IA_fac_1 <- DiscountFactorsStart[1]
    IA_fac_12 <- DiscountFactorsStart[12]

    Reinsceding_rate <- as.numeric(0.9)

    # print(paste("Run",Run_Nr,"Inforce at end CSM interest accretion",Sys.time()))

    # Interest_accretion <-  as.numeric(BELsums[i,2])*as.numeric(IA_fac_1 - IA_fac_12)
    # BELsums[i,5] <-  Interest_accretion
    #
    BELsums[i, 6] <- pv$BEL

    BELsums[i, 8] <- CurrClaimsAndExpCFS
    BELsums[i, 9] <- ExpReceivedPremiums

    #
    # print(paste("Run",Run_Nr,"Inforce at end interest accretion on BEL",Sys.time()))
    #
    # Interest_accBEL <-  as.numeric(BELsums[i,6])*as.numeric(IA_fac_1 - IA_fac_12)
    # BELsums[i,8] <-  Interest_accretion
    #
    # print(paste("Run",Run_Nr,"Inforce at end interest accretion on RA",Sys.time()))
    #
    # Interest_accBEL <-  as.numeric(BELsums[i,7])*as.numeric(IA_fac_1 - IA_fac_12)
    # BELsums[i,9] <-  Interest_accretion
    #
    #
    print(paste("Run", Run_Nr, Portf, "Inforce at end Calibration of coverage units", Sys.time()))

    CU[is.na(CU)] <- 0

    print(paste("Run", Run_Nr, Portf, "Inforce at end discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    # CU <- unlist(result)
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))

    CoverageUnits_fac <- sum(CU[2:13]) / sum(CU)
    BELsums[i, 3] <- CoverageUnits_fac

    if (BELsums[i, 2] > 0) {
      print(paste("Run", Run_Nr, Portf, "CSM released to the Income Statement", Sys.time()))

      CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
      BELsums[i, 4] <- CSM_release
    } else {
      ##################################################### systematic allocation ratio (SAR)

      print(paste("Run", NBRun_Nr, Portf, "Loss component (LC) calculated according to the SAR", Sys.time()))

      # Worked example{

      # Similarly, the SAR to apply for year 2 is calculated as:
      # loss component at beginning of year 2
      # ________________________________________ =   R68.6/R70 = 98% = year2 SAR
      # PV expected claims/expenses at start of year 2
      # a) The amounts above have been calculated by applying the SAR applicable in that year to the release of the expected claims and maintenance expenses in revenue that year.
      # For example:
      # R29.4 = R30 (amount released in revenue) x 98% (year 1 SAR)
      # R68.6 = R70 (amount released in revenue) x 98% (year 2 SAR)
      # }

      ExpClaimsandRenExp <- sum(Adm[2:13]) + sum(Claims[2:13])
      # BELsums[i,7] = ExpClaimsandRenExp
      LC_reversal <- as.numeric(ExpClaimsandRenExp / (PVClaims + PVExpenses) * as.numeric(BELsums[i, 2]))
      BELsums[i, 4] <- LC_reversal

      print(paste("Run", Run_Nr, Portf, "Loss component moved to the Income Statement", Sys.time()))
    }

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 7)
  }

  # Combine all data frames in the list into one data frame
  combined_df <- bind_rows(CFResults_List)

  # Summing the "Premiums", "Claims", and "Commission" by "Month"
  InsuranceCFS_df <- combined_df %>%
    group_by(Month) %>%
    summarise(
      Total_Premiums = sum(Premiums, na.rm = TRUE),
      Total_Acq = sum(Acq, na.rm = TRUE),
      Total_Ren = sum(Ren, na.rm = TRUE),
      Total_Claims = sum(Claims, na.rm = TRUE),
      Total_Commission = sum(Commission, na.rm = TRUE)
    )


  outwd <- file.path(inwd, paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/IF/Insurance"))
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)
  CurrClaims <- as.numeric(BELsums[, 26])
  TotCurrClaims <- sum(CurrClaims)
  CurrRenExpenses <- as.numeric(BELsums[, 27])
  TotCurrRenExp <- sum(CurrRenExpenses)
  SumsofBELS_IF_InsCLS_CYC <- as.numeric(BELsums[, 2])
  CurrRA <- as.numeric(BELsums[, 12])
  TotCurrRA <- sum(CurrRA)
  PVCommission <- as.numeric(BELsums[, 15])
  TotPVComm <- sum(PVCommission)
  PVClaimsAll <- as.numeric(BELsums[, 16])
  TotPVClaims <- sum(PVClaimsAll)
  PVPremiums <- as.numeric(BELsums[, 17])
  TotPVPrem <- sum(PVPremiums)
  PVAcq <- as.numeric(BELsums[, 18])
  TotPVAcq <- sum(PVAcq)
  PVInitExp <- as.numeric(BELsums[, 19])
  TotPVInitExp <- sum(PVInitExp)
  BELinf <- as.numeric(BELsums[, 20])
  TotBELinf <- sum(BELinf)
  BELout <- as.numeric(BELsums[, 21])
  TotBELout <- sum(BELout)
  PVRenExpenses <- as.numeric(BELsums[, 22])
  TotPVRenExpenses <- sum(PVRenExpenses)
  PVExpenses <- as.numeric(BELsums[, 23])
  TotPVExpenses <- sum(PVExpenses)
  PVRenComm <- as.numeric(BELsums[, 24])
  TotPVRenComm <- sum(PVRenComm)
  CurrInitComm <- as.numeric(BELsums[, 25])
  TotCurrInitComm <- sum(CurrInitComm)
  CurrInitExp <- as.numeric(BELsums[, 28])
  TotCurrInitExp <- sum(CurrInitExp)
  RenExp <- as.numeric(BELsums[, 13])
  TotRenExp <- sum(RenExp)
  CurrClaimsExp <- as.numeric(BELsums[, 8])
  TotCurrClaimsExp <- sum(CurrClaimsExp)
  ExpFutClaimsandExp <- as.numeric(BELsums[, 11])
  TotFutExpClaimsExp <- sum(ExpFutClaimsandExp)
  FutExpPremiums <- as.numeric(BELsums[, 10])
  TotExpPrems <- sum(FutExpPremiums)
  PremExptobeReceived <- as.numeric(BELsums[, 9])
  TotPremsExpReceived <- sum(PremExptobeReceived)
  SubtotalofBELS_IF_InsCLS_CYC <- sum(SumsofBELS_IF_InsCLS_CYC)
  ClaimsandExp_IF_InsCLS_CYC <- as.numeric(BELsums[, 7])
  TotPVClaimsandExp_IF_InsCLS_CYC <- sum(ClaimsandExp_IF_InsCLS_CYC)
  IFRS17_group_IF_InsCLS_CYC <- c(Item_names, "Total")
  CU_IF_InsCLS_CYC <- as.numeric(BELsums[, 3])
  CSMrelease_IF_InsCLS_CYC <- as.numeric(BELsums[, 4])
  BELs_IF_InsCLS_CYC <- as.numeric(BELsums[, 6])
  TotFCF_IF_InsCLS_CYC <- sum(BELs_IF_InsCLS_CYC)
  RiskAdj_IF_InsCLS_CYC <- as.numeric(BELsums[, 5])
  TotRiskAdj_IF_InsCLS_CYC <- sum(RiskAdj_IF_InsCLS_CYC)
  TotalCSMrelease_IF_InsCLS_CYC <- sum(CSMrelease_IF_InsCLS_CYC)
  avgCU_IF_InsCLS_CYC <- as.numeric(mean(CU_IF_InsCLS_CYC))

  SumofBELs_df_IF_InsCLS_CYC <- data.frame(
    IFRS17_group_IF_InsCLS_CYC,
    CurrRA = c(CurrRA, TotCurrRA), CurrInitComm = c(CurrInitComm, TotCurrInitComm), CurrInitExp = c(CurrInitExp, TotCurrInitExp), PVRenExp = c(RenExp, TotRenExp),
    CurrPremCFS = c(PremExptobeReceived, TotPremsExpReceived), FutExpPremiums = c(FutExpPremiums, TotExpPrems),
    CurrClaimsandExps = c(CurrClaimsExp, TotCurrClaimsExp), FutExpClaimsExp = c(FutExpClaimsExp, TotFutExpClaimsExp),
    CoverageUnits = c(CU_IF_InsCLS_CYC, avgCU_IF_InsCLS_CYC), CSM_LC_released_reversal = c(CSMrelease_IF_InsCLS_CYC, TotalCSMrelease_IF_InsCLS_CYC),
    Interest_Accreted_IF = c(Interest_accretion_IF_InsCLS_LIYC, TotInterestAccret_IF_InsCLS_LIYC),
    RA = c(RiskAdj_IF_InsCLS_CYC, TotRiskAdj_IF_InsCLS_CYC), BEL = c(BELs_IF_InsCLS_CYC, TotFCF_IF_InsCLS_CYC),
    ClaimsandExp = c(ClaimsandExp_IF_InsCLS_CYC, TotPVClaimsandExp_IF_InsCLS_CYC), TotPVClaims = c(
      PVClaimsAll,
      TotPVClaims
    ), TotPVComm = c(PVCommission, TotPVComm), TotPVAcq = c(PVAcq, TotPVAcq), TotPVPrem = c(PVPremiums, TotPVPrem),
    TotPVInitExp = c(PVInitExp, TotPVInitExp), TotBELinf = c(BELinf, TotBELinf), TotBELout = c(BELout, TotBELout), TotPVRenExpenses = c(PVRenExpenses, TotPVRenExpenses),
    TotCurrClaimsonly = c(CurrClaims, TotCurrClaims), TotCurrRenExp = c(CurrRenExpenses, TotCurrRenExp), TotPVExpenses = c(PVExpenses, TotPVExpenses), TotPVRenComm = c(PVRenComm, TotPVRenComm)
  )

  print(paste("Run", Run_Nr, Portf, "Printing Start year valuaion results to CSV file", Sys.time()))
  write.csv(SumofBELs_df_IF_InsCLS_CYC, paste(Run_Nr, Portf, "Insurance CLS_BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  print(paste("Run", Run_Nr, Portf, "CSM for IF calculations done", Sys.time()))

  run_dir <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS/IF/Insurance/IF Insurance CFs")

  if (!dir.exists(run_dir)) {
    dir.create(run_dir, recursive = TRUE)
  }

  # Set the working directory
  setwd(run_dir)

  write.csv(InsuranceCFS_df, paste(Run_Nr, Portf, "IF Insurance CFs.csv"), append = FALSE, row.names = FALSE, sep = ",")


  results_IF_InsCLS_CYC <- list(
    SumsofBELS_IF_InsCLS_CYC = SumsofBELS_IF_InsCLS_CYC,
    SubtotalofBELS_IF_InsCLS_CYC = SubtotalofBELS_IF_InsCLS_CYC,
    ClaimsandExp_IF_InsCLS_CYC = ClaimsandExp_IF_InsCLS_CYC,
    TotPVClaimsandExp_IF_InsCLS_CYC = TotPVClaimsandExp_IF_InsCLS_CYC,
    IFRS17_group_IF_InsCLS_CYC = IFRS17_group_IF_InsCLS_CYC,
    CU_IF_InsCLS_CYC = CU_IF_InsCLS_CYC,
    CSMrelease_IF_InsCLS_CYC = CSMrelease_IF_InsCLS_CYC,
    BELs_IF_InsCLS_CYC = BELs_IF_InsCLS_CYC,
    TotFCF_IF_InsCLS_CYC = TotFCF_IF_InsCLS_CYC,
    RiskAdj_IF_InsCLS_CYC = RiskAdj_IF_InsCLS_CYC,
    TotRiskAdj_IF_InsCLS_CYC = TotRiskAdj_IF_InsCLS_CYC,
    TotalCSMrelease_IF_InsCLS_CYC = TotalCSMrelease_IF_InsCLS_CYC,
    avgCU_IF_InsCLS_CYC = avgCU_IF_InsCLS_CYC,
    SumofBELs_df_IF_InsCLS_CYC = SumofBELs_df_IF_InsCLS_CYC, Reinsceding_rate = Reinsceding_rate
  )

  InsuranceResults <- list(Ins_NB = results_Ins_NB, IFCLS_CYC = results_IF_InsCLS_CYC, IFCLS_LIYC = results_IF_InsCLS_LIYC)

  return(InsuranceResults)
}

ReinsCSM <- function(PrevRun_Nr, NBRun_Nr, Run_Nr) {
  ################################################### REINSURANCE ####################################################

  ############################### NEW BUSINESS ##############################

  print(paste("Run", NBRun_Nr, Portf, "New business Start of CSM calculations", Sys.time()))
  # Library{r}
  list.of.packages <- c("dplyr", "data.table", "readr", "lubridate", "RODBC", "reshape", "stringr", "openxlsx", "quantmod", "ggplot2", "tools", "readxl")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
  if (length(new.packages)) install.packages(new.packages)
  library("dplyr")
  library("data.table")
  library("readr") # import read_csv
  library("lubridate") # working with dates
  library("RODBC") # import and export SQL data
  library("reshape") # converting AIDS tables into long format
  library("openxlsx") # to have Excel input tables
  library("stringr")
  library("quantmod") # quantitative analysis
  library("ggplot2")
  library("tools") # For file_path_sans_ext
  library("readxl")

  # invisible(utils::memory.limit(64000))

  # define output list for RunCSM function
  RunCSMListOutput <- list()

  print(paste("Run", Run_Nr, Portf, "Beginning of PM10000 IFRS17 Reinsuance runs", Sys.time()))

  setwd(here())
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "http://127.0.0.1:8000/configuration/runsettings/"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Convert JSON to data frame
  RunSettings <- as.data.frame(jsonData)
  # url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-inspect-data"
  # reponse <- GET(url)
  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  # if (http_type(response) != "application/json") {
  # stop("Error: No valid JSON response received")
  # }

  # Parse the JSON response and convert it to a data frame
  # data <- content(response, as = "text", encoding = "UTF-8")
  # RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)
  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which(round(RunSettings$NBRun_Nr, 5) == NBRun_Nr)
  # RunSettingsRowNr <- which(round(RunSettings$NBRun_Nr,5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12

  ForwardInterestRatesName <- RunSettings$ForwardInterestRatesName_NB[RunSettingsRowNr]
  EconomicAssumptionsName <- RunSettings$EconomicAssumptionsName[RunSettingsRowNr]
  RiskAdjustmentApproach <- RunSettings$RiskAdj[RunSettingsRowNr]
  RiskAdjustmentFactor <- RunSettings$RiskAdjustmentFac[RunSettingsRowNr]

  print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business All run settings applied", Sys.time()))

  # EconomicAssumptions
  EconomicAssumptions <- data.frame(read_csv(
    file = paste0("./Assumptions/TABLES/Economic/", EconomicAssumptionsName),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  # Interest rates
  ForwardInterestRates <- data.frame(read_csv(paste0("./Assumptions/TABLES/Curves/", Stress, "/", ForwardInterestRatesName),
    col_types = cols(
      ProjM = col_integer(),
      NominalForwardRate = col_double(),
      RealForwardRate = col_double()
    )
  ))

  ForwardInterestRates <- ForwardInterestRates %>%
    filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
  ForwardInterestRates <- ForwardInterestRates %>%
    mutate(ProjM = row_number()) # Resets ProjM to start at 1

  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Assumptions read successfully", Sys.time()))

  # RiskPremium
  RiskPremium <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "RiskPremium"]
  # Inflation risk premium
  IRP <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "IRP"]

  # curve manipulations
  NominalForwardRate <- ForwardInterestRates$NominalForwardRate
  RealForwardRate <- ForwardInterestRates$RealForwardRate


  RDR_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  RDR_PC_Rel_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Rel_Sens <- 0 # no sensitivies yet in the model

  print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Calibration of discountfactors", Sys.time()))

  # RiskDiscountRate   <- (NominalForwardRate + RiskPremium + RDR_PC_Abs_Sens) * (1 + RDR_PC_Rel_Sens) # both an absolute and relative sensitivity is built in for the risk discount rate
  RiskDiscountRate <- NominalForwardRate # set the RDR to the nominal forward rate
  InflationCurve <- NominalForwardRate - RealForwardRate - IRP

  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRate[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRate[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period

  # Find the last numeric (non-NA) value
  last_numeric_valueStart <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueStart

  last_numeric_valueEnd <- tail(na.omit(DiscountFactorsStart), 1)

  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueEnd

  InflationCurveAbsShock <- InflationCurve + ExpenseInfl_PC_Abs_Sens
  InflationCurveRelShock <- InflationCurve * (1 + ExpenseInfl_PC_Rel_Sens)

  InflationCurve <- pmax(InflationCurveAbsShock, InflationCurveRelShock)

  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)

  print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business reading of fulfilment cashflows", Sys.time()))

  inwd <- here()

  outwd <- file.path(inwd, "Output", NBRun_Nr, Portf, Stress, "NB/Reinsurance")
  file_list <- list.files(outwd, full.names = TRUE)
  file.remove(file_list)

  # Set the working directory to a subdirectory of the input directory using paste0()
  run_dir <- file.path(inwd, "Inputs", Stress, "NB/Reinsurance", NBRun_Nr)
  if (!dir.exists(run_dir)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(run_dir)

  # Get the list of filesData conversion from Excel FCFLOWS to comma separated for NB
  files <- list.files()
  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)


  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 25)
  CFResults_List <- list()

  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-reinsurance-data"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Print debugging information
  print("Debugging Information:")
  print(paste("URL:", url))
  print(paste("HTTP Status:", http_type(response)))

  # Check if the request was successful
  if (http_type(response) != "application/json") {
    # Print HTTP status code if not application/json
    cat("HTTP Status Code:", http_status(response)$status_code, "\n")
    # Print error message if available
    if (!is.null(response$status_message)) {
      cat("Error Message:", response$status_message, "\n")
    }
    stop("Error: No valid JSON response received")
  }

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Print the retrieved data
  print("Data Retrieved Successfully:")
  print(jsonData)

  # Convert JSON to data frame
  FCFVars <- as.data.frame(jsonData)
  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    file_r <- fread(files[i])
    # file = read.xlsx(files[i], sheet = sheetname)
    file_r <- file_r[, -1]
    file_r[file_r == "-"] <- 0



    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r
    library(data.table)

    # Define all needed columns with correct R syntax for names with special characters and spaces
    needed_columns <- c(
      "REINS_PREM_TREATY_OUT(2)", "RPR_PREM_OUT_TREATY_OUT(2)", "FR_REPAYMENT", "FR_CLAWBACK",
      "REINS_PREM_TREATY_OUT(3)", "REINS_PREM_TREATY_OUT(5)", "RPR_PREM_OUT_TREATY_OUT(3)", "RPR_PREM_OUT_TREATY_OUT(5)",
      "REINS_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(3)", "RPR_DTH_REC_TREATY_OUT(5)",
      "RPR_PHIBEN_REC_TREATY_OUT(3)", "RPR_PHIBEN_REC_TREATY_OUT(5)", "RPR_PHIBEN_REC_TREATY_OUT(2)",
      "FR_NEW_FINAN", "REINS_REC_TREATY_OUT(3)", "REINS_REC_TREATY_OUT(5)", "A_REINS_PREM(1)", "RPR_V_PREM_OUT",
      "A_REINS_REC(1)", "RPR_V_DEATH_REC", "RPR_V_PHIBEN_REC",
      "COVERAGE_UNITS_RI_TREATY_OUT(1)", "COVERAGE_UNITS_RI_TREATY_OUT(2)", "COVERAGE_UNITS_RI_TREATY_OUT(3)",
      "COVERAGE_UNITS_RI_TREATY_OUT(4)", "COVERAGE_UNITS_RI_TREATY_OUT(5)"
    )
    Premiums <- rep(0, nrow(file_r))
    # Initialize columns if they do not exist to avoid errors in calculations
    # for (col in needed_columns) {
    # if (!col %in% names(file)) {
    #  file[, (col) := rep(0, .N)]
    # }
    # }


    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }

    Claims <- rep(0, nrow(file_r))
    # Calculate 'Claims' using columns specified in FCFVars$Claims
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }
    # Claims <- (file$`A_REINS_REC(1)` + file$RPR_V_DEATH_REC + file$RPR_V_PHIBEN_REC + file$"REINS_REC_TREATY_OUT(2)" + file$"RPR_DTH_REC_TREATY_OUT(2)" + file$`RPR_DTH_REC_TREATY_OUT(3)` + file$`RPR_DTH_REC_TREATY_OUT(5)` + file$`RPR_PHIBEN_REC_TREATY_OUT(3)`
    #+ file$`RPR_PHIBEN_REC_TREATY_OUT(5)` +
    # file$"RPR_PHIBEN_REC_TREATY_OUT(2)" + file$FR_NEW_FINAN + file$`REINS_REC_TREATY_OUT(3)` + file$`REINS_REC_TREATY_OUT(5)`)

    InitExp <- file$INIT_EXP


    InitExps <- file$INIT_EXP
    Claims_NoFinre <- Claims - file$FR_NEW_FINAN
    Premiums_NoFinRe <- Premiums - file$RPR_V_PREM_OUT
    RiskReinsurance <- Premiums_NoFinRe - Claims_NoFinre




    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]
    PVRiskReins <- sum(RiskReinsurance[2:600] * discountfacStart)
    BELsums[i, 22] <- PVRiskReins
    PVClaims <- sum(discountfacStart * Claims[2:600])

    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    PVInitExp <- sum(discountfacStart * InitExp[2:600])
    CurrInitExp <- sum(InitExp[2:13])

    CurrClaimsAndExpCFS <- sum(Claims[2:13])
    ExpReceivedPremiums <- sum(Premiums[2:13])
    FutRIClaimsAndExp <- sum(Claims[14:600] * DiscountFactorsStart[14:600])
    FutRIPrems <- sum(Premiums[14:600] * DiscountFactorsStart[14:600])

    FinRe <- file$FR_REPAYMENT + file$FR_CLAWBACK - file$FR_NEW_FINAN + file$RPR_V_PREM_OUT
    FinReIncomeCF <- file$FR_NEW_FINAN + file$RPR_V_PREM_OUT
    FinReRepaymentCF <- file$FR_REPAYMENT + file$FR_CLAWBACK

    FinReIncome <- sum(discountfacStart * FinReIncomeCF[2:600])
    FinReRepayment <- sum(discountfacStart * FinReRepaymentCF[2:600])

    BELsums[i, 23] <- FinReIncome
    BELsums[i, 24] <- FinReRepayment
    BELsums[i, 16] <- sum(FinRe[2:600] * discountfacStart)

    BELsums[i, 18] <- PVClaims
    BELsums[i, 19] <- PVPremiums
    BELsums[i, 20] <- PVInitExp
    BELsums[i, 25] <- CurrInitExp

    # CFResults_List[[i]] <- current_df

    current_df <- data.frame(
      Month = 1:599,
      Premiums = Premiums[2:600],
      Recoveries = Claims[2:600],
      FinReIncome = FinReIncomeCF[2:600],
      FinReRepayment = FinReRepaymentCF[2:600],
      RiskReinsuranceRecoveries = Claims_NoFinre[2:600],
      RiskReinsurancePremiums = Premiums_NoFinRe[2:600]
    )

    # Store the data frame in the list
    CFResults_List[[i]] <- current_df

    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * (PVClaims)
      Estimates_FCF <- Premiums[2:600]
      FCF0 <- Estimates_FCF

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0[14:600], discountfacStart, Premiums[14:600],Claims[14:600], discountfacStart)

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future claims at end of period", Sys.time()))


      # PVClaims= sum(discountfacStart*Claims)
      #
      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future cashflows at start of period", Sys.time()))

      # PVExpenses = sum(discountfacStart*Adm)
      BELinf <- sum(Estimates_FCF * discountfacStart)
      BELout <- PVClaims
      pv <- data.frame(Present_Value = BELinf - BELout - RA, BEL = BELinf - BELout) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        Present_Value = pv$Present_Value
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      # BELsums[i,8] <-  length(unique_policies)

      BELsums[i, 7] <- RA
    } else {
      RA <- file$"RISK_ADJ_RI_TREATY_OUT(2)"
      Estimates_FCF <- -Premiums[2:600]
      FCF0 <- Estimates_FCF - RA

      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart), EstFCF = sum(Estimates_FCF * discountfacStart) + PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(-Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value + Pv_cashflows$PVClaims

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV
      BELsums[i, 7] <- pv$RA
      # BELsums[i,8] <-  length(unique_policies)
    }


    #
    # # unique_policies <- unique(POL_NUMBER)
    # discountfacStart = DiscountFactorsStart[1:length(FCF0)]
    # discountfacStart = DiscountFactorsStart[1:length(FCF0)]


    BELsums[i, 6] <- ExpReceivedPremiums
    BELsums[i, 12] <- CurrClaimsAndExpCFS
    BELsums[i, 13] <- FutRIClaimsAndExp
    BELsums[i, 14] <- FutRIPrems
    BELsums[i, 15] <- RiskAdjustmentFactor * CurrClaimsAndExpCFS
    print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Estimate of future cashflows", Sys.time()))

    BELsums[i, 8] <- pv$BEL

    BELsums[i, 9] <- PVClaims

    BEL_i <- pv$BEL
    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    BELsums[i, 2] <- sum(BEL_i)

    IA_fac_1 <- DiscountFactorsStart[1]
    IA_fac_12 <- DiscountFactorsStart[12]

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "Interest accretion on NB CSM", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 2]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 5] <- Interest_accretion

    print(paste("Run", NBRun_Nr, Portf, "Interest accretion on NB BEL", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 8]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 10] <- Interest_accretion

    print(paste("Run", NBRun_Nr, Portf, "Interest accretion on NB RA", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 7]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 11] <- Interest_accretion


    print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Calibration of coverage units", Sys.time()))

    CU_NB_RI <- file$"COVERAGE_UNITS_RI_TREATY_OUT(1)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(2)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(3)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(4)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(5)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(6)"

    CU_NB_RI[is.na(CU_NB_RI)] <- 0

    BELsums[i, 3] <- sum(CU_NB_RI, na.rm = TRUE) # Sum the vector and assign the sum

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))

    CoverageUnits_fac <- sum(CU_NB_RI[2:13]) / sum(CU_NB_RI)
    BELsums[i, 3] <- CoverageUnits_fac

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "CSM is being released to Income Statement", Sys.time()))

    CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
    BELsums[i, 4] <- CSM_release

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 20)
    NewCol <- as.data.frame(rep(pn, length(Pv_cashflows[[2]])))
    colname <- as.data.frame("GROUPING")
    Prophprod <- c(colname, NewCol)
  }
  combined_df <- bind_rows(CFResults_List)

  # Summarise the combined data frame by Month
  ReinsuranceCFS_df <- combined_df %>%
    group_by(Month) %>%
    summarise(
      Total_Premiums = sum(Premiums, na.rm = TRUE),
      Total_Recoveries = sum(Recoveries, na.rm = TRUE),
      Total_FinReIncome = sum(FinReIncome, na.rm = TRUE),
      Total_FinReRepayment = sum(FinReRepayment, na.rm = TRUE),
      Total_RiskReinsuranceRecoveries = sum(RiskReinsuranceRecoveries, na.rm = TRUE),
      Total_RiskReinsurancePremiums = sum(RiskReinsurancePremiums, na.rm = TRUE)
    )
  outwd <- file.path(inwd, "Output", NBRun_Nr, Portf, Stress, "NB/Reinsurance")
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)
  FinReIncome <- as.numeric(BELsums[, 23])
  TotFinReIncome <- sum(FinReIncome)
  FinReRepayment <- as.numeric(BELsums[, 24])
  TotFinReRepayment <- sum(FinReRepayment)
  CurrInitExp <- as.numeric(BELsums[, 25])
  TotCurrInitExp <- sum(CurrInitExp)
  SumsofBELS_NB_RI <- as.numeric(BELsums[, 2])
  SubtotalofBELS_NB_RI <- sum(SumsofBELS_NB_RI)
  CurrRA <- as.numeric(BELsums[, 15])
  PVCommission <- as.numeric(BELsums[, 17])
  TotPVComm <- sum(PVCommission)
  PVClaimsAll <- as.numeric(BELsums[, 18])
  TotPVClaims <- sum(PVClaimsAll)
  PVPremiums <- as.numeric(BELsums[, 19])
  TotPVPrem <- sum(PVPremiums)
  PVInitExp <- as.numeric(BELsums[, 20])
  TotInitExp <- sum(PVInitExp)
  PVFinRe <- as.numeric(BELsums[, 16])
  TotPVFinRe <- sum(PVFinRe)
  RiskRIPrems <- as.numeric(BELsums[, 22])
  TotRiskRIPrems <- sum(RiskRIPrems)
  TotCurrRA <- sum(CurrRA)
  FutRIClaims <- as.numeric(BELsums[, 13])
  TotFutRIClaims <- sum(FutRIClaims)
  FutRIPrems <- as.numeric(BELsums[, 14])
  TotFutRIPrems <- sum(FutRIPrems)
  IFRS17_group_NB_RI <- c(Item_names, "Total")
  ClaimsCurr <- as.numeric(BELsums[, 12])
  TotPVClaimsCurr <- sum(ClaimsCurr)
  CU_NB_RI <- as.numeric(BELsums[, 3])
  Interest_accretion_NB_RI <- as.numeric(BELsums[, 5])
  Interest_accBEL_NB_RI <- as.numeric(BELsums[, 10])
  TotIABEL_NB_RI <- sum(Interest_accBEL_NB_RI)
  Interest_accRA_NB_RI <- as.numeric(BELsums[, 11])
  TotIA_RA_NB_RI <- sum(Interest_accRA_NB_RI)
  PVFP_Curr_NB_RI <- as.numeric(BELsums[, 6])
  BELs_NB_RI <- as.numeric(BELsums[, 8])
  TotFCF_NB_RI <- sum(BELs_NB_RI)
  PVClaims_NB_RI <- as.numeric(BELsums[, 9])
  TotPVClaims_NB_RI <- sum(PVClaims_NB_RI)
  RiskAdj_NB_RI <- as.numeric(BELsums[, 7])
  TotRiskAdj_NB_RI <- sum(RiskAdj_NB_RI)
  TotCurrPVFP_NB_RI <- sum(PVFP_Curr_NB_RI)
  TotInterestAccret_NB_RI <- sum(Interest_accretion_NB_RI)
  CSMrelease_NB_RI <- as.numeric(BELsums[, 4])
  TotalCSMrelease_NB_RI <- sum(CSMrelease_NB_RI)
  avgCU_NB_RI <- mean(CU_NB_RI)

  SumofBELs_df_NB_RI <- data.frame(IFRS17_group_NB_RI,
    CSM_LCpergroup = c(SumsofBELS_NB_RI, SubtotalofBELS_NB_RI), CoverageUnits = c(CU_NB_RI, avgCU_NB_RI),
    CurrRA = c(CurrRA, TotCurrRA), CurrInitExp = c(CurrInitExp, TotCurrInitExp), FutRIPrems = c(FutRIPrems, TotFutRIPrems), FutRIClaims = c(FutRIClaims, TotFutRIClaims),
    CSM_LRecC_released = c(CSMrelease_NB_RI, TotalCSMrelease_NB_RI),
    Interest_Accreted_NB = c(Interest_accretion_NB_RI, TotInterestAccret_NB_RI), Interest_accBEL = c(Interest_accBEL_NB_RI, TotIABEL_NB_RI),
    Interest_accRA_NB_RI = c(Interest_accRA_NB_RI, TotIA_RA_NB_RI), PVFCurrPrems = c(PVFP_Curr_NB_RI, TotCurrPVFP_NB_RI),
    CurrClaims = c(ClaimsCurr, TotPVClaimsCurr), PVClaims = c(PVClaims_NB_RI, TotPVClaims_NB_RI), PVFinre = c(PVFinRe, TotPVFinRe),
    RA = c(RiskAdj_NB_RI, TotRiskAdj_NB_RI), BEL = c(BELs_NB_RI, TotFCF_NB_RI), TotPVClaims = c(PVClaimsAll, TotPVClaims), PVRiskRIPrems = c(RiskRIPrems, TotRiskRIPrems),
    PVPremiums = c(PVPremiums, TotPVPrem), TotFinReIncome = c(FinReIncome, TotFinReIncome), TotFinReRepayment = c(FinReRepayment, TotFinReRepayment)
  )
  write.csv(SumofBELs_df_NB_RI, paste(NBRun_Nr, Portf, "Reinsurance", "_NB BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  #################################################### NB Recognition report################################################################
  wb <- loadWorkbook(here("Reports/Templates/Report 1.3 NB Recognition.xlsx"))
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = sum(SumofBELs_df_NB_RI$BEL[c(1, 3)]), startCol = 2, startRow = 17) # NON ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = SumofBELs_df_NB_RI$BEL[2], startCol = 2, startRow = 18) # ONEROUS CONTRACTS
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = sum(SumofBELs_df_NB_RI$RA[c(1, 3)]), startCol = 3, startRow = 17) # NON ONEROUS CONTRACTS RA
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = SumofBELs_df_NB_RI$RA[2], startCol = 3, startRow = 18) # ONEROUS CONTRACTS RA
  csm_nononerous <- sum(SumofBELs_df_NB_RI$BEL[c(1, 3)]) + sum(SumofBELs_df_NB_RI$RA[c(1, 3)])
  csm_onerous <- SumofBELs_df_NB_RI$BEL[2] + SumofBELs_df_NB_RI$RA[2]

  # Write the calculated values to the Excel sheet
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = csm_nononerous, startCol = 4, startRow = 17) # NON ONEROUS CONTRACTS CSM
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = csm_onerous, startCol = 4, startRow = 18) # ONEROUS CONTRACTS CSM
  message1 <- paste0("This report shows a summary of the Insurance Contracts Recognised in ", Run_Nr, " for the Portfolio: ", Portf)
  writeData(wb, sheet = "Report 1.3 NB Recognition-Ins", x = message1, startCol = 1, startRow = 12)
  message2 <- paste0("This report shows a summary of the Reinsurance Contracts Recognised in ", Run_Nr, " for the Portfolio: ", Portf)
  writeData(wb, sheet = "Report 1.3 NB Recognition-Reins", x = message2, startCol = 1, startRow = 13)

  output_dir <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports"))
  output_file <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports/Report 1.3 NB Recognition.xlsx"))

  # Create the directory if it does not exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  # Save the workbook
  saveWorkbook(wb, output_file, overwrite = TRUE)
  # edwin_df <- data.frame(Premiums = Premiums[2:600], Claims = Claims[2:600])
  # write.csv(edwin_df,paste(Run_Nr, 'Reinsurance Quickbits.csv'),append = FALSE, row.names = FALSE, sep = "," )
  print(paste("Run", Run_Nr, Portf, "Reinsurance", "NB CSM calculations done", Sys.time()))
  run_dir <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS/NB/Reinsurance/NB Reinsurance CFs")

  # Create the directory if it doesn't exist
  if (!dir.exists(run_dir)) {
    dir.create(run_dir, recursive = TRUE)
  }

  # Set the working directory
  setwd(run_dir)
  write.csv(ReinsuranceCFS_df, paste(Run_Nr, Portf, "NB Reinsurance CFs.csv"), append = FALSE, row.names = FALSE, sep = ",")

  results_NB_RI <- list(
    SumofBELs_df_NB_RI = SumofBELs_df_NB_RI,
    SumsofBELS_NB_RI = as.numeric(BELsums[, 2]),
    SubtotalofBELS_NB_RI = sum(SumsofBELS_NB_RI),
    IFRS17_group_NB_RI = c(Item_names, "Total"),
    CU_NB_RI = as.numeric(BELsums[, 3]),
    Interest_accretion_NB_RI = as.numeric(BELsums[, 5]),
    Interest_accBEL_NB_RI = as.numeric(BELsums[, 10]),
    TotIABEL_NB_RI = sum(Interest_accBEL_NB_RI),
    Interest_accRA_NB_RI = as.numeric(BELsums[, 11]),
    TotIA_RA_NB_RI = sum(Interest_accRA_NB_RI),
    BELs_NB_RI = as.numeric(BELsums[, 8]),
    TotFCF_NB_RI = sum(BELs_NB_RI),
    PVClaims_NB_RI = as.numeric(BELsums[, 9]),
    TotPVClaims_NB_RI = sum(PVClaims_NB_RI),
    RiskAdj_NB_RI = as.numeric(BELsums[, 7]),
    TotRiskAdj_NB_RI = sum(RiskAdj_NB_RI),
    TotInterestAccret_NB_RI = sum(Interest_accretion_NB_RI),
    CSMrelease_NB_RI = as.numeric(BELsums[, 4]),
    TotalCSMrelease_NB_RI = sum(CSMrelease_NB_RI),
    avgCU_NB_RI = mean(CU_NB_RI)
  )



  ############################################################# Opening IN FORCE at locked in rates ############################################


  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Inforce at end Start of CSM calculations", Sys.time()))

  ################# FUNCTIONS ###############################

  elapsed_months <- function(end_date, start_date) {
    ed <- as.POSIXlt(end_date)
    sd <- as.POSIXlt(start_date)
    (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
  }

  ################# RUN SETTINGS ##########################

  setwd(here())
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "http://127.0.0.1:8000/configuration/runsettings/"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Convert JSON to data frame
  RunSettings <- as.data.frame(jsonData)
  # url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-inspect-data"
  # reponse <- GET(url)
  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  # if (http_type(response) != "application/json") {
  # stop("Error: No valid JSON response received")
  # }

  # Parse the JSON response and convert it to a data frame
  # data <- content(response, as = "text", encoding = "UTF-8")
  # RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)
  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which((RunSettings$Run_Nr) == Run_Nr)
  # RunSettingsRowNr <- which(round(RunSettings$Run_Nr,5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12


  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  ######## Assumption / Parameter manipulations to be used by model

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)


  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Inforce at end reading of FCFs", Sys.time()))

  inwd <- here()

  outwd <- file.path(inwd, "Output", Run_Nr, Portf, Stress, "IF")
  file_list <- list.files(outwd, full.names = TRUE)
  file.remove(file_list)

  run_dir <- file.path(inwd, "Inputs", Stress, "IF/Reinsurance", Run_Nr)
  if (!dir.exists(run_dir)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(run_dir)

  # Get the list of files
  files <- list.files()
  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)


  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 22)

  print(paste("Run", Run_Nr, "Reinsurance", "Locking the yield curve for each cohort", Sys.time()))
  #
  # COHORT <- numeric(4)
  #
  # yield_curvesStart <- list()
  # yield_curvesEnd <- list()
  #
  # master_results <- data.frame()

  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    year_match <- as.integer(sub("^(\\d{4})_.*\\.csv$", "\\1", files[i]))

    COHORT <- year_match

    # Interest Rate Data Reading
    ForwardInterestRatesNameLockedCohort <- paste0("Forw_", COHORT, ".csv")
    filepath <- file.path(here("Assumptions/TABLES/Curves", Stress), ForwardInterestRatesNameLockedCohort)
    ForwardInterestRatesLocked <- read_csv(filepath, col_types = cols(ProjM = col_integer(), NominalForwardRate = col_double(), RealForwardRate = col_double()))

    ForwardInterestRatesLocked <- ForwardInterestRatesLocked %>%
      filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
    ForwardInterestRatesLocked <- ForwardInterestRatesLocked %>%
      mutate(ProjM = row_number()) # Resets ProjM to start at 1


    # Print Log Information
    print(paste("Run", Run_Nr, Portf, "Reinsurance", "Calibration of discount factors using Locked-in curves for interest accretion on IF", Sys.time()))


    # Extracting Interest Rates
    RiskDiscountRatesLocked <- ForwardInterestRatesLocked$NominalForwardRate
    RealForwardRatesLocked <- ForwardInterestRatesLocked$RealForwardRate

    # Calculate Discount Factors
    DiscountFactorsStartLocked <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRatesLocked[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
    DiscountFactorsStartLocked <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRatesLocked[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period

    last_numeric_valueStartLocked <- tail(na.omit(DiscountFactorsStartLocked), 1)

    # Replace NA values with the last numeric value
    DiscountFactorsStartLocked[is.na(DiscountFactorsStartLocked)] <- last_numeric_valueStartLocked

    last_numeric_valueEndLocked <- tail(na.omit(DiscountFactorsStartLocked), 1)

    # Replace NA values with the last numeric value
    DiscountFactorsStartLocked[is.na(DiscountFactorsStartLocked)] <- last_numeric_valueEndLocked

    file_r <- fread(files[i])
    # file = read.xlsx(files[i], sheet = sheetname)

    file_r <- file_r[, -1]

    file_r[file_r == "-"] <- 0

    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r

    # Define all needed columns with correct R syntax for names with special characters and spaces
    needed_columns <- c(
      "REINS_PREM_TREATY_OUT(2)", "RPR_PREM_OUT_TREATY_OUT(2)", "FR_REPAYMENT", "FR_CLAWBACK",
      "REINS_PREM_TREATY_OUT(3)", "REINS_PREM_TREATY_OUT(5)", "RPR_PREM_OUT_TREATY_OUT(3)", "RPR_PREM_OUT_TREATY_OUT(5)",
      "REINS_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(3)", "RPR_DTH_REC_TREATY_OUT(5)",
      "RPR_PHIBEN_REC_TREATY_OUT(3)", "RPR_PHIBEN_REC_TREATY_OUT(5)", "RPR_PHIBEN_REC_TREATY_OUT(2)",
      "FR_NEW_FINAN", "REINS_REC_TREATY_OUT(3)", "REINS_REC_TREATY_OUT(5)", "A_REINS_PREM(1)", "RPR_V_PREM_OUT",
      "A_REINS_REC(1)", "RPR_V_DEATH_REC", "RPR_V_PHIBEN_REC",
      "COVERAGE_UNITS_RI_TREATY_OUT(1)", "COVERAGE_UNITS_RI_TREATY_OUT(2)", "COVERAGE_UNITS_RI_TREATY_OUT(3)",
      "COVERAGE_UNITS_RI_TREATY_OUT(4)", "COVERAGE_UNITS_RI_TREATY_OUT(5)"
    )

    # Initialize columns if they do not exist to avoid errors in calculations
    # for (col in needed_columns) {
    # if (!col %in% names(file)) {
    #   file[, (col) := rep(0, .N)]
    #  }
    # }
    Premiums <- rep(0, nrow(file_r))

    # Calculate 'Premiums' using columns specified in FCFVars$Premiums
    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }

    Claims <- rep(0, nrow(file_r))
    # Claims <- (file$`A_REINS_REC(1)` + file$RPR_V_DEATH_REC + file$RPR_V_PHIBEN_REC + file$"REINS_REC_TREATY_OUT(2)" + file$"RPR_DTH_REC_TREATY_OUT(2)" + file$`RPR_DTH_REC_TREATY_OUT(3)` + file$`RPR_DTH_REC_TREATY_OUT(5)` + file$`RPR_PHIBEN_REC_TREATY_OUT(3)`
    # + file$`RPR_PHIBEN_REC_TREATY_OUT(5)` +
    # file$"RPR_PHIBEN_REC_TREATY_OUT(2)" + file$FR_NEW_FINAN + file$`REINS_REC_TREATY_OUT(3)` + file$`REINS_REC_TREATY_OUT(5)`)
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }

    Claims_NoFinre <- Claims - file$FR_NEW_FINAN

    Premiums_NoFinRe <- Premiums - file$RPR_V_PREM_OUT
    RiskReinsurance <- Premiums_NoFinRe - Claims_NoFinre

    FinRe <- file$RPR_V_PREM_OUT + file$FR_REPAYMENT + file$FR_CLAWBACK - file$FR_NEW_FINAN
    InitExp <- file$INIT_EXP
    CurrInitExp <- sum(InitExp[2:13])

    BELsums[i, 18] <- sum(RiskReinsurance[2:600] * discountfacStart)

    BELsums[i, 15] <- sum(FinRe[2:600] * discountfacStart)

    discountfacStart <- DiscountFactorsStartLocked[2:600]
    discountfacStart <- DiscountFactorsStartLocked[2:600]

    PVClaims <- sum(discountfacStart * Claims[2:600])
    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    Undisc_Rec <- sum(Claims)
    Undisc_Prem <- sum(Premiums)
    BELsums[i, 17] <- Undisc_Prem
    BELsums[i, 16] <- Undisc_Rec
    CurrClaimsAndExpCFS <- sum(Claims[2:13])
    ExpReceivedPremiums <- sum(Premiums[2:13])
    FutRIClaimsAndExp <- sum(Claims[14:600] * DiscountFactorsStartLocked[14:600])
    FutRIPrems <- sum(Premiums[14:600] * DiscountFactorsStartLocked[14:600])

    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * (PVClaims)
      Estimates_FCF <- Premiums
      FCF0 <- Estimates_FCF

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0[14:600], discountfacStart, Premiums,Claims, discountfacStart)

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future claims at end of period", Sys.time()))


      # PVClaims= sum(discountfacStart*Claims)
      #
      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future cashflows at start of period", Sys.time()))

      # PVExpenses = sum(discountfacStart*Adm)

      BELinf <- sum(Estimates_FCF[2:600] * discountfacStart)
      BELout <- PVClaims
      pv <- data.frame(Present_Value = BELinf - BELout - RA, BEL = BELinf - BELout) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        Present_Value = pv$Present_Value
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV
      BELsums[i, 7] <- RA
    } else {
      RA <- file$"RISK_ADJ_RI_TREATY_OUT(2)"
      Estimates_FCF <- -Premiums
      FCF0 <- Estimates_FCF - RA


      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart), EstFCF = sum(Estimates_FCF * discountfacStart) + PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(-Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      Pv_cashflows$NPV <- Pv_cashflows$Present_Value + Pv_cashflows$PVClaims

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV

      BELsums[i, 7] <- pv$RA
    }


    BEL_i <- pv$BEL
    # BEL_i <- pv$BEL
    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    # BELsums[, 1] <- files
    BELsums[i, 2] <- sum(BEL_i)



    IA_fac_1 <- DiscountFactorsStart[1]
    IA_fac_12 <- DiscountFactorsStart[12]

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "Inforce at end AoCSM, interest accretion", Sys.time()))

    Interest_accretion <- as.numeric(BELsums[i, 2]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 5] <- Interest_accretion

    BELsums[i, 6] <- pv$BEL



    print(paste("Run", Run_Nr, Portf, "Reinsurance Inforce at end interest accretion on BEL", Sys.time()))

    Interest_accBEL <- as.numeric(BELsums[i, 6]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 8] <- Interest_accBEL

    print(paste("Run", Run_Nr, Portf, "Reinsurance Inforce at end interest accretion on RA", Sys.time()))

    Interest_accRA <- as.numeric(BELsums[i, 7]) * as.numeric(IA_fac_1 - IA_fac_12)
    BELsums[i, 9] <- Interest_accRA

    BELsums[i, 10] <- ExpReceivedPremiums
    BELsums[i, 11] <- CurrClaimsAndExpCFS
    BELsums[i, 12] <- FutRIClaimsAndExp
    BELsums[i, 13] <- FutRIPrems
    BELsums[i, 14] <- RiskAdjustmentFactor * CurrClaimsAndExpCFS

    BELsums[i, 20] <- PVClaims
    BELsums[i, 21] <- PVPremiums
    BELsums[i, 22] <- CurrInitExp

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "Inforce at end Calibration of coverage units", Sys.time()))
    CU_IF_RICLS_LIYC <- file$"COVERAGE_UNITS_RI_TREATY_OUT(1)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(2)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(3)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(4)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(5)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(6)"

    CU_IF_RICLS_LIYC[is.na(CU_IF_RICLS_LIYC)] <- 0

    BELsums[i, 3] <- sum(CU_IF_RICLS_LIYC, na.rm = TRUE) # Sum the vector and assign the sum

    print(paste("Run", Run_Nr, Portf, "Reinsurance", "Inforce at end discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    # CU <- unlist(result)
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))
    #
    CU <- file$"COVERAGE_UNITS_RI_TREATY_OUT(1)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(2)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(3)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(4)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(5)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(6)"

    CoverageUnits_fac <- sum(CU[2:13]) / sum(CU)


    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 15)

    print(paste("Run", Run_Nr, Portf, pn, "Inforce at end discounting coverage Units", Sys.time()))



    print(paste("Run", Run_Nr, Portf, "Reinsurance", "CSM released to the Income Statement", Sys.time()))

    CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
    BELsums[i, 4] <- CSM_release
    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 7)
  }
  outwd <- file.path(inwd, "Output", Run_Nr, Portf, Stress, "Locked/IF/Reinsurance")
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)


  PVClaimsAll <- as.numeric(BELsums[, 20])
  TotPVClaims <- sum(PVClaimsAll)
  PVPremiums <- as.numeric(BELsums[, 21])
  TotPVPrem <- sum(PVPremiums)
  CurrInitExp <- as.numeric(BELsums[, 22])
  TotCurrInitExp <- sum(CurrInitExp)
  SumsofBELS_IF_RICLS_LIYC <- as.numeric(BELsums[, 2])
  SubtotalofBELS_IF_RICLS_LIYC <- sum(SumsofBELS_IF_RICLS_LIYC)
  FutRIClaims <- as.numeric(BELsums[, 12])
  Undisc_Rec <- as.numeric(BELsums[, 16])
  Undisc_Prem <- as.numeric(BELsums[, 17])
  RiskRi <- as.numeric(BELsums[, 18])
  TotRiskRi <- sum(RiskRi)
  TotUndisc_Prem <- sum(Undisc_Prem)
  TotUndisc_Rec <- sum(Undisc_Rec)
  TotFutRIClaims <- sum(FutRIClaims)
  CurrRA <- as.numeric(BELsums[, 14])
  TotCurrRA <- sum(CurrRA)
  PVFinRe <- as.numeric(BELsums[, 15])
  TotFinRe <- sum(PVFinRe)
  FutRIPrems <- as.numeric(BELsums[, 13])
  ClaimsCurr <- as.numeric(BELsums[, 11])
  TotPVClaimsCurr <- sum(ClaimsCurr)
  TotFutRIPrems <- sum(FutRIPrems)
  CurrPrems <- as.numeric(BELsums[, 10])
  TotCurrRIPrems <- sum(CurrPrems)
  IFRS17_group_IF_RICLS_LIYC <- c(Item_names, "Total")
  CU_IF_RICLS_LIYC <- as.numeric(BELsums[, 3])
  Interest_accretion_IF_RICLS_LIYC <- as.numeric(BELsums[, 5])
  TotInterestAccret_IFCLS_LIYC_IF_RICLS_LIYC <- sum(Interest_accretion_IF_RICLS_LIYC)
  Interest_accBEL_IF_RICLS_LIYC <- as.numeric(BELsums[, 8])
  TotIABEL_IF_RICLS_LIYC <- sum(Interest_accBEL_IF_RICLS_LIYC)
  Interest_accRA_IF_RICLS_LIYC <- as.numeric(BELsums[, 9])
  TotIA_RA_IF_RICLS_LIYC <- sum(Interest_accRA_IF_RICLS_LIYC)
  CSMrelease_IF_RICLS_LIYC <- as.numeric(BELsums[, 4])
  BELs_IF_RICLS_LIYC <- as.numeric(BELsums[, 6])
  TotFCF_IF_RICLS_LIYC <- sum(BELs_IF_RICLS_LIYC)
  RiskAdj_IF_RICLS_LIYC <- as.numeric(BELsums[, 7])
  TotRiskAdj_IF_RICLS_LIYC <- sum(RiskAdj_IF_RICLS_LIYC)
  TotalCSMrelease_IF_RICLS_LIYC <- sum(CSMrelease_IF_RICLS_LIYC)
  avgCU_IF_RICLS_LIYC <- as.numeric(mean(CU_IF_RICLS_LIYC))

  SumofBELs_df_IF_RICLS_LIYC <- data.frame(IFRS17_group_IF_RICLS_LIYC, CoverageUnits = c(CU_IF_RICLS_LIYC, avgCU_IF_RICLS_LIYC), CurrRA = c(CurrRA, TotCurrRA), CurrInitExp = c(CurrInitExp, TotCurrInitExp), CurrRIPrems = c(CurrPrems, TotCurrRIPrems), FutRIPrems = c(FutRIPrems, TotFutRIPrems), CurrClaims = c(ClaimsCurr, TotPVClaimsCurr), FutRIClaims = c(FutRIClaims, TotFutRIClaims), CSM_LRecC_released = c(CSMrelease_IF_RICLS_LIYC, TotalCSMrelease_IF_RICLS_LIYC), Interest_Accreted_IF = c(Interest_accretion_IF_RICLS_LIYC, TotInterestAccret_IFCLS_LIYC_IF_RICLS_LIYC), Interest_accBEL = c(Interest_accBEL_IF_RICLS_LIYC, TotIABEL_IF_RICLS_LIYC), FinRe = c(PVFinRe, TotFinRe), RiskRI = c(RiskRi, TotRiskRi), Interest_accRA = c(Interest_accRA_IF_RICLS_LIYC, TotIA_RA_IF_RICLS_LIYC), RA = c(RiskAdj_IF_RICLS_LIYC, TotRiskAdj_IF_RICLS_LIYC), UndiscRec = c(Undisc_Rec, TotUndisc_Rec), UndiscPremi = c(Undisc_Prem, TotUndisc_Prem), BEL = c(BELs_IF_RICLS_LIYC, TotFCF_IF_RICLS_LIYC), TotPVClaims = c(PVClaimsAll, TotPVClaims), PVPremiums = c(PVPremiums, TotPVPrem))
  print(paste("Run", Run_Nr, "Reinsurance", "Printing Start year valuaion results to CSV file", Sys.time()))
  write.csv(SumofBELs_df_IF_RICLS_LIYC, paste(Run_Nr, Portf, "Reinsurance Locked_BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  print(paste("Run", Run_Nr, "Reinsurance", "CSM for IF calculations done", Sys.time()))

  ################################### CSM run-off report ###################################################################
  # CSM report
  wb <- loadWorkbook(here("Reports/Templates/Report 1.2 CSM run-off.xlsx"))
  writeData(wb, sheet = "METADATA", x = CU, startCol = 4, startRow = 3)
  writeData(wb, sheet = "Report 1.2 - CSM release", x = paste0("This report shows the Projected release of the CSM into the Income Statement at the Current and Prior reporting periods. Portfolio: ", Portf), startCol = 1, startRow = 14)

  output_dir <- here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports"))
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  saveWorkbook(wb, here(paste0("Output/", Run_Nr, "/", Portf, "/", Stress, "/Reports/Report 1.2 CSM run-off.xlsx")), overwrite = TRUE)


  results_IF_RICLS_LIYC <- list(
    SumofBELs_df_IF_RICLS_LIYC = SumofBELs_df_IF_RICLS_LIYC,
    SumsofBELS_IF_RICLS_LIYC = as.numeric(BELsums[, 2]),
    SubtotalofBELS_IF_RICLS_LIYC = sum(SumsofBELS_IF_RICLS_LIYC),
    IFRS17_group_IF_RICLS_LIYC = c(Item_names, "Total"),
    CU_IF_RICLS_LIYC = as.numeric(BELsums[, 3]),
    Interest_accretion_IF_RICLS_LIYC = as.numeric(BELsums[, 5]),
    TotInterestAccret_IFCLS_LIYC_IF_RICLS_LIYC = sum(Interest_accretion_IF_RICLS_LIYC),
    Interest_accBEL_IF_RICLS_LIYC = as.numeric(BELsums[, 8]),
    TotIABEL_IF_RICLS_LIYC = sum(Interest_accBEL_IF_RICLS_LIYC),
    Interest_accRA_IF_RICLS_LIYC = as.numeric(BELsums[, 9]),
    TotIA_RA_IF_RICLS_LIYC = sum(Interest_accRA_IF_RICLS_LIYC),
    CSMrelease_IF_RICLS_LIYC = as.numeric(BELsums[, 4]),
    BELs_IF_RICLS_LIYC = as.numeric(BELsums[, 6]),
    TotFCF_IF_RICLS_LIYC = sum(BELs_IF_RICLS_LIYC),
    RiskAdj_IF_RICLS_LIYC = as.numeric(BELsums[, 7]),
    TotRiskAdj_IF_RICLS_LIYC = sum(RiskAdj_IF_RICLS_LIYC),
    TotalCSMrelease_IF_RICLS_LIYC = sum(CSMrelease_IF_RICLS_LIYC),
    avgCU_IF_RICLS_LIYC = mean(CU_IF_RICLS_LIYC)
  )




  ####################################### VALUATION at the end  ##########################################################

  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Closing Inforce at Current rates", Sys.time()))

  ################# FUNCTIONS ###############################

  elapsed_months <- function(end_date, start_date) {
    ed <- as.POSIXlt(end_date)
    sd <- as.POSIXlt(start_date)
    (12 * (ed$year - sd$year) + (ed$mon - sd$mon))
  }

  ################# RUN SETTINGS ##########################

  setwd(here())
  # Install and load required packages if not already installed
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
  }
  library(httr)

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  library(jsonlite)

  if (!requireNamespace("data.table", quietly = TRUE)) {
    install.packages("data.table")
  }
  library(data.table)

  # Define the URL of your Flask endpoint
  url <- "http://127.0.0.1:8000/configuration/runsettings/"

  # Make a GET request to retrieve data
  response <- GET(url)

  # Parse JSON response
  data <- content(response, as = "text", encoding = "UTF-8")

  # Convert JSON to R object
  jsonData <- fromJSON(data)

  # Convert JSON to data frame
  RunSettings <- as.data.frame(jsonData)
  # url <- "https://pam1000-zkekojo2lq-uc.a.run.app/get-inspect-data"
  # reponse <- GET(url)
  # RunSettingsWB <- loadWorkbook(file.path(".", "Parameters", "RunSettings.xlsx"))
  # RunSettingsWB = read_excel(file.path(".","Parameters","RunSettings.xlsx"))
  # if (http_type(response) != "application/json") {
  # stop("Error: No valid JSON response received")
  # }

  # Parse the JSON response and convert it to a data frame
  # data <- content(response, as = "text", encoding = "UTF-8")
  # RunSettings <- as.data.frame(fromJSON(data))

  # Print the fetched data for verification
  print(RunSettings)
  # Import run setting file for current run
  # RunSettings <- read.xlsx(RunSettingsWB, sheet = "RunSettings")

  RunSettingsRowNr <- which((RunSettings$Run_Nr) == Run_Nr)
  # RunSettingsRowNr <- which(round(RunSettings$Run_Nr,"Reinsurance",5) == 2006)

  ################# SET PARAMETERS ##########################

  ParameterTable <- data.frame(read_csv(
    file = paste0("./Parameters/", "ParameterTable.csv"),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  MaxProjY <- ParameterTable$Value_N[ParameterTable$ParameterName == "MaxProjY"]

  MaxProjY_Sens <- MaxProjY # by default use the number of years specified in the parameter file

  # set the Max projection month
  MaxProjY <- MaxProjY_Sens
  MaxProjM <- MaxProjY_Sens * 12

  ForwardInterestRatesName <- RunSettings$ForwardInterestRatesName_IFend[RunSettingsRowNr]
  EconomicAssumptionsName <- RunSettings$EconomicAssumptionsName[RunSettingsRowNr]

  print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "All run settings applied", Sys.time()))

  # EconomicAssumptions
  EconomicAssumptions <- data.frame(read_csv(
    file = paste0("./Assumptions/TABLES/Economic/", EconomicAssumptionsName),
    col_types = cols(
      Value_D = col_date(format = "%Y/%m/%d"),
      Value_N = col_double(),
      Value_C = col_character()
    )
  ))

  # Interest rates
  ForwardInterestRates <- data.frame(read_csv(paste0("./Assumptions/TABLES/Curves/", Stress, "/", ForwardInterestRatesName),
    col_types = cols(
      ProjM = col_integer(),
      NominalForwardRate = col_double(),
      RealForwardRate = col_double()
    )
  ))
  ForwardInterestRates <- ForwardInterestRates %>%
    filter(!is.na(NominalForwardRate) & !is.na(RealForwardRate))
  ForwardInterestRates <- ForwardInterestRates %>%
    mutate(ProjM = row_number()) # Resets ProjM to start at 1
  # RiskPremium
  RiskPremium <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "RiskPremium"]
  # Inflation risk premium
  IRP <- EconomicAssumptions$Value_N[EconomicAssumptions$ParameterName == "IRP"]

  # curve manipulations
  NominalForwardRate <- ForwardInterestRates$NominalForwardRate
  RealForwardRate <- ForwardInterestRates$RealForwardRate


  RDR_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  RDR_PC_Rel_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Abs_Sens <- 0 # no sensitivies yet in the model
  ExpenseInfl_PC_Rel_Sens <- 0 # no sensitivies yet in the model

  print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "Calibration of discountfactors at current rates", Sys.time()))

  # RiskDiscountRate   <- (NominalForwardRate + RiskPremium + RDR_PC_Abs_Sens) * (1 + RDR_PC_Rel_Sens) # both an absolute and relative sensitivity is built in for the risk discount rate
  RiskDiscountRate <- NominalForwardRate # set the RDR to the nominal forward rate
  InflationCurve <- NominalForwardRate - RealForwardRate - IRP

  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) if (x == 1) 1 else prod((1 + RiskDiscountRate[1:(x - 1)])^(-1 / 12))) # used for cashflows at the start of the projection period
  DiscountFactorsStart <- sapply(X = 1:(MaxProjM + 12), FUN = function(x) prod((1 + RiskDiscountRate[1:x])^(-1 / 12))) # used for cashflows at the end   of the projection period
  # DiscountFactorsStart          = sapply(X = 1:(MaxProjM), FUN = function(x) if(x == 1) 1 else prod((1+RiskDiscountRate[1:(x-1)])^(-1))) # used for cashflows at the start of the projection period
  # DiscountFactorsStart            = sapply(X = 1:(MaxProjM), FUN = function(x)                   prod((1+RiskDiscountRate[1: x   ])^(-1))) # used for cashflows at the end   of the projection period

  last_numeric_valueStart <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueStart

  last_numeric_valueEnd <- tail(na.omit(DiscountFactorsStart), 1)

  # Replace NA values with the last numeric value
  DiscountFactorsStart[is.na(DiscountFactorsStart)] <- last_numeric_valueEnd

  InflationCurveAbsShock <- InflationCurve + ExpenseInfl_PC_Abs_Sens
  InflationCurveRelShock <- InflationCurve * (1 + ExpenseInfl_PC_Rel_Sens)

  InflationCurve <- pmax(InflationCurveAbsShock, InflationCurveRelShock)



  ## Function to keep dates as dates in ifelse##
  safe.ifelse <- function(cond, yes, no) {
    class.y <- class(yes)
    X <- ifelse(cond, yes, no)
    class(X) <- class.y
    return(X)
  }

  ######## Assumption / Parameter manipulations to be used by model

  # Sequence for the projection months
  ProjM <- seq(MaxProjM)


  print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "reading of FCFs", Sys.time()))

  inwd <- here()

  outwd <- file.path(inwd, "Output", Run_Nr, Portf, Stress, "IF")
  file_list <- list.files(outwd, full.names = TRUE)
  file.remove(file_list)

  run_dir <- file.path(inwd, "Inputs", Stress, "IF/Reinsurance", Run_Nr)
  if (!dir.exists(run_dir)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(run_dir)

  # Get the list of files
  files <- list.files()
  # Conditional file filtering
  if (Portf == "GL") {
    files <- grep("Cell", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for GL:")
    print(files)
  } else if (Portf == "FDOC") {
    files <- grep("FDOC", files, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for FDOC:")
    print(files)
  } else if (Portf == "BLL") {
    files <- grep("Cell|FDOC", files, invert = TRUE, value = TRUE)
    if (length(files) == 0) {
      files <- list("")
    }
    print("Filtered files for BLL:")
    print(files)
  } else {
    files <- list("")
    print("No matching portfolio, files set to empty list:")
    print(files)
  }

  # Final debug print statement
  print("Final files:")
  print(files)


  Item_names <- gsub("\\.csv$", "", files)
  BELsums <- matrix(0, nrow = length(files), ncol = 26)
  CFResults <- matrix(0, nrow = 599, ncol = 4)
  CFResults_List <- list()
  # Loop through the files
  for (i in 1:length(files)) {
    setwd(run_dir)
    # Read in the data

    file_r <- fread(files[i])
    # file = read.xlsx(files[i], sheet = sheetname)

    file_r <- file_r[, -1]

    file_r[file_r == "-"] <- 0



    file_r[is.na(file_r)] <- 0

    file_r

    file <- file_r
    # Define all needed columns with correct R syntax for names with special characters and spaces
    needed_columns <- c(
      "REINS_PREM_TREATY_OUT(2)", "RPR_PREM_OUT_TREATY_OUT(2)", "FR_REPAYMENT", "FR_CLAWBACK",
      "REINS_PREM_TREATY_OUT(3)", "REINS_PREM_TREATY_OUT(5)", "RPR_PREM_OUT_TREATY_OUT(3)", "RPR_PREM_OUT_TREATY_OUT(5)",
      "REINS_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(2)", "RPR_DTH_REC_TREATY_OUT(3)", "RPR_DTH_REC_TREATY_OUT(5)",
      "RPR_PHIBEN_REC_TREATY_OUT(3)", "RPR_PHIBEN_REC_TREATY_OUT(5)", "RPR_PHIBEN_REC_TREATY_OUT(2)",
      "FR_NEW_FINAN", "REINS_REC_TREATY_OUT(3)", "REINS_REC_TREATY_OUT(5)", "A_REINS_PREM(1)", "RPR_V_PREM_OUT",
      "A_REINS_REC(1)", "RPR_V_DEATH_REC", "RPR_V_PHIBEN_REC",
      "COVERAGE_UNITS_RI_TREATY_OUT(1)", "COVERAGE_UNITS_RI_TREATY_OUT(2)", "COVERAGE_UNITS_RI_TREATY_OUT(3)",
      "COVERAGE_UNITS_RI_TREATY_OUT(4)", "COVERAGE_UNITS_RI_TREATY_OUT(5)"
    )

    # Initialize columns if they do not exist to avoid errors in calculations
    # for (col in needed_columns) {
    # if (!col %in% names(file)) {
    #  file[, (col) := rep(0, .N)]
    # }
    # }
    Premiums <- rep(0, nrow(file_r))

    for (premium_col in FCFVars$Premiums) {
      if (premium_col %in% names(file)) {
        Premiums <- Premiums + as.numeric(file[[premium_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Premium Column", premium_col, "not found\n")
      }
    }
    # Premiums <- file$RPR_V_PREM_OUT + file$`A_REINS_PREM(1)` + file$"REINS_PREM_TREATY_OUT(2)" + file$"RPR_PREM_OUT_TREATY_OUT(2)" + file$FR_REPAYMENT + file$FR_CLAWBACK + file$`REINS_PREM_TREATY_OUT(3)` + file$`REINS_PREM_TREATY_OUT(5)` + file$`RPR_PREM_OUT_TREATY_OUT(3)` + file$`RPR_PREM_OUT_TREATY_OUT(5)`
    Claims <- rep(0, nrow(file_r))
    # Claims <- (file$`A_REINS_REC(1)` + file$RPR_V_DEATH_REC + file$RPR_V_PHIBEN_REC + file$"REINS_REC_TREATY_OUT(2)" + file$"RPR_DTH_REC_TREATY_OUT(2)" + file$`RPR_DTH_REC_TREATY_OUT(3)` + file$`RPR_DTH_REC_TREATY_OUT(5)` + file$`RPR_PHIBEN_REC_TREATY_OUT(3)`
    # + file$`RPR_PHIBEN_REC_TREATY_OUT(5)` +
    # file$"RPR_PHIBEN_REC_TREATY_OUT(2)" + file$FR_NEW_FINAN + file$`REINS_REC_TREATY_OUT(3)` + file$`REINS_REC_TREATY_OUT(5)`)
    # Calculate 'Claims' using columns specified in FCFVars$Claims
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }

    FinRe <- file$FR_REPAYMENT + file$FR_CLAWBACK - file$FR_NEW_FINAN + file$RPR_V_PREM_OUT
    discountfacStart <- DiscountFactorsStart[2:600]
    discountfacStart <- DiscountFactorsStart[2:600]

    PVFinRe <- sum(FinRe[2:600] * discountfacStart)
    BELsums[i, 12] <- PVFinRe
    FinReIncome <- file$FR_NEW_FINAN + file$RPR_V_PREM_OUT
    FinReIncomeCF <- FinReIncome
    FinReRepayment <- file$FR_REPAYMENT + file$FR_CLAWBACK
    FinReRepaymentCF <- FinReRepayment
    FinReIncome <- sum(discountfacStart * FinReIncome[2:600])
    FinReRepayment <- sum(discountfacStart * FinReRepayment[2:600])
    BELsums[i, 19] <- FinReIncome
    BELsums[i, 20] <- FinReRepayment
    InitExp <- file$INIT_EXP
    CurrInitExp <- sum(InitExp[2:13])

    PVClaims <- sum(discountfacStart * Claims[2:600])
    PVPremiums <- sum(discountfacStart * Premiums[2:600])
    CurrClaims <- sum(Claims[2:13])
    ExpReceivedPremiums <- sum(Premiums[2:13])
    FutRIClaimsAndExp <- sum(Claims[14:600] * DiscountFactorsStart[14:600])
    FutRIPrems <- sum(Premiums[14:600] * DiscountFactorsStart[14:600])
    BELsums[i, 9] <- FutRIClaimsAndExp
    BELsums[i, 10] <- FutRIPrems

    CurrFinReIncome <- sum(FinReIncomeCF[2:13])
    BELsums[i, 23] <- CurrFinReIncome
    CurrFinReRepayment <- sum(FinReRepaymentCF[2:13])
    BELsums[i, 24] <- CurrFinReRepayment
    Claims <- rep(0, nrow(file_r))
    # Claims <- (file$`A_REINS_REC(1)` + file$RPR_V_DEATH_REC + file$RPR_V_PHIBEN_REC + file$"REINS_REC_TREATY_OUT(2)" + file$"RPR_DTH_REC_TREATY_OUT(2)" + file$`RPR_DTH_REC_TREATY_OUT(3)` + file$`RPR_DTH_REC_TREATY_OUT(5)` + file$`RPR_PHIBEN_REC_TREATY_OUT(3)`
    #  + file$`RPR_PHIBEN_REC_TREATY_OUT(5)` +
    # file$"RPR_PHIBEN_REC_TREATY_OUT(2)" + file$`REINS_REC_TREATY_OUT(3)` + file$`REINS_REC_TREATY_OUT(5)`)
    for (claim_col in FCFVars$Claims) {
      if (claim_col %in% names(file)) {
        Claims <- Claims + as.numeric(file[[claim_col]])
      } else {
        cat("\nFile:", files[i], "\n")
        cat("  Warning: Claims Column", claim_col, "not found\n")
      }
    }

    Claims_NoFinre <- Claims
    Premiums_NoFinRe <- Premiums - file$FR_REPAYMENT - file$FR_CLAWBACK
    RiskReinsurance <- Premiums_NoFinRe - Claims_NoFinre

    CurrRiskReinsurancePremiums <- sum(Premiums_NoFinRe[2:13])
    BELsums[i, 26] <- CurrInitExp
    BELsums[i, 25] <- CurrRiskReinsurancePremiums
    PVRiskReins <- sum(RiskReinsurance[2:600] * discountfacStart)
    CurrRecoveries <- sum(Claims_NoFinre[2:13])
    BELsums[i, 8] <- CurrRecoveries
    BELsums[i, 14] <- PVRiskReins

    current_df <- data.frame(
      Month = 1:599,
      Premiums = Premiums[2:600],
      Recoveries = Claims[2:600],
      FinReIncomeCF = FinReIncomeCF[2:600],
      FinReRepayment = FinReRepaymentCF[2:600],
      RiskReinsuranceRecoveries = Claims_NoFinre[2:600],
      RiskReinsurancePremiums = Premiums_NoFinRe[2:600]
    )

    # Store the data frame in the list
    CFResults_List[[i]] <- current_df

    if (RiskAdjustmentApproach == "Percentage") {
      RA <- RiskAdjustmentFactor * (PVClaims)
      # Estimates_FCF = - Premiums[2:600]
      # FCF0 = Estimates_FCF
      BELinf <- sum(Premiums * discountfacStart)
      BELout <- PVClaims
      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Future cashflows projected", Sys.time()))

      # df <- data.frame(FCF0[14:600], discountfacStart, Premiums[14:600],Claims[14:600], discountfacStart)

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future claims at end of period", Sys.time()))


      # PVClaims= sum(discountfacStart*Claims)
      #
      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Discounting applied to future cashflows at start of period", Sys.time()))

      # PVExpenses = sum(discountfacStart*Adm)
      #
      # BELinf =  sum(Estimates_FCF*discountfacStart)
      # BELout =  PVClaims
      BEL <- PVRiskReins + PVFinRe
      CSM <- BEL - RA # prodce CSM and PVFP only


      BELsums[i, 6] <- BEL

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      # Pv_cashflows$Present_Value <- Pv_cashflows$NPV
      # BELsums[i,8] <-  length(unique_policies)

      BELsums[i, 5] <- RA
    } else {
      RA <- file$"RISK_ADJ_RI_TREATY_OUT(2)"
      Estimates_FCF <- -Premiums
      FCF0 <- Estimates_FCF - RA

      # possible problem \/\/
      pv <- data.frame(Present_Value = sum(FCF0 * discountfacStart), EstFCF = sum(Estimates_FCF * discountfacStart) + PVClaims, RA = sum(RA * discountfacStart), Pvpremiums = sum(-Premiums * discountfacStart)) # prodce CSM and PVFP only
      Pv_cashflows <- data.frame(
        PVClaims = PVClaims,
        Present_Value = pv$Present_Value,
        Pvpremiums = pv$Pvpremiums
      )
      # possible problem /\/\

      Pv_cashflows$NPV <- Pv_cashflows$Present_Value + Pv_cashflows$PVClaims

      print(paste("Run", Run_Nr, Portf, "Reinsurance", "New business Loss component checkpoint", Sys.time()))
      # Pv_cashflows$NPV[Pv_cashflows$NPV<0] <- 0
      # PositiveCSM <- subset(Pv_cashflows, NPV != 0)
      Pv_cashflows$Present_Value <- Pv_cashflows$NPV
      BELsums[i, 5] <- pv$RA
      # BELsums[i,8] <-  length(unique_policies)
    }

    # combine all data frames into one if needed
    # ReinsuranceCFS_df <- do.call(rbind, CFResults_List)

    BEL_i <- CSM

    # BEL_i_vals <- c(BEL_i_vals, BEL_i)
    BELsums[i, 1] <- files[i]
    # BELsums[, 1] <- files
    BELsums[i, 2] <- sum(BEL_i)
    CU <- file$"COVERAGE_UNITS_RI_TREATY_OUT(1)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(2)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(3)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(4)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(5)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(6)"


    IA_fac_1 <- DiscountFactorsStart[1]
    IA_fac_12 <- DiscountFactorsStart[12]

    # print(paste("Run",Run_Nr,"Reinsurance CLS IF","at current rates interest accretion",Sys.time()))

    # ################### we don't need interest accretion at current rates
    #
    # Interest_accretion <-  as.numeric(BELsums[i,2])*as.numeric(IA_fac_1 - IA_fac_12)
    # BELsums[i,5] <-  Interest_accretion




    print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "at current rates Calibration of coverage units", Sys.time()))

    CU_IF_RICLS_CYC <- file$"COVERAGE_UNITS_RI_TREATY_OUT(1)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(2)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(3)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(4)" +
      file$"COVERAGE_UNITS_RI_TREATY_OUT(5)" + file$"COVERAGE_UNITS_RI_TREATY_OUT(6)"

    CU_IF_RICLS_CYC[is.na(CU_IF_RICLS_CYC)] <- 0

    BELsums[i, 3] <- sum(CU_IF_RICLS_CYC, na.rm = TRUE) # Sum the vector and assign the sum

    BELsums[i, 7] <- ExpReceivedPremiums

    BELsums[i, 11] <- RiskAdjustmentFactor * CurrClaims

    BELsums[i, 17] <- PVClaims
    BELsums[i, 18] <- PVPremiums

    print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "at current rates discounting coverage Units", Sys.time()))

    # num_parts <- ceiling(length(CU)/1201)
    # part_len <- ceiling(length(CU)/num_parts)
    #
    # data_parts <- split(CU, rep(1:num_parts, each = part_len))
    #
    # result<- lapply(data_parts,function(x) x*discountfacStart)
    #
    # CU <- unlist(result)
    #
    # CU <- colSums(matrix(CU, ncol = 1201, byrow = TRUE))

    CoverageUnits_fac <- sum(CU[2:13]) / sum(CU)



    print(paste("Run", Run_Nr, Portf, "Reinsurance CLS IF", "CSM released to the Income Statement", Sys.time()))

    CSM_release <- as.numeric(BELsums[i, 3]) * as.numeric(BELsums[i, 2])
    BELsums[i, 4] <- CSM_release

    prod_name <- as.character(files[i])
    pn <- substr(prod_name, 1, 7)
  }
  # ReinsuranceCFS_df <- do.call(rbind, CFResults_List)

  outwd <- file.path(inwd, "Output", Run_Nr, Portf, Stress, "IF/Reinsurance")
  if (!dir.exists(outwd)) {
    dir.create(outwd, recursive = TRUE)
  }
  setwd(outwd)

  combined_df <- bind_rows(CFResults_List)

  # Summarise the combined data frame by Month
  ReinsuranceCFS_df <- combined_df %>%
    group_by(Month) %>%
    summarise(
      Total_Premiums = sum(Premiums, na.rm = TRUE),
      Total_Recoveries = sum(Recoveries, na.rm = TRUE),
      Total_FinReIncomeCF = sum(FinReIncomeCF, na.rm = TRUE),
      Total_FinReRepayment = sum(FinReRepayment, na.rm = TRUE),
      Total_RiskReinsuranceRecoveries = sum(RiskReinsuranceRecoveries, na.rm = TRUE),
      Total_RiskReinsurancePremiums = sum(RiskReinsurancePremiums, na.rm = TRUE)
    )

  # ReinsuranceCFS_df <- aggregate(. ~ Month, data = ReinsuranceCFS_df, sum)

  CurrFinReIncome <- as.numeric(BELsums[, 23])
  CurrRiskRIPrems <- as.numeric(BELsums[, 25])
  CurrInitExp <- as.numeric(BELsums[, 26])
  TotCurrInitExp <- sum(CurrInitExp)
  TotCurrRiskRIPrems <- sum(CurrRiskRIPrems)
  TotCurrFinReIncome <- sum(CurrFinReIncome)
  CurrFinReRepayment <- as.numeric(BELsums[, 24])
  TotCurrFinReRepayment <- sum(CurrFinReRepayment)
  PVClaimsAll <- as.numeric(BELsums[, 17])
  TotPVClaims <- sum(PVClaimsAll)
  FinReIncome <- as.numeric(BELsums[, 19])
  PremiumCFS <- as.numeric(CFResults[1, ])
  TotPremCFS <- sum(PremiumCFS)
  ClaimCFs <- as.numeric(CFResults[2, ])
  TotClaimCFs <- sum(ClaimCFs)
  FinReIncomeCFs <- as.numeric(CFResults[3, ])
  TotFinReIncomeCF <- sum(FinReIncomeCFs)
  FinReRepaymentCFs <- as.numeric(CFResults[4, ])
  TotFinReRepaymentCF <- sum(FinReRepaymentCFs)
  TotFinReIncome <- sum(FinReIncome)
  FinReRepayment <- as.numeric(BELsums[, 20])
  TotFinReRepayment <- sum(FinReRepayment)
  PVPremiums <- as.numeric(BELsums[, 18])
  TotPVPrem <- sum(PVPremiums)
  SumsofBELS_IF_RICLS_CYC <- as.numeric(BELsums[, 2])
  ClaimsCurr <- as.numeric(BELsums[, 8])
  RiskRi <- as.numeric(BELsums[, 14])
  TotRiskRi <- sum(RiskRi)
  TotPVClaimsCurr <- sum(ClaimsCurr)
  CurrRA <- as.numeric(BELsums[, 11])
  PVFinRe <- as.numeric(BELsums[, 12])
  TotFinRe <- sum(PVFinRe)
  TotCurrRA <- sum(CurrRA)
  PVFP_Curr_IF_RI <- as.numeric(BELsums[, 7])
  TotCurrPVFP_IF_RI <- sum(PVFP_Curr_IF_RI)
  FutRIPrems <- as.numeric(BELsums[, 10])
  TotFutRIPrems <- sum(FutRIPrems)
  FutRIClaims <- as.numeric(BELsums[, 9])
  SubtotalofBELS_IF_RICLS_CYC <- sum(SumsofBELS_IF_RICLS_CYC)
  IFRS17_group_IF_RICLS_CYC <- c(Item_names, "Total")
  CU_IF_RICLS_CYC <- as.numeric(BELsums[, 3])
  CSMrelease_IF_RICLS_CYC <- as.numeric(BELsums[, 4])
  BELs_IF_RICLS_CYC <- as.numeric(BELsums[, 6])
  TotFCF_IF_RICLS_CYC <- sum(BELs_IF_RICLS_CYC)
  RiskAdj_IF_RICLS_CYC <- as.numeric(BELsums[, 5])
  TotRiskAdj_IF_RICLS_CYC <- sum(RiskAdj_IF_RICLS_CYC)
  TotalCSMrelease_IF_RICLS_CYC <- sum(CSMrelease_IF_RICLS_CYC)
  avgCU_IF_RICLS_CYC <- as.numeric(mean(CU_IF_RICLS_CYC))

  # ReinsuranceCFS_df = data.frame( Premiums = c(PremiumCFS, TotPremCFS), Claims = c(ClaimCFs, TotClaimCFs), FinReIncomeCFs = c(FinReIncomeCFs, TotFinReIncomeCF), FinReRepaymentCFs = c(FinReRepaymentCFs, TotFinReRepaymentCF))
  SumofBELs_df_IF_RICLS_CYC <- data.frame(IFRS17_group_IF_RICLS_CYC,
    CoverageUnits = c(CU_IF_RICLS_CYC, avgCU_IF_RICLS_CYC), CurrRA = c(CurrRA, TotCurrRA), CurrInitExp = c(CurrInitExp, TotCurrInitExp),
    PVFCurrPrems = c(PVFP_Curr_IF_RI, TotCurrPVFP_IF_RI), FutRIPrems = c(FutRIPrems, TotFutRIPrems), CurrRecoveries = c(ClaimsCurr, TotPVClaimsCurr),
    FutRIClaims = c(FutRIClaims, TotFutRIClaims), CSM_LRecC_released = c(CSMrelease_IF_RICLS_CYC, TotalCSMrelease_IF_RICLS_CYC),
    RA = c(RiskAdj_IF_RICLS_CYC, TotRiskAdj_IF_RICLS_CYC),
    BEL = c(BELs_IF_RICLS_CYC, TotFCF_IF_RICLS_CYC), PVFinRe = c(PVFinRe, TotFinRe), TotFinReIncome = c(FinReIncome, TotFinReIncome),
    TotFinReRepayment = c(FinReRepayment, TotFinReRepayment), PVRiskRI = c(RiskRi, TotRiskRi), TotPVClaims = c(PVClaimsAll, TotPVClaims),
    CurrFinReIncome = c(CurrFinReIncome, TotCurrFinReIncome), CurrFinReRepayment = c(CurrFinReRepayment, TotFinReRepayment),
    PVPremiums = c(PVPremiums, TotPVPrem), CurrRiskRIPrems = c(CurrRiskRIPrems, TotCurrRiskRIPrems)
  )
  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Printing Closing IF valuation results to CSV file at current rates", Sys.time()))
  write.csv(SumofBELs_df_IF_RICLS_CYC, paste(Run_Nr, Portf, "Reinsurance IFCLS_CYC BEL per IFRS17_group.csv"), append = FALSE, row.names = FALSE, sep = ",")
  # Construct the path dynamically
  run_dir <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS/IF/Reinsurance/IF Reinsurance CFs")

  # Create the directory if it doesn't exist
  if (!dir.exists(run_dir)) {
    dir.create(run_dir, recursive = TRUE)
  }

  # Set the working directory
  setwd(run_dir)
  write.csv(ReinsuranceCFS_df, paste(Run_Nr, Portf, "IF Reinsurance CFs.csv"), append = FALSE, row.names = FALSE, sep = ",")

  results_IF_RICLS_CYC <- list(
    SumofBELs_df_IF_RICLS_CYC = SumofBELs_df_IF_RICLS_CYC,
    SumsofBELS_IF_RICLS_CYC = as.numeric(BELsums[, 2]),
    SubtotalofBELS_IF_RICLS_CYC = sum(SumsofBELS_IF_RICLS_CYC),
    IFRS17_group_IF_RICLS_CYC = c(Item_names, "Total"),
    CU_IF_RICLS_CYC = as.numeric(BELsums[, 3]),
    CSMrelease_IF_RICLS_CYC = as.numeric(BELsums[, 4]),
    BELs_IF_RICLS_CYC = as.numeric(BELsums[, 6]),
    TotFCF_IF_RICLS_CYC = sum(BELs_IF_RICLS_CYC),
    RiskAdj_IF_RICLS_CYC = as.numeric(BELsums[, 5]),
    TotRiskAdj_IF_RICLS_CYC = sum(RiskAdj_IF_RICLS_CYC),
    TotalCSMrelease_IF_RICLS_CYC = sum(CSMrelease_IF_RICLS_CYC),
    avgCU_IF_RICLS_CYC = as.numeric(mean(CU_IF_RICLS_CYC))
  )

  ReinsuranceResults <- list(Reins_NB = results_NB_RI, ReinIFCLS_CYC = results_IF_RICLS_CYC, ReinsIFCLS_LIYC = results_IF_RICLS_LIYC)
  print(paste("Run", Run_Nr, Portf, "List dn=one", Sys.time()))
  print(paste("Run", Run_Nr, Portf, "List dn=one2", Sys.time()))
  return(ReinsuranceResults)
  print(paste("Run", Run_Nr, Portf, "Reinsurance", "Closing Inforce at Current rates CSM done", Sys.time()))
}
GrossInsuranceResults <- GrossCSM(PrevRun_Nr, NBRun_Nr, Run_Nr)

ReinsuranceResults <- ReinsCSM(PrevRun_Nr, NBRun_Nr, Run_Nr)

allResultsA <- list(GrossInsuranceResults = GrossInsuranceResults, ReinsuranceResults = ReinsuranceResults)


setwd(paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress))
output_file <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/Master_Results.xlsx")
if (file.exists(output_file)) {
  file.remove(output_file)
}
new_wb <- createWorkbook()
# Save the workbook to the output file
saveWorkbook(new_wb, file.path(getwd(), "Master_Results.xlsx"), overwrite = FALSE)
library(data.table)
library(openxlsx)

combine_and_write_to_excel <- function(main_folder) {
  # Create a new workbook
  wb <- createWorkbook()

  # Set the paths to the folders
  subfolders <- c("NB", "IF", "Locked/IF")
  folders <- c("Insurance", "Reinsurance")

  for (subfolder in subfolders) {
    subfolder_path <- file.path(main_folder, subfolder)

    for (folder in folders) {
      folder_path <- file.path(subfolder_path, folder)

      # Check if the folder exists
      if (!dir.exists(folder_path)) {
        cat("Folder does not exist:", folder_path, "\n")
        next
      }

      # List all files (including those in subfolders) in the current folder
      files <- list.files(folder_path, full.names = TRUE, recursive = TRUE)

      # Check if there are any files to process
      if (length(files) == 0) {
        cat("No files found in folder:", folder_path, "\n")
        next
      }

      # Create an empty data.table to store the combined data
      combined_data <- data.table()

      # Loop through each file and read it into the combined_data data.table
      for (file in files) {
        if (file.exists(file)) {
          tryCatch(
            {
              cat("Reading file:", file, "\n") # Diagnostic message
              current_data <- fread(file, encoding = "unknown")
              combined_data <- rbindlist(list(combined_data, current_data), fill = TRUE)
            },
            error = function(e) {
              cat("Error reading file:", file, "\n")
            }
          )
        } else {
          cat("File does not exist:", file, "\n")
        }
      }

      # Replace "/" with "_" in subfolder names for sheet names
      clean_subfolder <- gsub("/", "_", subfolder)

      # Add a worksheet for the current combination to the workbook
      sheet_name <- paste0(clean_subfolder, "_", folder)
      cat("Adding worksheet:", sheet_name, "\n") # Diagnostic message
      addWorksheet(wb, sheetName = sheet_name)

      # Print the structure of combined_data before writing
      cat("Structure of combined_data for sheet", sheet_name, ":\n")
      print(str(combined_data))

      # Check if combined_data is empty
      if (nrow(combined_data) == 0) {
        cat("No data to write for sheet:", sheet_name, "\n")
      } else {
        # Write the combined data to the worksheet
        writeDataTable(wb, sheet = sheet_name, x = combined_data, startCol = 1, startRow = 1, colNames = TRUE)
      }
    }
  }

  # Construct the output directory and file name
  output_dir <- file.path("Output")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  output_file <- file.path(output_dir, paste0("Combined_Output_", Run_Nr, "_", Portf, "_", Stress, ".xlsx"))

  # Remove existing output file if it exists
  if (file.exists(output_file)) {
    file.remove(output_file)
  }

  # Save the workbook with the constructed file name
  cat("Saving workbook to:", output_file, "\n") # Diagnostic message
  saveWorkbook(wb, output_file, overwrite = TRUE)

  # Print a message indicating success
  cat("Data combined and saved successfully.\n")
}
# Set the paths to the main folder and the output file on the desktop
main_folder <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress)
# Combine and write data for Insurance and Reinsurance folders in both NB, IF, and Locked/IF
combine_and_write_to_excel(main_folder)

################################################################ Combine output cashflows ####################################################

# Load necessary libraries
library(data.table)
library(openxlsx)
library(here)

# Set the working directory and output file
setwd(paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS"))
output_file <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/Master_Results.xlsx")

# If the output file exists, remove it
if (file.exists(output_file)) {
  file.remove(output_file)
}

# Function to combine and write data to an Excel file
combine_and_write_to_excel <- function(main_folder, output_file, Run_Nr, Portf) {
  # Create a new workbook
  wb <- createWorkbook()

  # Set the paths to the folders
  subfolders <- c("NB", "IF")
  folders <- c("Insurance", "Reinsurance")

  for (subfolder in subfolders) {
    subfolder_path <- file.path(main_folder, subfolder)

    for (folder in folders) {
      # List all files (including those in subfolders) in the current folder
      # Filter files that contain both Run_Nr and Portf in their names
      files <- list.files(file.path(subfolder_path, folder), full.names = TRUE, recursive = TRUE)
      files <- files[grepl(Run_Nr, files) & grepl(Portf, files)]

      # Create an empty data.table to store the combined data
      combined_data <- data.table()

      # Loop through each file and read it into the combined_data data.table
      for (file in files) {
        tryCatch(
          {
            current_data <- fread(file, encoding = "unknown")
            combined_data <- rbindlist(list(combined_data, current_data))
          },
          error = function(e) {
            cat("Error reading file:", file, "\n")
          }
        )
      }

      # Replace "/" with "_" in subfolder names for sheet names
      clean_subfolder <- gsub("/", "_", subfolder)

      # Add a worksheet for the current combination to the workbook
      sheet_name <- paste0("CFS_", clean_subfolder, "_", folder)
      addWorksheet(wb, sheetName = sheet_name)

      # Write the combined data to the worksheet
      writeDataTable(wb, sheet = sheet_name, x = combined_data, startCol = 1, startRow = 1, colNames = TRUE)
    }
  }

  # Construct the file name dynamically using Run_Nr and Portf
  file_name <- paste0("Combined_Output_CFS_", Run_Nr, "_", Portf, "_", Stress, ".xlsx")

  # Save the workbook with the constructed file name in the Output/CFS folder
  saveWorkbook(wb, file.path(main_folder, file_name), overwrite = TRUE)

  # Print a message indicating success
  cat("Data combined and saved successfully.\n")
}

# Call the function with the appropriate arguments
combine_and_write_to_excel(paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress, "/CFS"), output_file, Run_Nr, Portf)


# output_file <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/Combined_Output_CFS.xlsx"
# # Combine and write data for Insurance and Reinsurance folders in both NB, IF, and Locked/IF
# combine_and_write_to_excel(main_folder, output_file)
##########################################  Merge CFS with COMBINED_OUTPUT  #############################
print(paste0("Merging CFS to Combined Output"))

wd <- paste0(here("Output"), "/", Run_Nr, "/", Portf, "/", Stress)
# Define file paths
dest_name <- paste0("Combined_Output_", Run_Nr, "_", Portf, "_", Stress, ".xlsx")
sour_name <- paste0("Combined_Output_CFS_", Run_Nr, "_", Portf, "_", Stress, ".xlsx")
dest_path <- file.path(wd, "Output", dest_name)
sour_path <- file.path(wd, "CFS", sour_name)
source_file <- sour_path
destination_file <- dest_path

# Load source file
source_wb <- loadWorkbook(source_file)

# Load destination file
destination_wb <- loadWorkbook(destination_file)

# Get sheet names from source file
source_sheet_names <- names(source_wb)

# Loop through each sheet in the source file
for (sheet_name in source_sheet_names) {
  # Read data from source sheet
  data <- read.xlsx(source_file, sheet = sheet_name)

  # Check if the sheet already exists in the destination workbook
  if (sheet_name %in% names(destination_wb)) {
    # If the sheet exists, remove it
    removeWorksheet(destination_wb, sheet = sheet_name)
    # Add it back as a new sheet
    addWorksheet(destination_wb, sheetName = sheet_name)
  } else {
    # If the sheet does not exist, just add it
    addWorksheet(destination_wb, sheetName = sheet_name)
  }

  # Write data to the sheet in destination file
  writeDataTable(destination_wb, sheet = sheet_name, x = data, startCol = 1, startRow = 1, colNames = TRUE, rowNames = FALSE)
}

# Save the changes to the destination file
saveWorkbook(destination_wb, destination_file, overwrite = TRUE)


print(paste0("Merge Completed"))

##########################################################################################################
cat("now moving to subledgers and postings\n")

# Specify the path to your Excel file
excel_path <- here("Reports/Templates/IFRS17_Master_Results.xlsx")
ifrs_output <- file.path(here("Output"), Run_Nr, Portf, Stress, "Reports/IFRS17_Master_Results.xlsx")
# Load the workbook
wb <- loadWorkbook(excel_path)


if (Run_Nr == Run_Nr) {
  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrPremCFS[4])),
    startCol = 4,
    startRow = 17
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LC_released_reversal[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LC_released_reversal[3],
      0
    )),
    startCol = 6,
    startRow = 18
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrClaimsExpCFS[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrClaimsExpCFS[3]
    )),
    startCol = 4,
    startRow = 21
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrAcqCFS[4])),
    startCol = 4,
    startRow = 20
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$BEL[2], 0)),
    startCol = 7,
    startRow = 26
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$RA[2], 0)),
    startCol = 8,
    startRow = 26
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$RA[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$RA[3],
      0
    )),
    startCol = 5,
    startRow = 30
  )
  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$BEL[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$BEL[3],
      0
    )),
    startCol = 4,
    startRow = 30
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      -(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[1] +
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[3] -
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpPremiumsPV[1] -
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpPremiumsPV[3])
      + (
          GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[1] +
            GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[3] -
            GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[1] -
            GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[3]
        ),
      0
    )),
    startCol = 4,
    startRow = 31
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      RiskAdjustmentFactor * (
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[1] +
          GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[3] -
          GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[1] -
          GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[3]
      ),
      0
    )),
    startCol = 5,
    startRow = 31
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$BEL[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$BEL[3],
      0
    )),
    startCol = 4,
    startRow = 30
  )
  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[2] -
        (GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpPremiumsPV[2] +
          GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[2] -
          GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[2]),
      0
    )),
    startCol = 7,
    startRow = 32
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      (GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[2] -
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$FutExpClaimsExp[2]) * RiskAdjustmentFactor,
      0
    )),
    startCol = 8,
    startRow = 32
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$InterestAccBEL[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$InterestAccBEL[3],
      0
    )),
    startCol = 4,
    startRow = 41
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$Interest_accRA[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$Interest_accRA[3],
      0
    )),
    startCol = 5,
    startRow = 41
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$Interest_Accreted_NB[1] +
        GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$Interest_Accreted_NB[3],
      0
    )),
    startCol = 6,
    startRow = 41
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$InterestAccBEL[2],
      0
    )),
    startCol = 7,
    startRow = 41
  )

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$Interest_accRA[2],
      0
    )),
    startCol = 8,
    startRow = 41
  )

  print(paste0(("Printing of impact of changes in interest rates on BEL - Exc LC"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      -(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[1] +
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[3] +
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[1] +
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutExpClaimsExp[3])
      + (
          GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpClaimsExp[1] +
            GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpClaimsExp[3] +
            GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpPremiums[1] +
            GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpPremiums[3]
        ),
      0
    )),
    startCol = 4,
    startRow = 42
  )
  print(paste0(("Printing of impact of changes in interest rates on BEL - LC"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      -(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$FutPrems[2] +
        GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpClaimsExp[2])
      + (
          GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpClaimsExp[2] +
            GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$FutExpPremiums[2]
        ),
      0
    )),
    startCol = 7,
    startRow = 42
  )

  print(paste0(("Printing of impact of changes in interest rates on RA - Exc LC"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      -(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$RA[1] +
        GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$RA[3])
      + (
          GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$RA[1] +
            GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$RA[3]
        ),
      0
    )),
    startCol = 5,
    startRow = 42
  )


  print(paste0(("Printing of impact of changes in interest rates on RA - LC"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(round(
      -(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC$RA[2])
      + (
          GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC$RA[2]
        ),
      0
    )),
    startCol = 8,
    startRow = 42
  )

  print(paste0(("Printing of RA release on Insurance"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(
      round(
        -GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrRA[4]
      ),
      0
    ),
    startCol = 5,
    startRow = 19
  )
} else {
  print(paste0(("Printing of RA release on Insurance - Sub Calc"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc1",
    x = as.numeric(
      round(
        -GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CurrRA[4]
      ),
      0
    ),
    startCol = 5,
    startRow = 19
  )
}
# aveWorkbook(wb, excel_path, overwrite = TRUE)
#
#
# # Create a style with a dark grey background
# darkGreyStyle <- createStyle(bgFill = "#D3D3D3") # Dark grey color
#
# # Apply the style to column K and row 59
# # Assuming that you are working on the first sheet
# addStyle(wb, sheet = "IFRS17_Disc1", style = darkGreyStyle, rows = 59:300, cols = 1:300, gridExpand = TRUE) # Adjust the 100 to the max number of your columns
# addStyle(wb, sheet = "IFRS17_Disc1", style = darkGreyStyle, rows = 1:348, cols = 11:300, gridExpand = TRUE) # Excel's max row number as of now is 1048576
#
# Save the workbook
# saveWorkbook(wb, excel_path, overwrite = TRUE)
#
# # Path to the source and destination workbooks
# source_file <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/Master_Results.xlsx"
# dest_file <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/Combined_Output.xlsx"
#
# # Load the destination workbook
# dest_wb <- loadWorkbook(dest_file)
#
# # Get sheet names from the source workbook
# sheet_names <- getSheetNames(source_file)
#
# # Copy sheets from the source workbook to the destination workbook, excluding "IFRS17_Disc1"
# for(sheet in sheet_names) {
#   if(sheet != "IFRS17_Disc1") {
#     # Read data from the source sheet
#     data <- read.xlsx(source_file, sheet = sheet)
#
#     # Check if sheet already exists in the destination workbook
#     if(!(sheet %in% getSheetNames(dest_file))) {
#       # If not, add a new sheet to the destination workbook and write data
#       addWorksheet(dest_wb, sheet)
#       writeData(dest_wb, sheet = sheet, data)
#     } else {
#       # Optional: Handle case where sheet already exists in the destination workbook, e.g., overwrite, skip, or append
#       # For this example, we'll simply overwrite the data in the existing sheet
#       writeData(dest_wb, sheet = sheet, data, overwrite = TRUE)
#     }
#   }
# }

############################################################ Rolling forward Reinsurance ###########################

if (Run_Nr == Run_Nr) {
  # Premium experience variances
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$PVFCurrPrems[4])),
    startCol = 4,
    startRow = 17
  )
  # Expected recovery of insurance service expenses
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$CurrClaims[4])),
    startCol = 4,
    startRow = 20
  )

  # Net cost or gain recognised in profit or loss
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$CSM_LRecC_released[4])),
    startCol = 6,
    startRow = 18
  )

  # Contracts initially recognised - BEL
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$BEL[4])),
    startCol = 4,
    startRow = 29
  )
  # Contracts initially recognised - RA
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$RA[4])),
    startCol = 5,
    startRow = 29
  )
  # Contracts initially recognised - CSM
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$CSM_LCpergroup[4])),
    startCol = 6,
    startRow = 29
  )

  # Loss component recovery - BEL
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LCpergroup[2])),
    startCol = 4,
    startRow = 24
  )

  # Loss component recovery - CSM
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LCpergroup[2])),
    startCol = 6,
    startRow = 24
  )

  # Loss component recovery - Loss component
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LCpergroup[2])),
    startCol = 7,
    startRow = 24
  )

  # Reversal of Loss component recovery - BEL
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LC_released_reversal[2])),
    startCol = 4,
    startRow = 25
  )

  # Reversal of Loss component recovery - CSM
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LC_released_reversal[2])),
    startCol = 6,
    startRow = 25
  )

  # Reversal of Loss component recovery - Loss component
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = -as.numeric(round(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins$CSM_LC_released_reversal[2])),
    startCol = 7,
    startRow = 25
  )


  # Changes in Estimates that adjust the Reinsurance CSM - BEL

  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      -(ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$FutRIPrems[4] -
        ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$FutRIPrems[4])
      + (
          ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$FutRIClaims[4] -
            ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$FutRIClaims[4]
        ),
      0
    )),
    startCol = 4,
    startRow = 30
  )
  # Changes in Estimates that adjust the Reinsurance CSM - RA
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      -RiskAdjustmentFactor * (ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$FutRIClaims[4] -
        ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$FutRIClaims[4]
      ),
      0
    )),
    startCol = 5,
    startRow = 30
  )
  # Interest accretion Reinsurance - CSM
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$Interest_Accreted_NB[4],
      0
    )),
    startCol = 6,
    startRow = 38
  )
  # Interest accretion Reinsurance - RA
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$Interest_accRA[4],
      0
    )),
    startCol = 5,
    startRow = 38
  )
  # Interest accretion Reinsurance - RA
  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$Interest_accBEL[4],
      0
    )),
    startCol = 4,
    startRow = 38
  )

  # Printing of impact of changes in interest rates on BEL - Exc LC

  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      -(ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$FutRIPrems[4] +
        ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$FutRIClaims[4])
      + (
          ReinsuranceResults$ReinIFCLS_CYC$SumofBELs_df_IF_RICLS_CYC$FutRIPrems[4] +
            ReinsuranceResults$ReinIFCLS_CYC$SumofBELs_df_IF_RICLS_CYC$FutRIClaims[4]
        ),
      0
    )),
    startCol = 4,
    startRow = 39
  )


  print(paste0(("Printing of impact of changes in interest rates on RA - Exc LC"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(round(
      -(ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC$RA[4])
      + (ReinsuranceResults$ReinIFCLS_CYC$SumofBELs_df_IF_RICLS_CYC$RA[4]
        ),
      0
    )),
    startCol = 5,
    startRow = 39
  )

  print(paste0(("Printing of RA release on Reinsurance"), Sys.time()))

  writeData(wb,
    sheet = "IFRS17_Disc2",
    x = as.numeric(
      round(
        -ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI$CurrRA[4]
      ),
      0
    ),
    startCol = 5,
    startRow = 19
  )
} else {
  0
}

# Save the updated destination workbook
saveWorkbook(wb, ifrs_output, overwrite = TRUE)

################################################################## SUBLEDGER ######################################

# Load necessary libraries
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)
if (!require("openxlsx")) install.packages("openxlsx", dependencies = TRUE)
if (!require("here")) install.packages("here", dependencies = TRUE)

library(readxl)
library(dplyr)
library(openxlsx)
library(here)

# Define the file path
file_path <- ifrs_output

# Load specific ranges from the sheets
df_sheet1 <- read_excel(file_path, sheet = "IFRS17_Disc1", range = "C10:J53")
df_sheet3 <- read_excel(file_path, sheet = "IFRS17_Disc2", range = "C10:I45")
df_sheet2 <- read_excel(file_path, sheet = "Subledger")

# Print column names to verify
print(colnames(df_sheet1))
print(colnames(df_sheet3))

# Clean column names
df_sheet1 <- df_sheet1 %>%
  rename_with(~ gsub(" ", "", .)) %>%
  mutate(across(everything(), as.character))
df_sheet3 <- df_sheet3 %>%
  rename_with(~ gsub(" ", "", .)) %>%
  mutate(across(everything(), as.character))
df_sheet2 <- df_sheet2 %>% mutate(across(c(`DR Account Code`, `CR Account Code`), as.character))

# Print cleaned column names
print(colnames(df_sheet1))
print(colnames(df_sheet3))

# Function to get the intersection value as numeric
get_intersection_value <- function(dr_code, cr_code, df, code_column) {
  # Print debugging information
  print(paste("DR Code:", dr_code))
  print(paste("CR Code:", cr_code))

  # Check if the column exists
  if (dr_code %in% colnames(df)) {
    # Find the rows with the CR code
    df_filtered <- df %>% filter(.data[[code_column]] == cr_code)

    # Print the filtered data frame for debugging
    print(df_filtered)

    # Return the sum of all matching values, or 0 if none
    if (nrow(df_filtered) > 0) {
      return(sum(as.numeric(df_filtered[[dr_code]]), na.rm = TRUE))
    } else {
      return(0)
    }
  } else {
    return(0)
  }
}

# Calculate the intersection values and update the Amount column as numeric
df_sheet2$Amount <- mapply(function(dr_code, cr_code) {
  amount1 <- get_intersection_value(dr_code, cr_code, df_sheet1, "Accountcode")
  amount2 <- get_intersection_value(dr_code, cr_code, df_sheet3, "AccountCode")

  # Sum amounts if both are not 0
  total_amount <- amount1 + amount2
  if (total_amount > 0) {
    return(total_amount)
  } else {
    return(0)
  }
}, df_sheet2$`DR Account Code`, df_sheet2$`CR Account Code`)

# Load the existing workbook and update the Subledger sheet
wb <- loadWorkbook(file_path)
writeData(wb, sheet = "Subledger", df_sheet2, colNames = TRUE)
saveWorkbook(wb, file = file_path, overwrite = TRUE)

cat("Subledger has been successfully updated in the Excel file.\n")

#####################################################################  TRIAL BALANCE  #########################################################

# Load necessary libraries
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)
if (!require("openxlsx")) install.packages("openxlsx", dependencies = TRUE)

library(readxl)
library(dplyr)
library(openxlsx)
library(here)

# Define the file path
file_path <- ifrs_output

# Read the Excel file
subledger <- read_excel(file_path, sheet = "Subledger")
trial_balance <- read_excel(file_path, sheet = "TrialBalance")

# Print the column names to verify they match what we expect
print("Column names in subledger:")
print(colnames(subledger))
print("Column names in trial_balance:")
print(colnames(trial_balance))

# Replace spaces with underscores in column names
colnames(subledger) <- gsub(" ", "_", colnames(subledger))
colnames(trial_balance) <- gsub(" ", "_", colnames(trial_balance))

# Verify column names after replacement
print("Column names in subledger after replacement:")
print(colnames(subledger))
print("Column names in trial_balance after replacement:")
print(colnames(trial_balance))

# Sum amounts in subledger by Group_Code and CR_Account_Code
subledger_summary <- subledger %>%
  group_by(Group_Code, CR_Account_Code) %>%
  summarise(Total_Amount = sum(Amount, na.rm = TRUE))

# Print subledger_summary to verify
print("Subledger summary:")
print(subledger_summary)

# Merge subledger summary with trial balance
merged_data <- merge(trial_balance, subledger_summary,
  by.x = c("Group_Code", "Account_Code"),
  by.y = c("Group_Code", "CR_Account_Code"),
  all.x = TRUE
)

# Update Amount in trial balance with the corresponding Total_Amount from subledger summary
merged_data$Amount <- ifelse(is.na(merged_data$Total_Amount), merged_data$Amount, merged_data$Total_Amount)

# Set Amount to zero where Amount is negative but categorized as Liability
merged_data$Amount[merged_data$Amount < 0 & merged_data$Asset_Liability == "Liability"] <- 0

# Set Amount to zero where Amount is positive but categorized as Asset
merged_data$Amount[merged_data$Amount > 0 & merged_data$Asset_Liability == "Asset"] <- 0

# Remove Total_Amount column if no longer needed
merged_data <- merged_data[, !names(merged_data) %in% "Total_Amount"]

# Write the updated TrialBalance sheet back to the Excel file
wb <- loadWorkbook(file_path)
writeData(wb, sheet = "TrialBalance", x = merged_data)
saveWorkbook(wb, file_path, overwrite = TRUE)

cat("TrialBalance has been successfully updated in the Excel file.\n")
############################################################### PAA TOOL #########################################
# library(openxlsx2)
# library(readxl)

# # Define file paths
# file_path <- ifrs_output
# paa_path <- here("Output/Reports/Templates/PAA Tool.xlsm")
# paa_output <- file.path(here("Output"), Run_Nr, Portf, Stress, "Reports/PAA Tool.xlsm")

# # Read data
# ifrs17_disc1 <- read_xlsx(file_path, sheet = 'IFRS17_Disc1')
# ifrs17_disc2 <- read_xlsx(file_path, sheet = 'IFRS17_Disc2')

# # Load the existing workbook
# wb <- wb_load(paa_path)

# # Remove existing sheets if they exist
# if ("IFRS17_Disc1" %in% wb$sheet_names) {
#   wb_remove_sheet(wb, "IFRS17_Disc1")
# }
# if ("IFRS17_Disc2" %in% wb$sheet_names) {
#   wb_remove_sheet(wb, "IFRS17_Disc2")
# }

# # Add new sheets
# wb_add_sheet(wb, "IFRS17_Disc1")
# wb_add_sheet(wb, "IFRS17_Disc2")

# # Write data to new sheets
# wb_add_data(wb, sheet = "IFRS17_Disc1", x = ifrs17_disc1, start_col = 1)
# wb_add_data(wb, sheet = "IFRS17_Disc2", x = ifrs17_disc2, start_col = 1)

# # Save the updated workbook
# wb_save(wb, paa_output, overwrite = TRUE)

# print(paste0("Preparation of results into Master DB ", Sys.time()))
#
# # Define file paths
# source_excel <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/Combined_Output.xlsx"
# master_excel <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/IFRS17_Master_Results.xlsx"
#
# # Load the source Excel workbook
# source_wb <- loadWorkbook(source_excel)
#
# # Load the master Excel workbook
# master_wb <- loadWorkbook(master_excel)
#
# # # Function to write data to master workbook and apply numeric style
# write_and_style <- function(data, sheet_name) {
#   # Adjust column names and remove the first row
#   names(data) <- as.character(unlist(data[1, ]))
#   data <- data[-1, ]
#
#   # Convert to data frame (in case it's not already)
#   data <- as.data.frame(data)
#
#   # Write data from dataframe to the newly added sheet in the master Excel workbook
#   writeData(master_wb, sheet = sheet_name, x = data, startRow = 2)  # Start from the second row
#   # Define a style for numeric cells
#   numStyle <- createStyle(numFmt = "#,##0.00")  # Adjust the number format as needed
#   # Apply the style to the relevant range of cells
#   addStyle(master_wb, sheet = sheet_name, style = numStyle, rows = 2:nrow(data) + 1, cols = 2, gridExpand = TRUE)
# }
#
#
#
# # Write and style data for NB_Insurance
# x <- as.data.frame(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins)
# write_and_style(x, "NB_Insurance")
#
#  # Write and style data for NB_Reinsurance
# y <- as.data.frame(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI)
# write_and_style(y, "NB_Reinsurance")
#
# # Write and style data for IF_Insurance
# z <- as.data.frame(GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC)
# write_and_style(z, "IF_Insurance")
#
# # Write and style data for Locked_IF_Insurance
# a <- as.data.frame(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC)
# write_and_style(a, "Locked_IF_Insurance")
#
# # Write and style data for IF_Reinsurance
# b <- as.data.frame(ReinsuranceResults$ReinIFCLS_CYC$SumofBELs_df_IF_RICLS_CYC)
# write_and_style(b, "IF_Reinsurance")
#
# # Write and style data for Locked_IF_Reinsurance
# c <- as.data.frame(ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC)
# write_and_style(c, "Locked_IF_Reinsurance")
#
# # Save the master Excel workbook
# saveWorkbook(master_wb, master_excel, overwrite = TRUE)
# Construct the file name dynamically using Run_Nr

# print(paste0(("Preparation of results into Master DB"), Sys.time()))
# # Define file paths
# # source_excel <- "C:/Users/Nkalolang/Dropbox/PC/Documents/GitHub/PAM1000/Output/Combined_Output.xlsx"
# file_name <- paste0("Combined_Output_", Run_Nr, ".xlsx")
# wd <- here("Output")
# source_excel <- file.path(wd, file_name)
# master_excel <- here("Output/IFRS17_Master_Results.xlsx")

# # Load the source Excel workbook
# source_wb <- loadWorkbook(source_excel)

# # Load the master Excel workbook
# master_wb <- loadWorkbook(master_excel)

# # Get sheet names from source Excel workbook
# source_sheet_names <- excel_sheets(source_excel)
# # library(openxlsx)
# x <- as.data.frame(GrossInsuranceResults$Ins_NB$SumofBELs_df_NB_Ins)
# names(x) <- as.character(unlist(x[1, ]))
# x <- x[-1, ]
# x <- as.data.frame(x)
# data_df <- readWorkbook(master_wb, sheet = "NB_Insurance")
# last_row <- nrow(data_df) + 1
# # Before writing the matrix to the Excel sheet, replace NA values with empty strings
# # writeData(master_wb, sheet = "NB_Reinsurance", x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# writeData(master_wb, sheet = "NB_Insurance", x = matrix("", ncol = ncol(data_df), nrow = last_row - 1), startRow = 2, startCol = 1)
# writeData(master_wb, sheet = "NB_Insurance", x = x, startRow = 2)
# # numStyle <- createStyle(numFmt = "#,##0.00")
# # addStyle(master_wb, sheet = "NB_Insurance", style = numStyle, rows = 2:(nrow(x) + 1), cols = 2, gridExpand = TRUE)
# # # Save the master Excel workbook
# # saveWorkbook(master_wb, master_excel, overwrite = TRUE)

# x <- as.data.frame(ReinsuranceResults$Reins_NB$SumofBELs_df_NB_RI)
# names(x) <- as.character(unlist(x[1, ]))
# x <- x[-1, ]
# x <- as.data.frame(x)
# data_df <- readWorkbook(master_wb, sheet = "NB_Reinsurance")
# last_row <- nrow(data_df) + 1
# # Before writing the matrix to the Excel sheet, replace NA values with empty strings
# # writeData(master_wb, sheet = "NB_Reinsurance", x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# writeData(master_wb, sheet = "NB_Reinsurance", x = matrix("", ncol = ncol(data_df), nrow = last_row - 1), startRow = 2, startCol = 1)
# writeData(master_wb, sheet = "NB_Reinsurance", x = x, startRow = 2)

# ## Save the master Excel workbook
# # saveWorkbook(master_wb, master_excel, overwrite = TRUE)

# x <- as.data.frame(GrossInsuranceResults$IFCLS_CYC$SumofBELs_df_IF_InsCLS_CYC)
# names(x) <- as.character(unlist(x[1, ]))
# x <- x[-1, ]
# x <- as.data.frame(x)
# data_df <- readWorkbook(master_wb, sheet = "IF_Insurance")
# last_row <- nrow(data_df) + 1
# writeData(master_wb, sheet = "IF_Insurance", x = matrix("", ncol = ncol(data_df), nrow = last_row - 1), startRow = 2, startCol = 1)
# writeData(master_wb, sheet = "IF_Insurance", x = x, startRow = 2)
# # addStyle(master_wb, sheet = "IF_Insurance", style = numStyle, rows = 2:(nrow(x) + 1), cols = 2, gridExpand = TRUE)
# #
# # ## Save the master Excel workbook
# # saveWorkbook(master_wb, master_excel, overwrite = TRUE)
# # #
# #  x <- as.data.frame(GrossInsuranceResults$IFCLS_LIYC$SumofBELs_df_IF_InsCLS_LIYC)
# #  names(x) <- as.character(unlist(x[1, ]))
# #  x <- x[-1, ]
# #  x <- as.data.frame(x)
# #  data_df <- readWorkbook(master_wb, sheet = "Locked_IF_Insurance")
# #  last_row <- nrow(data_df) + 1
# #  writeData(master_wb, sheet = "Locked_IF_Insurance", x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# #  writeData(master_wb, sheet = "Locked_IF_Insurance", x = x, startRow = 2)
# # # addStyle(master_wb, sheet = "Locked_IF_Insurance", style = numStyle, rows = 2:(nrow(x) + 1), cols = 2, gridExpand = TRUE)

# # # # Save the master Excel workbook
# # saveWorkbook(master_wb, master_excel, overwrite = TRUE)
# #
# #  x <- as.data.frame(ReinsuranceResults$ReinIFCLS_CYC$SumofBELs_df_IF_RICLS_CYC)
# #  names(x) <- as.character(unlist(x[1, ]))
# #  x <- x[-1, ]
# #  x <- as.data.frame(x)
# #  data_df <- readWorkbook(master_wb, sheet = "IF_Reinsurance")
# #  last_row <- nrow(data_df) + 1
# #  writeData(master_wb, sheet = "IF_Reinsurance", x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# #  writeData(master_wb, sheet = "IF_Reinsurance", x = x, startRow = 2)
# # # addStyle(master_wb, sheet = "IF_Reinsurance", style = numStyle, rows = 2:(nrow(x) + 1), cols = 2, gridExpand = TRUE)
# #
# # # # Save the master Excel workbook
# # # saveWorkbook(master_wb, master_excel, overwrite = TRUE)
# #
# #  x <- as.data.frame(ReinsuranceResults$ReinsIFCLS_LIYC$SumofBELs_df_IF_RICLS_LIYC)
# #  names(x) <- as.character(unlist(x[1, ]))
# #  x <- x[-1, ]
# #  x <- as.data.frame(x)
# #  data_df <- readWorkbook(master_wb, sheet = "Locked_IF_Reinsurance")
# #  last_row <- nrow(data_df) + 1
# #  writeData(master_wb, sheet = "Locked_IF_Reinsurance", x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# #  writeData(master_wb, sheet = "Locked_IF_Reinsurance", x = x, startRow = 2)
# # # addStyle(master_wb, sheet = "Locked_IF_Reinsurance", style = numStyle, rows = 2:(nrow(x) + 1), cols = 2, gridExpand = TRUE)
# #
# # # Save the master Excel workbook
# saveWorkbook(master_wb, master_excel, overwrite = TRUE)
# # #
# #    # # Loop through each sheet in the source Excel workbook
# #    # for (i in 1:length(source_sheet_names)) {
# #    #   # Read data from source sheet
# #    #   data <- as.data.frame(readWorkbook(source_wb, sheet = i, startRow = 2)) # Skips the first row
# #    #
# #    #   writeData(master_wb, sheet = i, x = matrix("", ncol = ncol(data_df), nrow = last_row-1), startRow = 2, startCol = 1)
# #    #
# #    #
# #    #     # Write data from dataframe to the newly added sheet in the master Excel workbook
# #    #     writeData(master_wb, sheet = i, x = data, startRow = 2)
# #    #   }
# #


# #
# #
# #   # }
# # # })
# #
# #
