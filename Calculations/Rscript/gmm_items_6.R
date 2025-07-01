args <- commandArgs(trailingOnly = FALSE)
script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
if (length(script_path) == 0) script_path <- getwd()
script_dir <- normalizePath(script_path)
print(paste("Script directory is:", script_dir))

options(repos = c(CRAN = "https://cloud.r-project.org"))
packages <- c("openxlsx2", "dplyr", "lubridate", "openxlsx","readxl")
installed <- rownames(installed.packages())
for (p in packages) {
  if (!(p %in% installed)) install.packages(p)
}

library(openxlsx2)
library(dplyr)
library(lubridate)
library(openxlsx)

library(readxl)

## STEP 1. Loading the workbook
# Load the Excel workbook
# wb <- wb_load("C:/Users/ELLEN MOSWEU/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm")
setwd("C:/Users/NESK/Downloads")
file_path <- "IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm"
# Load the Excel workbook
wb <- wb_load(file_path)
TransactionTypes <- wb_to_df(wb, sheet= "TransactionTypes", rows= 1:167, cols= 1:3, col_names = TRUE)
CurrencyCodes <- wb_to_df(wb, sheet= "CurrencyCodes", rows= 1:169, cols= 1:2, col_names = TRUE)

## SETUP VARIABLES
Setup <- wb_to_df(wb, "Setup")
ReportingDate_Previous <- Setup[1,5]
ReportingDate_Current <- Setup[2,5]
Currency <- Setup[3,5]
Scope_Insurance <- Setup[6,5]
Scope_Reinsurance <- Setup[7,5]
Scope_Ins_NUB <- Setup[8,5]
Scope_Reins_NUB <- Setup[9,5]
Scope_ExchangeRates <- Setup[10,5]

Scope_LinkedCashflows <- Setup[11,5]
Scope_LockedInAssumptions <- Setup[12,5]
Scope_R_NEW_LR <- Setup[13,5]
Scope_R_IF_GEN_LR <- Setup[14,5]

Option_PLvsOCI <- Setup[17,5]
Option_DisaggregateChangeInRA <- Setup[18,5]
Option_RASimplification <- Setup[19,5]
Option_DiscountCUs <- Setup[20,5]
Option_DiscountAcqCFs <- Setup[21,5]
Option_DiscountAmortPattern <- Setup[22,5]
Option_GranularYC <- Setup[23,5]

base_path <- "C:/Users/NESK/Desktop/Empirica/Pam1000_2025/media/uploads/input_files"
# base_path <- file.path(script_dir, "..", "..", "media", "uploads", "input_files")
######################################core_inputs
core_path <- file.path(base_path, "core")
yieldcurve_path  <- file.path(core_path,"YieldCurves_input.xlsx")
ExchangeRates <- file.path(core_path,"Exchange_Rates.xlsx")

YieldCurves <- read_excel(yieldcurve_path)
ExchangeRates <- read_excel(ExchangeRates)

######################################insurance
insurance_path <- file.path(base_path, "insurance")

i_groups_path <- file.path(insurance_path, "I_group.xlsx")
i_equity_path <- file.path(insurance_path, "I_Equity.xlsx")
i_new_gen_path <- file.path(insurance_path, "I_NEW_GEN.xlsx")
i_new_cfs_path <- file.path(insurance_path, "i_new_cfs.xlsx")
i_if_gen_path <- file.path(insurance_path, "I_IF_GEN.xlsx")
i_if_fcfs_path <- file.path(insurance_path, "I_IF_FCFs.xlsx")
i_if_patterns_path <- file.path(insurance_path, "I_IF_Patterns.xlsx")

# Read Excel files with appropriate sheet names
i_groups <- read_excel(i_groups_path)
i_equity <- read_excel(i_equity_path)
i_new_gen <- read_excel(i_new_gen_path)
i_new_cfs <- read_excel(i_new_cfs_path)
i_if_gen <- read_excel(i_if_gen_path)
i_if_fcfs <- read_excel(i_if_fcfs_path)
i_if_patterns <- read_excel(i_if_patterns_path)

#############################################reinsurance

reinsurance_path <- file.path(base_path, "reinsurance")

# Define individual file paths
r_groups_path <- file.path(reinsurance_path, "R_Groups.xlsx")
r_equity_path <- file.path(reinsurance_path, "R_Equity.xlsx")
r_i_mapping_path <- file.path(reinsurance_path, "R_I_Mapping.xlsx")
r_new_gen_path <- file.path(reinsurance_path, "R_NEW_GEN.xlsx")
r_new_cfs_path <- file.path(reinsurance_path, "R_NEW_CFs.xlsx")
r_new_lr_path <- file.path(reinsurance_path, "R_NEW_LR.xlsx")
r_i_new_cfs_path <- file.path(reinsurance_path, "R_I_NEW_CFs.xlsx")
r_if_gen_path <- file.path(reinsurance_path, "R_IF_GEN.xlsx")
r_if_fcfs_path <- file.path(reinsurance_path, "R_IF_FCFs.xlsx")
r_if_patterns_path <- file.path(reinsurance_path, "R_IF_Patterns.xlsx")
r_i_if_fcfs_path <- file.path(reinsurance_path, "R_I_IF_FCFs.xlsx")
r_if_gen_lr_path <- file.path(reinsurance_path, "R_IF_GEN_LR.xlsx")

# Read Excel files with corresponding sheet names
r_groups <- read_excel(r_groups_path)
r_equity <- read_excel(r_equity_path)
r_i_mapping <- read_excel(r_i_mapping_path)
r_new_gen <- read_excel(r_new_gen_path)
r_new_cfs <- read_excel(r_new_cfs_path)
r_new_lr <- read_excel(r_new_lr_path)
r_i_new_cfs <- read_excel(r_i_new_cfs_path)
r_if_gen <- read_excel(r_if_gen_path)
r_if_fcfs <- read_excel(r_if_fcfs_path)
r_if_patterns <- read_excel(r_if_patterns_path)
r_i_if_fcfs <- read_excel(r_i_if_fcfs_path)
r_if_gen_lr <- read_excel(r_if_gen_lr_path)

####################################################pas12
source("C:/Users/NESK/Desktop/Empirica/Pam1000_2025/pas12mirror/templates/pas12_summary_calculations.R")
I_IF_GEN <-  load_pas12_data()



############################################################################inputs
# I_Groups <- wb_to_df(wb, sheet = "I_Groups", col_names = TRUE)
# I_NEW_CFs <- wb_to_df(wb, sheet = "I_NEW_CFs", col_names = TRUE)
# I_NEW_GEN <- wb_to_df(wb, sheet = "I_NEW_GEN", col_names = TRUE)

# desktop_path <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
# csv_file_path <- file.path(desktop_path, "I_NEW_CFs.csv")
# I_NEW_CFs <- readr::read_csv(csv_file_path)
# C:\Users\NESK\Desktop\Empirica\Pam1000_2025\pas12mirror\templates\pas12_summary_calculations.R

# # I_IF_GEN <- wb_to_df(wb, sheet = "I_IF_GEN", col_names = TRUE)
# I_Equity <- wb_to_df(wb, sheet = "I_Equity", col_names = TRUE)
# I_IF_Patterns <- wb_to_df(wb, sheet = "I_IF_Patterns", col_names = TRUE)
# I_IF_FCFs <- wb_to_df(wb, sheet = "I_IF_FCFs", col_names = TRUE)
# ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
# ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
# YieldCurves <- wb_to_df(wb, sheet = "YieldCurves", col_names = TRUE)
###########################################################Define column names
# source("C:/Users/NESK/Desktop/load_pas12_summary.R")

# # Call function to get dataframe
# pas12_summary_df <- load_pas12_data()


I_IN_Disc_cols <- c(
  "Reporting Date",
  "GIC Code",
  "Locked-in YC Date",
  "Currency",
  "Premium CFs (Unlinked)(Service in Current Reporting Period)",
  "Premium CFs (Unlinked)(Future Service)",
  "Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)",
  "Acquisition Expense CFs (Unlinked)(Future Service)",
  "Investment Component CFs (Unlinked)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)",
  "Premium CFs (Linked)(Service in Current Reporting Period)",
  "Premium CFs (Linked)(Future Service)",
  "Acquisition Expense CFs (Linked)(Service in Current Reporting Period)",
  "Acquisition Expense CFs (Linked)(Future Service)",
  "Investment Component CFs (Linked)",
  "Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)",
  "Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)",
  "Delay (in Years)",
  "Spot Rate (Unlinked)(Locked-in Date, Delay)",
  "Spot Rate (Unlinked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Spot Rate (Linked)(Locked-in Date, Delay)",
  "Spot Rate (Linked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)",
  "Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Locked-in Date)",
  "Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, Locked-in Date)",
  "Discounted Investment Component CFs (Locked-in YC, Locked-in Date)",
  "Discounted Non-claim CFs (Locked-in YC, Locked-in Date)",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)",
  "Discounted Claim CFs (Locked-in YC, Locked-in Date)",
  "Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, Reporting Date)",
  "Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Reporting Date)",
  "Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, Reporting Date)",
  "Discounted Investment Component CFs (Locked-in YC, Reporting Date)",
  "Discounted Non-claim CFs (Locked-in YC, Reporting Date)",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, Reporting Date)",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, Reporting Date)",
  "Discounted Claim CFs (Locked-in YC, Reporting Date)"
)

I_IN_Calc_cols <- c(
  "GIC Code",
  "Issued/Acquired",
  "Pre-recognition CFs",
  "New LRC - Premium CFs (Current Service)",
  "New LRC - Premium CFs (Future Service)",
  "New LRC - Premium CFs",
  "New LRC - Acquisition Expense CFs (Current Service)",
  "New LRC - Acquisition Expense CFs (Future Service)",
  "New LRC - Acquisition Expense CFs",
  "New LRC - Investment Component CFs",
  "New LRC - Claim and Other Expense CFs (Incurred in Current Reporting Period)",
  "New LRC - Claim and Other Expense CFs (Incurred in Future Reporting Periods)",
  "New LRC - Claim and Other Expense CFs",
  "New LRC - Total Outflows",
  "New LRC - PVFCF",
  "RA % of ABS(PVFCF Claims)",
  "New LRC - RA",
  "New LRC - FCF",
  "Non-onerous/Onerous",
  "New LRC - CSM",
  "New LRC - Loss - PVFCF",
  "New LRC - Loss - RA",
  "New LRC - Profit - PVFCF (Claims)",
  "New LRC - Profit - RA"
)

I_IN_Pre_FX_cols <- c(
  "GIC Code",
  "Transfer of Pre-recognition CFs (Issued, Non-onerous)",
  "New LRC - Profit - Premium CFs (Issued, Non-onerous)",
  "New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous)",
  "New LRC - Profit - Investment Component CFs (Issued, Non-onerous)",
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous)",
  "New LRC - Profit - RA (Issued, Non-onerous)",
  "New LRC - Profit - CSM (Issued, Non-onerous)",
  "Transfer of Pre-recognition CFs (Issued, Onerous)",
  "New LRC - Profit - Premium CFs (Issued, Onerous)",
  "New LRC - Profit - Acquisition Expense CFs (Issued, Onerous)",
  "New LRC - Profit - Investment Component CFs (Issued, Onerous)",
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Onerous)",
  "New LRC - Profit - RA (Issued, Onerous)",
  "New LRC - Profit - CSM (Issued, Onerous)",
  "New LRC - Loss - PVFCF (Issued, Onerous)",
  "New LRC - Loss - RA (Issued, Onerous)",
  "Transfer of Pre-recognition CFs (Acquired, Non-onerous)",
  "New LRC - Profit - Premium CFs (Acquired, Non-onerous)",
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Non-onerous)",
  "New LRC - Profit - Investment Component CFs (Acquired, Non-onerous)",
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Non-onerous)",
  "New LRC - Profit - RA (Acquired, Non-onerous)",
  "New LRC - Profit - CSM (Acquired, Non-onerous)",
  "Transfer of Pre-recognition CFs (Acquired, Onerous)",
  "New LRC - Profit - Premium CFs (Acquired, Onerous)",
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Onerous)",
  "New LRC - Profit - Investment Component CFs (Acquired, Onerous)",
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Onerous)",
  "New LRC - Profit - RA (Acquired, Onerous)",
  "New LRC - Profit - CSM (Acquired, Onerous)",
  "New LRC - Loss - PVFCF (Acquired, Onerous)",
  "New LRC - Loss - RA (Acquired, Onerous)"
)

I_IN_ToSL_cols <- c(
  "GIC Code",
  "Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Issued, Non-onerous)(2) - Actuals FX",
  "New LRC - Profit - Premium CFs (Issued, Non-onerous) - Actuals FX",
  "New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous) - Actuals FX",
  "New LRC - Profit - Investment Component CFs (Issued, Non-onerous) - Actuals FX",
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous) - Actuals FX",
  "New LRC - Profit - RA (Issued, Non-onerous) - Actuals FX",
  "New LRC - Profit - CSM (Issued, Non-onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Issued, Onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Issued, Onerous)(2) - Actuals FX",
  "New LRC - Profit - Premium CFs (Issued, Onerous) - Actuals FX",
  "New LRC - Profit - Acquisition Expense CFs (Issued, Onerous) - Actuals FX",
  "New LRC - Profit - Investment Component CFs (Issued, Onerous) - Actuals FX",
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Onerous) - Actuals FX",
  "New LRC - Profit - RA (Issued, Onerous) - Actuals FX",
  "New LRC - Profit - CSM (Issued, Onerous) - Actuals FX",
  "New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX",
  "New LRC - Loss - RA (Issued, Onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired, Non-onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired, Non-onerous)(2) - Actuals FX",
  "New LRC - Profit - Premium CFs (Acquired, Non-onerous) - Actuals FX",
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Non-onerous) - Actuals FX",
  "New LRC - Profit - Investment Component CFs (Acquired, Non-onerous) - Actuals FX",
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Non-onerous) - Actuals FX",
  "New LRC - Profit - RA (Acquired, Non-onerous) - Actuals FX",
  "New LRC - Profit - CSM (Acquired, Non-onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired, Onerous) - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired, Onerous)(2) - Actuals FX",
  "New LRC - Profit - Premium CFs (Acquired, Onerous) - Actuals FX",
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Onerous) - Actuals FX",
  "New LRC - Profit - Investment Component CFs (Acquired, Onerous) - Actuals FX",
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Onerous) - Actuals FX",
  "New LRC - Profit - RA (Acquired, Onerous) - Actuals FX",
  "New LRC - Profit - CSM (Acquired, Onerous) - Actuals FX",
  "New LRC - Loss - PVFCF (Acquired, Onerous) - Actuals FX",
  "New LRC - Loss - RA (Acquired, Onerous) - Actuals FX"
)

I_EQ_Calc_cols <- c(
  "GIC Code",
  "Reporting Segment",
  "Opening Insurance Finance Reserve",
  "Income/(Expense) disclosed in OCI",
  "Closing Insurance Finance Reserve",
  "Opening Retained Earnings",
  "Income/(Expense) disclosed in P&L",
  "Closing Retained Earnings"
)

I_SUB_ToT1TB_cols <- c("GIC Code","Portfolio", "Asset / Liability", 
                    "LRC - Profit - PVFCF", "LRC - Loss - PVFCF", 
                    "LRC - Profit - RA", "LRC - Loss - RA", 
                    "LRC - CSM", "LRC - PRCF", 
                    "LIC - PVFCF", "LIC - RA", "LIC - IC")

I_SUB_ToT0TB_cols <- c(
  "GIC Code",
  "Portfolio",
  "Asset / Liability",
  "LRC - Profit - PVFCF",
  "LRC - Loss - PVFCF",
  "LRC - Profit - RA",
  "LRC - Loss - RA",
  "LRC - CSM",
  "LRC - PRCF",
  "LIC - PVFCF",
  "LIC - RA",
  "LIC - IC"
)

I_SUB_Disc1_cols <- c(
  "Reporting Date", "GIC Code", "Locked-in YC Date", "Currency", 
  "Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Past Service) - Prev FX", 
  "Premium CFs (Unlinked)(Past Service) - Current FX", 
  "Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX", 
  "Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX", 
  "Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Future Service) - Prev FX", 
  "Premium CFs (Unlinked)(Future Service) - Current FX", 
  "Acquisition Expense CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Unlinked)(Past Service) - Prev FX", 
  "Acquisition Expense CFs (Unlinked)(Past Service) - Current FX", 
  "Acquisition Expense CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Unlinked)(Service in Next Reporting Period) - Prev FX", 
  "Acquisition Expense CFs (Unlinked)(Service in Next Reporting Period) - Current FX", 
  "Acquisition Expense CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Unlinked)(Future Service) - Prev FX", 
  "Acquisition Expense CFs (Unlinked)(Future Service) - Current FX", 
  "Investment Component CFs (Unlinked)(Payable in Future)(Locked-in Financial Assumptions)(Current Discretion)",
  "Investment Component CFs (Unlinked)(Payable in Future) - Prev FX", 
  "Investment Component CFs (Unlinked)(Payable in Future) - Current FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Prior Reporting Periods) - Prev FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Prior Reporting Periods) - Current FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period) - Prev FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period) - Current FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Next Reporting Period) - Prev FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Next Reporting Period) - Current FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods) - Prev FX", 
  "Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods) - Current FX", 
  "Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Past Service) - Prev FX", 
  "Premium CFs (Linked)(Past Service) - Current FX", 
  "Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX", 
  "Premium CFs (Linked)(Service in Next Reporting Period) - Current FX", 
  "Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Future Service) - Prev FX", 
  "Premium CFs (Linked)(Future Service) - Current FX", 
  "Acquisition Expense CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Linked)(Past Service) - Prev FX", 
  "Acquisition Expense CFs (Linked)(Past Service) - Current FX", 
  "Acquisition Expense CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Linked)(Service in Next Reporting Period) - Prev FX", 
  "Acquisition Expense CFs (Linked)(Service in Next Reporting Period) - Current FX", 
  "Acquisition Expense CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Acquisition Expense CFs (Linked)(Future Service) - Prev FX", 
  "Acquisition Expense CFs (Linked)(Future Service) - Current FX", 
  "Investment Component CFs (Linked)(Payable in Future)(Locked-in Financial Assumptions)(Current Discretion)",
  "Investment Component CFs (Linked)(Payable in Future) - Prev FX", 
  "Investment Component CFs (Linked)(Payable in Future) - Current FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Linked)(Incurred in Prior Reporting Periods) - Prev FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Prior Reporting Periods) - Current FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period) - Prev FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period) - Current FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Linked)(Incurred in Next Reporting Period) - Prev FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Next Reporting Period) - Current FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions)(Current Discretion)",
  "Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods) - Prev FX", 
  "Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods) - Current FX", 
  "Delay (in Years)", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Previous Reporting Date, Delay)", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Previous Reporting Date, min[Delay, Reporting Period])", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Current Reporting Date, Delay)", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date))", 
  "Spot Rate (Unlinked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date) + min[Delay, Reporting Period])", 
  "Spot Rate (Unlinked)(Incurred Claims)(Previous Reporting Date, Delay)", 
  "Spot Rate (Unlinked)(Incurred Claims)(Previous Reporting Date, min[Delay, Reporting Period])", 
  "Spot Rate (Unlinked)(Incurred Claims)(Current Reporting Date, Delay)", 
  "Spot Rate (Unlinked)(Incurred Claims)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)", 
  "Spot Rate (Unlinked)(Incurred Claims)(Locked-in Date, (Reporting Date - Locked-in Date))",
  "Spot_Rate_Unlinked_Incurred_Claims_Locked_in_Date", 
  "Spot_Rate_Linked_Remaining_Coverage_Previous_`Reporting Date`_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Previous_`Reporting Date`_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Remaining_Coverage_Current_`Reporting Date`_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Incurred_Claims_Previous_`Reporting Date`_Delay", 
  "Spot_Rate_Linked_Incurred_Claims_Previous_`Reporting Date`_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Incurred_Claims_Current_`Reporting Date`_Delay", 
  "Spot_Rate_Linked_Incurred_Claims_Locked_in_Date_Delay", 
  "Spot_Rate_Linked_Incurred_Claims_Locked_in_Date", 
  "Spot_Rate_Linked_Incurred_Claims_Locked_in_Date_min_Delay_Reporting_Period",
  "Discounted_Premium_CFs_Past_Service_Prev_YC_t0",
  "Discounted_Premium_CFs_Service_in_Next_Reporting_Period_Prev_YC_t0",
  "Discounted_Premium_CFs_Future_Service_Prev_YC_t0",
  "Discounted_Acquisition_Expense_CFs_Past_Service_Prev_YC_t0",
  "Discounted_Acquisition_Expense_CFs_Service_in_Next_Reporting_Period_Prev_YC_t0",
  "Discounted_Acquisition_Expense_CFs_Future_Service_Prev_YC_t0",
  "Discounted_Investment_Component_CFs_Payable_in_Future_Prev_YC_t0",
  "Discounted_Non_claim_CFs_Prev_YC_t0",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Prior_Reporting_Periods_Prev_YC_t0_Current_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Current_Reporting_Period_Prev_YC_t0_Current_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_the_Past_Prev_YC_t0_Current_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Prior_Reporting_Periods_Prev_YC_t0_Prev_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Current_Reporting_Period_Prev_YC_t0_Prev_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_the_Past_Prev_YC_t0_Prev_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Next_Reporting_Period_Prev_YC_t0",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Future_Reporting_Periods_Prev_YC_t0",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_the_Future_Prev_YC_t0",
  "Discounted_Premium_CFs_Past_Service_Current_YC_t0_Prev_FX",
  "Discounted_Premium_CFs_Service_in_Next_Reporting_Period_Current_YC_t0_Prev_FX",
  "Discounted_Premium_CFs_Future_Service_Current_YC_t0_Prev_FX",
  "Discounted_Acquisition_Expense_CFs_Past_Service_Current_YC_t0_Prev_FX",
  "Discounted_Acquisition_Expense_CFs_Service_in_Next_Reporting_Period_Current_YC_t0_Prev_FX",
  "Discounted_Acquisition_Expense_CFs_Future_Service_Current_YC_t0_Prev_FX",
  "Discounted_Investment_Component_CFs_Payable_in_Future_Current_YC_t0_Prev_FX",
  "Discounted_Non_claim_CFs_Current_YC_t0_Prev_FX",
  "Discounted_Premium_CFs_Past_Service_Current_YC_t0_Current_FX",
  "Discounted_Premium_CFs_Service_in_Next_Reporting_Period_Current_YC_t0_Current_FX",
  "Discounted_Premium_CFs_Future_Service_Current_YC_t0_Current_FX",
  "Discounted_Acquisition_Expense_CFs_Past_Service_Current_YC_t0_Current_FX",
  "Discounted_Acquisition_Expense_CFs_Service_in_Next_Reporting_Period_Current_YC_t0_Current_FX",
  "Discounted_Acquisition_Expense_CFs_Future_Service_Current_YC_t0_Current_FX",
  "Discounted_Investment_Component_CFs_Payable_in_Future_Current_YC_t0_Current_FX",
  "Discounted_Non_claim_CFs_Current_YC_t0_Current_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Prior_Reporting_Periods_Current_YC_t0_Current_FX",
  "Discounted_Claim_and_Other_Expense_CFs_Incurred_in_Current_Reporting_Period_Current_YC_t0_Current_FX",
  "Discounted Claim and Other Expense CFs (Incurred in the Past)(Current YC, t0) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in Prior Reporting Periods)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in the Past)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in Next Reporting Period)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in the Future)(Current YC, t0) - Prev FX",
  "Discounted Claim and Other Expense CFs (Incurred in Next Reporting Period)(Current YC, t0) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Current YC, t0) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in the Future)(Current YC, t0) - Current FX",
  "Discounted Premium CFs (Past Service)(Locked-in YC, t0)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t0)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, t0)",
  "Discounted Acquisition Expense CFs (Past Service)(Locked-in YC, t0)",
  "Discounted Acquisition Expense CFs (Service in Next Reporting Period)(Locked-in YC, t0)",
  "Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, t0)",
  "Discounted Investment Component CFs (Payable in Future)(Locked-in YC, t0)",
  "Discounted Non-claim CFs (Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in Prior Reporting Periods)(Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in the Past)(Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in Next Reporting Period)(Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, t0)",
  "Discounted Claim and Other Expense CFs (Incurred in the Future)(Locked-in YC, t0)",
  "Discounted Premium CFs (Past Service)(Locked-in YC, t1)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t1)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, t1)",
  "Discounted Acquisition Expense CFs (Past Service)(Locked-in YC, t1)",
  "Discounted Acquisition Expense CFs (Service in Next Reporting Period)(Locked-in YC, t1)",
  "Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, t1)",
  "Discounted Investment Component CFs (Payable in Future)(Locked-in YC, t1)",
  "Discounted Non-claim CFs (Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Prior Reporting Periods)(Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in the Past)(Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Next Reporting Period)(Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in the Future)(Locked-in YC, t1)",
  "Discounted Premium CFs (Past Service)(Prev YC, t1)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Prev YC, t1)",
  "Discounted Premium CFs (Future Service)(Prev YC, t1)",
  "Discounted Acquisition Expense CFs (Past Service)(Prev YC, t1)",
  "Discounted Acquisition Expense CFs (Service in Next Reporting Period)(Prev YC, t1)",
  "Discounted Acquisition Expense CFs (Future Service)(Prev YC, t1)",
  "Discounted Investment Component CFs (Payable in Future)(Prev YC, t1)",
  "Discounted Non-claim CFs (Prev YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Prior Reporting Periods)(Prev YC, t1) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Prev YC, t1) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in the Past)(Prev YC, t1) - Current FX",
  "Discounted Claim and Other Expense CFs (Incurred in Next Reporting Period)(Prev YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Prev YC, t1)",
  "Discounted Claim and Other Expense CFs (Incurred in the Future)(Prev YC, t1)"
)


 I_SUB_Disc2_cols  <- c(
    "Reporting Date", 
    "GIC Code", 
    "Locked-in YC Date", 
    "Currency", 
    "Coverage Units (Undiscounted)", 
    "Amortisation Pattern (Undiscounted)", 
    "Reporting Period (0 = current)", 
    "Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date) + # Reporting Periods * Reporting Period)", 
    "Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date))", 
    "Spot Rate (Current Reporting Date, Reporting period)", 
    "Discounted Coverage Units (Locked-in YC, t0)", 
    "Discounted Amortisation Pattern (Locked-in YC, t0)"
  )


I_SUB_Calc_cols <- c(
  "GIC Code", 
  "Currency", 
  "Locked-in YC Date", 
  "RA % of ABS(PVFCF Claims)", 
  "Opening LRC - PVFCF (Non-claims)", 
  "Opening LRC - PVFCF (Non-claims) - Post Roll Forward (Prev YC)", 
  "Opening LRC - PVFCF (Non-claims)(Locked-in YC)", 
  "Opening LRC - PVFCF (Non-claims) - Post Roll Forward (LIYC)", 
  "Effect on Opening LRC - PVFCF (Non-claims) of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening LRC - PVFCF (Non-claims)", 
  "New LRC - PVFCF (Non-claims)", 
  "New LRC - PVFCF (Non-claims) - Post Roll Forward", 
  "Interest Accreted on New LRC - PVFCF (Non-claims)", 
  "LRC - PVFCF (Non-claims) - Post Roll Forward", 
  "Actual less Expected Return on LRC IC", 
  "Interest Accreted on LRC - PVFCF (Non-claims)", 
  "Expected Premium (Past/Current)(Opening)", 
  "Expected Premium (Past/Current)(New)", 
  "Premium Receipts (Past/Current)", 
  "Expected Premium (Past/Current)(Closing)", 
  "Premium Experience Variance (Past/Current)", 
  "LRC - PVFCF (Non-claims) - Post Premium Experience Variances (Past/Current)", 
  "Expected Acquisition Expense (Past/Current)(Opening)", 
  "Expected Acquisition Expense (Past/Current)(New)",
  "Acquisition Expense Payments (Past/Current)", 
  "Expected Acquisition Expense (Past/Current)(Closing)", 
  "Acquisition Expense Experience Variance (Past/Current)", 
  "LRC - PVFCF (Non-claims) - Post Acquisition Expense Experience Variances (Past/Current)", 
  "Expected Non-claim CFs (Future)(Opening)", 
  "Expected Non-claim CFs (Future)(New)", 
  "Non-claim Receipts/Payments/Transfers (Future)", 
  "Expected Non-claim CFs (Future)(Closing)", 
  "Effect on LRC - PVFCF (Non-claims) of Non-claim CFs Experience Variance (Future - Non FX)", 
  "LRC - PVFCF (Non-claims) - Post Non-claim CFs Experience Variance (Future)", 
  "Premium Receipts", 
  "Acquisition Expense Payments", 
  "Transfer of Investment Components", 
  "LRC - PVFCF (Non-claims) - Post Payments/Receipts/Transfers", 
  "Closing LRC - PVFCF (Non-claims) - Prev FX", 
  "Closing LRC - PVFCF (Non-claims) - Current FX", 
  "Effect on LRC - PVFCF (Non-claims) of Changes in Interest Rates (2/2)", 
  "Effect on LRC - PVFCF (Non-claims) of Changes in Interest Rates", 
  "Effect on LRC - PVFCF (Non-claims) of Non-claim CFs Experience Variance (Future - FX)", 
  "Opening LRC - PVFCF (Claims)", 
  "Opening LRC - PVFCF (Claims) (Locked-in YC)", 
  "Opening LRC - PVFCF (Claims) - Post Roll Forward (Prev YC)", 
  "Opening LRC - PVFCF (Claims) - Post Roll Forward (LIYC)",
  "Effect on Opening LRC - PVFCF (Claims) of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening LRC - PVFCF (Claims)", 
  "Interest Accreted on Opening LRC - PVFCF (Claims) (Locked-in YC)", 
  "New LRC - PVFCF (Claims)", 
  "New LRC - PVFCF (Claims) - Post Roll Forward", 
  "Interest Accreted on New LRC - PVFCF (Claims)", 
  "LRC - PVFCF (Claims) - Post Roll Forward", 
  "Interest Accreted on LRC - PVFCF (Claims)", 
  "Expected Claim CFs (Current)(Opening)", 
  "Expected Claim CFs (Current)(New)", 
  "Effect on LRC - PVFCF (Claims) of Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - PVFCF (Claims) - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "Expected Claim CFs (Future)(Opening)", 
  "Expected Claim CFs (Future)(New)", 
  "Expected Claim CFs (Future)(Closing)", 
  "Effect on LRC - PVFCF (Claims) of Claim CFs Experience Variance (Future) - Non FX", 
  "LRC - PVFCF (Claims) - Post Claim CFs Non FX Experience Variances (Future)", 
  "Effect on LRC - PVFCF (Claims) of Claim CFs Experience Variance (Future) - FX", 
  "Effect on LRC - PVFCF (Claims) of Claim CFs Experience Variance (Future) - FX and Non FX", 
  "Closing LRC - PVFCF (Claims) - Prev FX", 
  "Closing LRC - PVFCF (Claims) - Current FX", 
  "Effect on LRC - PVFCF (Claims) of Changes in Interest Rates (2/2)", 
  "Effect on LRC - PVFCF (Claims) of Changes in Interest Rates", 
  "Opening LRC - RA", 
  "Effect on Opening LRC - RA of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening LRC - RA", 
  "Interest Accreted on Opening LRC - RA (Locked-in YC)", 
  "New LRC - RA", 
  "Interest Accreted on New LRC - RA", 
  "Interest Accreted on LRC - RA", 
  "LRC - RA - Post Roll Forward",
  "Closing LRC - RA (Current FX)", 
  "Effect on LRC - RA of Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - RA - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "Effect on LRC - RA of Claim CFs Experience Variance (Future) (Non FX)", 
  "Effect on LRC - RA of Claim CFs Experience Variance (Future) (FX)", 
  "LRC - RA - Post Claim CFs Experience Variance (Future) - Non FX", 
  "Effect on LRC - RA of Changes in Interest Rates (2/2)", 
  "Effect on LRC - RA of Changes in Interest Rates", 
  "Opening LRC - Loss - PVFCF", 
  "Opening LRC - Profit - PVFCF (Claims)", 
  "Effect on Opening LRC - Loss - PVFCF of Changes in Interest Rates (1/2)", 
  "Effect on Opening LRC - Profit - PVFCF of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening LRC - Loss - PVFCF (Prev YC)", 
  "Interest Accreted on Opening LRC - Profit - PVFCF (Claims) (Prev YC)", 
  "Interest Accreted on Opening LRC - Loss - PVFCF (Locked-in YC)", 
  "Interest Accreted on Opening LRC - Profit - PVFCF (Claims) (Locked-in YC)", 
  "New LRC - Loss - PVFCF", 
  "New LRC - Profit - PVFCF (Claims)", 
  "Interest Accreted on New LRC - Loss - PVFCF", 
  "Interest Accreted on New LRC - Profit - PVFCF (Claims)", 
  "Interest Accreted on LRC - Loss - PVFCF", 
  "Interest Accreted on LRC - Loss - PVFCF (Locked-in YC)", 
  "Interest Accreted on LRC - Profit - PVFCF (Claims)", 
  "LRC - Loss - PVFCF - Post Roll Forward", 
  "LRC - Profit - PVFCF (Claims) - Post Roll Forward", 
  "Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)",
  "Effect on LRC - Profit - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - Loss - PVFCF - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - Profit - PVFCF (Claims) - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "Opening LRC - Profit - PVFCF", 
  "Interest Accreted on Opening LRC - Profit - PVFCF", 
  "Interest Accreted on Opening LRC - Profit - PVFCF (Locked-in YC)", 
  "Opening LRC - Loss - RA", 
  "Opening LRC - Profit - RA", 
  "Effect on Opening LRC - Loss - RA of Changes in Interest Rates (1/2)", 
  "Effect on Opening LRC - Profit - RA of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening LRC - Loss - RA", 
  "Interest Accreted on Opening LRC - Profit - RA", 
  "Interest Accreted on Opening LRC - Loss - RA (Locked-in YC)", 
  "Interest Accreted on Opening LRC - Profit - RA (Locked-in YC)", 
  "New LRC - Loss - RA", 
  "New LRC - Profit - RA", 
  "Interest Accreted on New LRC - Loss - RA", 
  "Interest Accreted on New LRC - Profit - RA", 
  "Interest Accreted on LRC - Loss - RA", 
  "Interest Accreted on LRC - Profit - RA", 
  "Interest Accreted on LRC - Loss - RA (Locked-in YC)", 
  "Interest Accreted on LRC - Profit - RA (Locked-in YC)", 
  "LRC - Loss - RA - Post Roll Forward", 
  "LRC - Profit - RA - Post Roll Forward", 
  "Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "Effect on LRC - Profit - RA of Removal of Expected Claims and Other Expenses Incurred (Current)",
  "LRC - Loss - RA - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - Profit - RA - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "LRC - Loss - FCF - Post Removal of Expected Claims and Other Expenses Incurred (Current)", 
  "Opening LRC - CSM", 
  "Opening LRC - CSM - Post Roll Forward", 
  "New LRC - CSM", 
  "New LRC - CSM - Post Roll Forward", 
  "LRC - CSM - Post Roll Forward", 
  "Interest Accreted on LRC - CSM", 
  "Total Change in FCF (Future) Non FX", 
  "Non-onerous/Onerous (Opening)", 
  "Non-onerous/Onerous (After Non FX change in FCF)", 
  "Effect on LRC - CSM of Total Experience Variance (Future) - Non FX", 
  "LRC - CSM - Post Total Experience Variance (Future)", 
  "Release in LRC - CSM", 
  "Closing LRC - CSM", 
  "Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX", 
  "LRC - Loss - RA - Post Total Experience Variance (Future) - Non FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - Non FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - Non FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - FX",
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates (2/2)", 
  "Effect on LRC - Loss - RA of Changes in Interest Rates (2/2)", 
  "Effect on LRC - Profit - PVFCF of Changes in Interest Rates (2/2)", 
  "Effect on LRC - Profit - RA of Changes in Interest Rates (2/2)", 
  "Closing LRC - Loss - PVFCF", 
  "Closing LRC - Loss - RA", 
  "Closing LRC - Profit - PVFCF", 
  "Closing LRC - Profit - RA", 
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates", 
  "Effect on LRC - Loss - RA of Changes in Interest Rates", 
  "Effect on LRC - Profit - PVFCF of Changes in Interest Rates", 
  "Effect on LRC - Profit - RA of Changes in Interest Rates", 
  "Opening LIC - PVFCF", 
  "Opening LIC - PVFCF (Locked-in YC)", 
  "LIC - PVFCF - Post Roll Forward", 
  "LIC - PVFCF - Post Roll Forward (Locked-in YC)", 
  "Interest Accreted on LIC - PVFCF", 
  "Interest Accreted on LIC - PVFCF (Locked-in YC)", 
  "Claim and Other Expense Payments (Past)", 
  "LIC - PVFCF - Post Changes to Claim CFs (Past)", 
  "Effect on LIC - PVFCF of Changes to Claims CFs (Past)", 
  "Claim and Other Expense Payments (Incurred in Current Reporting Period)", 
  "LIC - PVFCF - Post Addition of New Claims and Other Expenses Incurred (Current)", 
  "Effect on LIC - PVFCF of New Claims and Other Expenses Incurred (Current)", 
  "LIC - PVFCF - Post Changes in Interest Rates", 
  "Effect on LIC - PVFCF of Changes in Interest Rates",
  "Effect on LIC - PVFCF of Change in Exchange Rates", 
  "Claim and Other Expense Payments", 
  "Closing LIC - PVFCF", 
  "Opening LIC - RA", 
  "Closing LIC - RA", 
  "Interest Accreted on LIC - RA", 
  "Interest Accreted on LIC - RA (Locked-in YC)", 
  "Effect on LIC - RA of Changes to Claims CFs (Past)", 
  "Effect on LIC - RA of New Claims and Other Expenses Incurred (Current)", 
  "Effect on LIC - RA of Changes in Interest Rates", 
  "Effect on LIC - RA of Change in Exchange Rates", 
  "Opening LIC - IC", 
  "Investment Component Payments", 
  "Closing LIC - IC", 
  "Effect on LIC - IC of Changes to IC CFs (Past)", 
  "Opening LRC - PRCF", 
  "Pre-recognition CF Payments", 
  "Impairment of PRCF Asset", 
  "Reversal of Impairment of PRCF Asset", 
  "Transfer of Pre-recognition CFs", 
  "Closing LRC - PRCF", 
  "Pre-recognition CFs", 
  "Pre-recognition CFs - Post Roll Forward", 
  "Accretion on Pre-recognition CFs (LIYC)", 
  "Opening Notional DAC", 
  "Accretion factor on Opening NDAC",
  "Accretion on Opening NDAC", 
  "New Future Acquisition Expense Payments (LIYC)", 
  "New Future Acquisition Expense Payments rolled forward (LIYC)", 
  "Accretion on New Future Acquisition Expense Payments", 
  "Interest Accreted on DAC", 
  "Expected Acquisition Expense (Past/Current)(Opening) Prev YC", 
  "Expected Acquisition Expense (Past/Current)(Closing) Current YC", 
  "Acquisition Expense Experience Variance (Past/Current) Current YC", 
  "Expected Acquisition Expense (Future)(Opening) LIYC", 
  "Expected Acquisition Expense (Future)(New)", 
  "Acquisition Expense Payments (Future)", 
  "Expected Acquisition Expense (Future)(Closing) LIYC", 
  "Acquisition Expense Experience Variance (Future) LIYC", 
  "Expected Acquisition Expense (Future)(Opening) Prev YC", 
  "Expected Acquisition Expense (Future)(Closing) Current YC", 
  "Acquisition Expense Experience Variance (Future) Current YC", 
  "Expected Acquisition Expense (Total)(Opening) No YC", 
  "Acquisition Expense Payments (Total)", 
  "Expected Acquisition Expense (Total)(Closing) No YC", 
  "Acquisition Expense Experience Variance (Total) No YC", 
  "Closing Notional DAC (before release)", 
  "Closing Notional DAC", 
  "Release in Notional DAC"
)

I_FX_cols <- c(
  "GIC Code", "Currency", 
  "Opening LRC - Profit - PVFCF - Actuals FX", "New LRC - Profit - Premium CFs (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Investment Component CFs (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Premium CFs (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - Acquisition Expense CFs (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - Investment Component CFs (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - Claim and Other Expense CFs (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - Premium CFs (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Investment Component CFs (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - Premium CFs (Acquired, Onerous) - Actuals FX", 
  "New LRC - Profit - Acquisition Expense CFs (Acquired, Onerous) - Actuals FX", 
  "New LRC - Profit - Investment Component CFs (Acquired, Onerous) - Actuals FX", 
  "New LRC - Profit - Claim and Other Expense CFs (Acquired, Onerous) - Actuals FX", 
  "Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX", 
  "Interest Accreted on Opening LRC - Profit - PVFCF - OCI - Actuals FX", 
  "Premium Experience Variance (Past/Current) - Actuals FX", 
  "Acquisition Expense Experience Variance (Past/Current) - Actuals FX", 
  "Effect on LRC - Profit - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Profit - PVFCF of Changes in Interest Rates - Current FX", 
  "Premium Receipts - Actuals FX", 
  "Acquisition Expense Payments - Actuals FX", 
  "Transfer of Investment Components - Actuals FX", 
  "Closing LRC - Profit - PVFCF - Actuals FX", 
  "Closing LRC - Profit - PVFCF - Current FX", 
  "Closing LRC - Profit - PVFCF - Net foreign exchange income / (expenses)", 
  "Opening LRC - Loss - PVFCF - Actuals FX", 
  "New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX", 
  "New LRC - Loss - PVFCF (Acquired, Onerous) - Actuals FX", 
  "Interest Accreted on LRC - Loss - PVFCF - Actuals FX", 
  "Interest Accreted on LRC - Loss - PVFCF - OCI - Actuals FX", 
  "Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates - Current FX", 
  "Closing LRC - Loss - PVFCF - Actuals FX", 
  "Closing LRC - Loss - PVFCF - Current FX", 
  "Closing LRC - Loss - PVFCF - Net foreign exchange income / (expenses)", 
  "Opening LRC - Profit - RA - Actuals FX", 
  "New LRC - Profit - RA (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - RA (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - RA (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - RA (Acquired, Onerous) - Actuals FX", 
  "Interest Accreted on LRC - Profit - RA - Actuals FX", 
  "Interest Accreted on LRC - Profit - RA - OCI - Actuals FX", 
  "Effect on LRC - Profit - RA of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Profit - RA of Changes in Interest Rates - Current FX", 
  "Closing LRC - Profit - RA - Actuals FX", 
  "Closing LRC - Profit - RA - Current FX", 
  "Closing LRC - Profit - RA - Net foreign exchange income / (expenses)", 
  "Opening LRC - Loss - RA - Actuals FX", 
  "New LRC - Loss - RA (Issued, Onerous) - Actuals FX", 
  "New LRC - Loss - RA (Acquired, Onerous) - Actuals FX", 
  "Interest Accreted on LRC - Loss - RA - Actuals FX", 
  "Interest Accreted on LRC - Loss - RA - OCI - Actuals FX", 
  "Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Loss - RA of Changes in Interest Rates - Current FX", 
  "Closing LRC - Loss - RA - Actuals FX", 
  "Closing LRC - Loss - RA - Current FX", 
  "Closing LRC - Loss - RA - Net foreign exchange income / (expenses)", 
  "Opening LRC - CSM - Actuals FX", 
  "New LRC - Profit - CSM (Issued, Non-onerous) - Actuals FX", 
  "New LRC - Profit - CSM (Issued, Onerous) - Actuals FX", 
  "New LRC - Profit - CSM (Acquired, Non-onerous) - Actuals FX", 
  "New LRC - Profit - CSM (Acquired, Onerous) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Issued, Onerous) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired, Non-onerous) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired, Onerous) - Actuals FX", 
  "Interest Accreted on LRC - CSM - Actuals FX", 
  "Effect on LRC - CSM of Total Experience Variance (Future) - Non FX - Current FX", 
  "Release in LRC - CSM - Actuals FX", 
  "Closing LRC - CSM - Actuals FX", 
  "Closing LRC - CSM - Current FX", 
  "Closing LRC - CSM - Net foreign exchange income / (expenses)", 
  "Opening LIC - PVFCF - Actuals FX",  
  "Interest Accreted on LIC - PVFCF - Actuals FX", 
  "Interest Accreted on LIC - PVFCF - OCI - Actuals FX", 
  "Effect on LIC - PVFCF of Changes to Claims CFs (Past) - Current FX", 
  "Effect on LIC - PVFCF of New Claims and Other Expenses Incurred (Current) - Current FX", 
  "Effect on LIC - PVFCF of Changes to Claims CFs (Future) - Non FX - Current FX", 
  "Effect on LIC - PVFCF of Changes to Claims CFs (Future) - FX - Current FX", 
  "Effect on LIC - PVFCF of Changes in Interest Rates - Current FX", 
  "Closing LIC - PVFCF - Actuals FX", 
  "Closing LIC - PVFCF - Current FX", 
  "Closing LIC - PVFCF - Net foreign exchange income / (expenses)",
  "Opening LIC - RA - Actuals FX", "Interest Accreted on LIC - RA - Actuals FX", 
  "Interest Accreted on LIC - RA - OCI - Actuals FX", "Effect on LIC - RA of Changes to Claims CFs (Past) - Current FX", 
  "Effect on LIC - RA of New Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LIC - RA of Change in Exchange Rates - Current FX", 
  "Effect on LIC - RA of Changes in Interest Rates - Current FX", 
  "Closing LIC - RA - Actuals FX", "Closing LIC - RA - Current FX", 
  "Closing LIC - RA - Net foreign exchange income / (expenses)", 
  "Opening LIC - IC - Actuals FX", "Effect on LIC - IC of Changes to IC CFs (Past) - Current FX", 
  "Investment Component Payments - Actuals FX", "Closing LIC - IC - Actuals FX", 
  "Closing LIC - IC - Current FX", "Closing LIC - IC - Net foreign exchange income / (expenses)", 
  "Opening LRC - PRCF - Actuals FX", "Transfer of Pre-recognition CFs (Issued, Non-onerous)(2) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Issued, Onerous)(2) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired, Non-onerous)(2) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired, Onerous)(2) - Actuals FX", "Pre-recognition CF Payments - Actuals FX", 
  "Impairment of PRCF Asset - Current FX", "Reversal of Impairment of PRCF Asset - Current FX", 
  "Closing LRC - PRCF - Actuals FX", "Closing LRC - PRCF - Current FX", 
  "Closing LRC - PRCF - Net foreign exchange income / (expenses)", 
  "Release in Notional DAC - Actuals FX"
)

I_SUB_ToSL_cols <- c(
  "GIC Code", "Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX", 
  "Interest Accreted on Opening LRC - Profit - PVFCF - OCI - Actuals FX", 
  "Premium Experience Variance (Past/Current) - Actuals FX", 
  "Acquisition Expense Experience Variance (Past/Current) - Actuals FX", 
  "Effect on LRC - Profit - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Profit - PVFCF of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Profit - PVFCF of Changes in Interest Rates - Current FX", 
  "Premium Receipts - Actuals FX", "Premium Receipts (2) - Actuals FX", 
  "Acquisition Expense Payments - Actuals FX", "Acquisition Expense Payments (2) - Actuals FX", 
  "Transfer of Investment Components - Actuals FX", "Transfer of Investment Components (2) - Actuals FX", 
  "Interest Accreted on LRC - Loss - PVFCF - Actuals FX", 
  "Interest Accreted on LRC - Loss - PVFCF - OCI - Actuals FX", 
  "Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates - Current FX", 
  "Interest Accreted on LRC - Profit - RA - Actuals FX", "Interest Accreted on LRC - Profit - RA - OCI - Actuals FX", 
  "Effect on LRC - Profit - RA of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Profit - RA of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Profit - RA of Changes in Interest Rates - Current FX", 
  "Interest Accreted on LRC - Loss - RA - Actuals FX", "Interest Accreted on LRC - Loss - RA - OCI - Actuals FX", 
  "Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX - Current FX", 
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX - Current FX", 
  "Effect on LRC - Loss - RA of Changes in Interest Rates - Current FX", 
  "Interest Accreted on LRC - CSM - Actuals FX", "Effect on LRC - CSM of Total Experience Variance (Future) - Non FX - Current FX", 
  "Release in LRC - CSM - Actuals FX", "Interest Accreted on LIC - PVFCF - Actuals FX", 
  "Interest Accreted on LIC - PVFCF - OCI - Actuals FX", "Effect on LIC - PVFCF of Changes to Claims CFs (Past) - Current FX", 
  "Effect on LIC - PVFCF of New Claims and Other Expenses Incurred (Current) - Current FX", 
  "Effect on LIC - PVFCF of Changes in Interest Rates - Current FX", 
  "Effect on LIC - PVFCF of Change in Exchange Rates - Current FX", 
  "Claim and Other Expense Payments - Actuals FX", "Claim and Other Expense Payments (2) - Actuals FX", 
  "Interest Accreted on LIC - RA - Actuals FX", "Interest Accreted on LIC - RA - OCI - Actuals FX", 
  "Effect on LIC - RA of Changes to Claims CFs (Past) - Current FX", 
  "Effect on LIC - RA of New Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on LIC - RA of Change in Exchange Rates - Current FX", 
  "Effect on LIC - RA of Changes in Interest Rates - Current FX", 
  "Effect on LIC - IC of Changes to IC CFs (Past) - Current FX", "Investment Component Payments - Actuals FX", 
  "Investment Component Payments (2) - Actuals FX", "Pre-recognition CF Payments - Actuals FX", 
  "Pre-recognition CF Payments (2) - Actuals FX", "Impairment of PRCF Asset - Current FX", 
  "Reversal of Impairment of PRCF Asset - Current FX", "Release in Notional DAC - Actuals FX", 
  "Release in Notional DAC (2) - Actuals FX", 
  "Closing LRC - Profit - PVFCF - Net foreign exchange income / (expenses)", 
  "Closing LRC - Loss - PVFCF - Net foreign exchange income / (expenses)", 
  "Closing LRC - Profit - RA - Net foreign exchange income / (expenses)", 
  "Closing LRC - Loss - RA - Net foreign exchange income / (expenses)", 
  "Closing LRC - CSM - Net foreign exchange income / (expenses)", 
  "Closing LIC - PVFCF - Net foreign exchange income / (expenses)", 
  "Closing LIC - RA - Net foreign exchange income / (expenses)", 
  "Closing LIC - IC - Net foreign exchange income / (expenses)", 
  "Closing LRC - PRCF - Net foreign exchange income / (expenses)"
)

I_SUB_ToPRCF_cols <- c(
  "GIC Code",
  paste0("LRC - PRCF Release - Reporting Period ", 1:99)  # Add Reporting Period columns from 1 to 99
)

I_SUB_ToCSM_cols <- c(
  "GIC Code",
  paste0("LRC - CSM Release - Reporting Period ", 1:100)  # Add Reporting Period columns from 1 to 100
)



############################################################
# Create DataFrames for each sheet with example data (replace with your actual data)
library(dplyr)
# DataFrame for LRC_1

# DataFrame for I_IN_Disc
I_IN_Disc <- data.frame(matrix(ncol = length(I_IN_Disc_cols), nrow = length(I_NEW_CFs$`Reporting Date`)))
colnames(I_IN_Disc) <- I_IN_Disc_cols

I_IN_Calc <- data.frame(matrix(ncol = length(I_IN_Calc_cols), nrow = length(I_NEW_GEN$`GIC Code`)))
colnames(I_IN_Calc) <- I_IN_Calc_cols

I_IN_ToSL <- data.frame(matrix(ncol = length(I_IN_ToSL_cols), nrow = length(I_IN_Calc$`GIC Code`)))
colnames(I_IN_ToSL) <- I_IN_ToSL_cols

I_IN_Pre_FX <- data.frame(matrix(ncol = length(I_IN_Pre_FX_cols), nrow = length(I_IN_Calc$`GIC Code`)))
colnames(I_IN_Pre_FX) <- I_IN_Pre_FX_cols

I_SUB_ToT1TB <- data.frame(matrix(ncol = length(I_SUB_ToT1TB_cols), nrow = length(I_Groups$`GIC Code`)))
colnames(I_SUB_ToT1TB) <- I_SUB_ToT1TB_cols

I_SUB_ToT0TB <- data.frame(matrix(ncol = length(I_SUB_ToT0TB_cols), nrow = length(I_Groups$`GIC Code`)))
colnames(I_SUB_ToT0TB) <- I_SUB_ToT0TB_cols

I_EQ_Calc <- data.frame(matrix(ncol = length(I_EQ_Calc_cols), nrow = length(I_Groups$`GIC Code`)))
colnames(I_EQ_Calc) <- I_EQ_Calc_cols

I_SUB_Disc1 <- data.frame(matrix(ncol = length(I_SUB_Disc1_cols), nrow = length(I_IF_FCFs$`GIC Code`)))
colnames(I_SUB_Disc1) <- I_SUB_Disc1_cols

I_SUB_Disc2 <- data.frame(matrix(ncol = length(I_SUB_Disc2_cols), nrow = length(I_IF_Patterns$`Reporting Date`)))
colnames(I_SUB_Disc2) <- I_SUB_Disc2_cols

I_SUB_Calc <- data.frame(matrix(ncol = length(I_SUB_Calc_cols), nrow = length(I_Groups$`GIC Code`)))
colnames(I_SUB_Calc) <- I_SUB_Calc_cols

I_FX <- data.frame(matrix(ncol = length(I_FX_cols), nrow = length(I_SUB_Calc$`GIC Code`)))
colnames(I_FX) <- I_FX_cols

I_SUB_ToSL <- data.frame(matrix(ncol = length(I_SUB_ToSL_cols), nrow = length(I_FX$`GIC Code`)))
colnames(I_SUB_ToSL) <- I_SUB_ToSL_cols

I_SUB_ToPRCF <- data.frame(matrix(ncol = length(I_SUB_ToPRCF_cols), nrow = length(I_FX$`GIC Code`)))
colnames(I_SUB_ToPRCF) <- I_SUB_ToPRCF_cols

I_SUB_ToCSM <- data.frame(matrix(ncol = length(I_SUB_ToCSM_cols), nrow = length(I_SUB_Calc$`GIC Code`)))
colnames(I_SUB_ToCSM) <- I_SUB_ToCSM_cols


#############################I_in_disc

library(dplyr)

 
I_IN_Disc$`Reporting Date` <- as.Date(NA)

# Loop through each index of I_IN_Disc
for(i in seq_along(I_IN_Disc$`Reporting Date`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Reporting Date`[i] <- as.Date(0)  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Reporting Date`[i] <- as.Date(I_NEW_CFs$`Reporting Date`[i])
  }
}

for(i in seq_along(I_IN_Disc$`GIC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`GIC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`GIC Code`[i] <- I_NEW_CFs$`GIC Code`[i]
  }
}


# Ensure Locked-in YC Date column exists and is initialized as NA
I_IN_Disc <- I_IN_Disc %>%
  mutate(I_IN_Disc$`Locked-in YC Date` <- case_when(
    `Scope_Ins_NUB` == "No" ~ as.Date(NA),  # Set to NA if Scope_Ins_NUB is "No"
    TRUE ~ as.Date(I_Groups$`Locked-in YC Date`[match(`GIC Code`, I_Groups$`GIC Code`)]))  # Match and assign Locked-in YC Date
  )

for(i in seq_along(I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)`[i] <- I_NEW_CFs$`Premium CFs (Unlinked)(Current Service)`[i]
  }
}


for(i in seq_along(I_IN_Disc$`Premium CFs (Unlinked)(Future Service)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Unlinked)(Future Service)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Premium CFs (Unlinked)(Future Service)`[i] <- I_NEW_CFs$`Premium CFs (Unlinked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)`[i] <- I_NEW_CFs$`Acquisition Expense CFs (Unlinked)(Current Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)`[i] <- I_NEW_CFs$`Acquisition Expense CFs (Unlinked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Investment Component CFs (Unlinked)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Investment Component CFs (Unlinked)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Investment Component CFs (Unlinked)`[i] <- I_NEW_CFs$`Investment Component CFs (Unlinked)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`[i] <- I_NEW_CFs$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`[i] <- I_NEW_CFs$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)`[i] <- I_NEW_CFs$`Premium CFs (Linked)(Current Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Premium CFs (Linked)(Future Service)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Linked)(Future Service)` <- 0
  } else {
    I_IN_Disc$`Premium CFs (Linked)(Future Service)`[i] <- I_NEW_CFs$`Premium CFs (Linked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)`[i] <- I_NEW_CFs$`Acquisition Expense CFs (Linked)(Current Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)` <- 0
  } else {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)`[i] <- I_NEW_CFs$`Acquisition Expense CFs (Linked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Investment Component CFs (Linked)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Investment Component CFs (Linked)` <- 0
  } else {
    I_IN_Disc$`Investment Component CFs (Linked)`[i] <- I_NEW_CFs$`Investment Component CFs (Linked)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`[i] <- I_NEW_CFs$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)` <- 0
  } else {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`[i] <- I_NEW_CFs$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Delay (in Years)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Delay (in Years)` <- 0
  } else {
    I_IN_Disc$`Delay (in Years)`[i] <- I_NEW_CFs$`Delay (in Years)`[i]
  }
}


# Create Lookup_Key in I_IN_Disc
I_IN_Disc <- I_IN_Disc %>%
  mutate(
    Lookup_Key = paste0(I_IN_Disc$`Locked-in YC Date`,
      `Currency`,
      "Unlinked",
      ifelse(Option_GranularYC == "Yes", 
             paste("Remaining Coverage", GIC_Code, sep="_"), 
             ""),
      sep="_"
    )
  )



library(dplyr)
library(tidyr)

# Step 1: Ensure Lookup_Key and delay_months are created correctly in I_IN_Disc
I_IN_Disc <- I_IN_Disc %>%
  rowwise() %>%
  mutate(
    Lookup_Key = paste0(
      `Locked-in YC Date`, "_", Currency, "_Unlinked",
      if_else(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GIC Code`), "")
    ),
    delay_months = round(`Delay (in Years)` * 12, 0)-1  # Convert delay years to months
  ) %>%
  ungroup()

# Step 2: Expand YieldCurves to 1800 rows
expanded_YieldCurves <- YieldCurves %>%
  slice(rep(1:n(), length.out = 1800))  # Repeat rows to match 1800
expanded_YieldCurves <- expanded_YieldCurves %>%
  slice(1:1800)
# Step 3: Convert delay_months columns into a single column
delay_cols <- grep("^\\d+$", colnames(expanded_YieldCurves), value = TRUE)

# Ensure delay columns exist before proceeding
if (length(delay_cols) == 0) {
  stop("Error: No delay_months columns found in `expanded_YieldCurves`.")
}

# Convert `expanded_YieldCurves` from wide format to long format
long_YieldCurves <- expanded_YieldCurves %>%
  pivot_longer(
    cols = all_of(delay_cols),  # Select all numerical delay month columns
    names_to = "delay_months",  # Store column names as delay_months values
    values_to = "spot_rate"  # Store values from columns
  ) %>%
  mutate(delay_months = as.numeric(delay_months),  Lookup_Key = paste0(
    `Date \\ Duration (Months)`, "_", Currency, "_Unlinked"
  ))  # Convert column names to numeric values

# Step 4: JOIN datasets to ensure correct matching instead of using filter()
matched_result <- long_YieldCurves %>%
  inner_join(I_IN_Disc, by = c("Lookup_Key", "delay_months"))

result <- matched_result %>%
  pull(spot_rate) %>%
  na.omit() %>%  # Remove NAs before taking the first value
  first() %>%
  replace_na(0)  # Default to 0 if empty




I_IN_Disc <- I_IN_Disc %>%
  mutate(
    `Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)` = 
      `Premium CFs (Unlinked)(Service in Current Reporting Period)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
      `Premium CFs (Linked)(Service in Current Reporting Period)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )
I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)` = 
    `Premium CFs (Unlinked)(Future Service)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Premium CFs (Linked)(Future Service)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Locked-in Date)` = 
    `Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Acquisition Expense CFs (Linked)(Service in Current Reporting Period)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, Locked-in Date)` = 
    `Acquisition Expense CFs (Unlinked)(Future Service)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Acquisition Expense CFs (Linked)(Future Service)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )
I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Investment Component CFs (Locked-in YC, Locked-in Date)` = 
    `Investment Component CFs (Unlinked)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Investment Component CFs (Linked)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Non-claim CFs (Locked-in YC, Locked-in Date)` = 
    `Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)` +
    `Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)` +
    `Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Locked-in Date)` +
    `Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, Locked-in Date)` +
    `Discounted Investment Component CFs (Locked-in YC, Locked-in Date)`
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)` = 
    `Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)` = 
    `Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)` * ((1 + `Spot Rate (Unlinked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`) +
    `Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)` * ((1 + `Spot Rate (Linked)(Locked-in Date, Delay)`) ^ -`Delay (in Years)`)
  )

I_IN_Disc <- I_IN_Disc %>%
  mutate(`Discounted Claim CFs (Locked-in YC, Locked-in Date)` = 
    `Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)` +
    `Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)`
  )

# Assuming I_IN_Disc is your data frame
# Ensure the date difference is converted to numeric before division
I_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)` <- 
  ifelse(
    Scope_Ins_NUB == "No", 
    0, 
    (I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)` *
       ((1 + I_IN_Disc$`Spot Rate (Unlinked)(Locked-in Date, Delay)`)^(-I_IN_Disc$`Delay (in Years)`)) *
       (1 + I_IN_Disc$`Spot Rate (Unlinked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])`))^
      pmin(I_IN_Disc$`Delay (in Years)`, 
           round(as.numeric(I_IN_Disc$`Reporting Date` - I_IN_Disc$`Locked-in YC Date`) / 365.25, 2))) +  
  
  (I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)` *
     ((1 + I_IN_Disc$`Spot Rate (Linked)(Locked-in Date, Delay)`)^(-I_IN_Disc$`Delay (in Years)`)) *
     (1 + I_IN_Disc$`Spot Rate (Unlinked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])`))^
  pmin(I_IN_Disc$`Delay (in Years)`, 
       round(as.numeric(I_IN_Disc$`Reporting Date` - I_IN_Disc$`Locked-in YC Date`) / 365.25, 2))




##########################################I_IN_Calc

for(i in seq_along(I_IN_Calc$`GIC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`GIC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Calc$`GIC Code`[i] <- I_NEW_GEN$`GIC Code`[i]
  }
}

for(i in seq_along(I_IN_Calc$`Issued/Acquired`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`Issued/Acquired` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Calc$`Issued/Acquired`[i] <- I_NEW_GEN$`Issued/Acquired`[i]
  }
}

for(i in seq_along(I_IN_Calc$`Pre-recognition CFs`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`Pre-recognition CFs` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in I_NEW_CFs
    I_IN_Calc$`Pre-recognition CFs`[i] <- I_NEW_GEN$`Pre-recognition CFs`[i]
  }
}

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Premium CFs (Current Service)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Premium CFs (Future Service)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Premium CFs` = `New LRC - Premium CFs (Current Service)` + `New LRC - Premium CFs (Future Service)`)


I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Acquisition Expense CFs (Future Service)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Acquisition Expense CFs (Future Service)(Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Acquisition Expense CFs (Current Service)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Acquisition Expense CFs` = `New LRC - Acquisition Expense CFs (Current Service)` + `New LRC - Acquisition Expense CFs (Future Service)`)

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Investment Component CFs` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Investment Component CFs (Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Claim and Other Expense CFs (Incurred in Current Reporting Period)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Claim and Other Expense CFs (Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)`)
  ))

I_IN_Calc <- I_IN_Calc %>%
  rowwise() %>%
  mutate(`New LRC - Claim and Other Expense CFs (Incurred in Future Reporting Periods)` = -sum(
    I_IN_Disc %>%
      filter(
        `Reporting Date` == ReportingDate_Current, 
        `GIC Code` == `GIC Code`
      ) %>%
      pull(`Discounted Claim and Other Expense CFs (Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)`)
  ))



I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Claim and Other Expense CFs` = `New LRC - Claim and Other Expense CFs (Incurred in Current Reporting Period)` + `New LRC - Claim and Other Expense CFs (Incurred in Future Reporting Periods)`)


I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Total Outflows` = `New LRC - Acquisition Expense CFs` + `New LRC - Investment Component CFs` + `New LRC - Claim and Other Expense CFs`)

I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - PVFCF` = `New LRC - Premium CFs` + `New LRC - Total Outflows`)

I_IN_Calc <- I_IN_Calc %>%
  mutate(`RA % of ABS(PVFCF Claims)` = if_else(
    Scope_Ins_NUB == "No", 
    0, 
    if_else(
      Option_RASimplification == "Yes", 
      sum(I_Groups %>%
            filter(`GIC Code` == `GIC Code`) %>%
            pull(`RA % of ABS(PVFCF)`)),
      0
    )
  ))

# First join I_NEW_GEN to I_IN_Calc based on the common key (e.g., GIC Code)
I_IN_Calc <- I_IN_Calc %>%
  left_join(I_NEW_GEN %>% select(`GIC Code`, `Initial RA`), by = "GIC Code") %>%
  mutate(
    `New LRC - RA` = if_else(
      Scope_Ins_NUB == "No", 
      0, 
      if_else(
        `RA % of ABS(PVFCF Claims)` == 0, 
        `Initial RA`,  # Use the newly joined column
        abs(`New LRC - Claim and Other Expense CFs`) * `RA % of ABS(PVFCF Claims)`
      )
    )
  )

I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - FCF` = `New LRC - PVFCF` + `New LRC - RA`)

I_IF_GEN_unique <- I_IF_GEN %>%
  distinct(`GIC Code`, `Opening LRC - Loss - PVFCF`, `Opening LRC - Loss - RA`)

# Perform the join and calculation
I_IN_Calc <- I_IN_Calc %>%
  left_join(
    I_IF_GEN_unique, 
    by = "GIC Code"
  ) %>%
  mutate(
    # Calculate the condition and populate the Non-onerous/Onerous column
    `Non-onerous/Onerous` = if_else(
      (`New LRC - FCF` - `Pre-recognition CFs` + 
       2 * `Opening LRC - Loss - PVFCF` + `Opening LRC - Loss - RA`) > 0, 
      "Onerous", 
      "Non-onerous"
    )
  )


I_IN_Calc <- I_IN_Calc %>%
  mutate(
    `New LRC - CSM` = if_else(
      `Non-onerous/Onerous` == "Onerous",
      -`Pre-recognition CFs`,
      -`New LRC - FCF`
    )
  )

I_IN_Calc <- I_IN_Calc %>%
  mutate(
    `New LRC - Loss - PVFCF` = if_else(
      `Non-onerous/Onerous` == "Non-onerous",
      0,
      (`New LRC - FCF` - `Pre-recognition CFs`) * 
      (`New LRC - Claim and Other Expense CFs` / 
      (`New LRC - Claim and Other Expense CFs` + `New LRC - RA`))
    )
  )

I_IN_Calc <- I_IN_Calc %>%
  mutate(
    `New LRC - Loss - RA` = if_else(
      `Non-onerous/Onerous` == "Non-onerous",
      0,
      (`New LRC - FCF` - `Pre-recognition CFs`) * 
      (`New LRC - RA` / 
      (`New LRC - Claim and Other Expense CFs` + `New LRC - RA`))
    )
  )

I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Profit - PVFCF (Claims)` = `New LRC - Claim and Other Expense CFs` - `New LRC - Loss - PVFCF`)


I_IN_Calc <- I_IN_Calc %>%
  mutate(`New LRC - Profit - RA` = `New LRC - RA` - `New LRC - Loss - RA`)

#####################################I_IN_Pre_FX

I_IN_Pre_FX$`GIC Code` <- I_IN_Calc$`GIC Code`

I_IN_Pre_FX <- I_IN_Pre_FX %>%
  mutate(
    `Transfer of Pre-recognition CFs (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & 
      I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`Pre-recognition CFs`,
      TRUE ~ 0
    )
  )

I_IN_Pre_FX <- I_IN_Pre_FX %>%
  mutate(
    `New LRC - Profit - Premium CFs (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & 
      I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - Premium CFs`,
      TRUE ~ 0
    )
  )


I_IN_Pre_FX <- I_IN_Pre_FX %>%
  mutate(
    `New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - Acquisition Expense CFs`,
      TRUE ~ 0
    ),
    `New LRC - Profit - Investment Component CFs (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - Investment Component CFs`,
      TRUE ~ 0
    ),
    `New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - Profit - PVFCF (Claims)`,
      TRUE ~ 0
    ),
    `New LRC - Profit - RA (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - Profit - RA`,
      TRUE ~ 0
    ),
    `New LRC - Profit - CSM (Issued, Non-onerous)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,
      I_IN_Calc$`Issued/Acquired` == "Issued" & I_IN_Calc$`Non-onerous/Onerous` == "Non-onerous" ~ I_IN_Calc$`New LRC - CSM`,
      TRUE ~ 0
    )
  )

#########################################################I_IN_ToSL

I_IN_ToSL$`GIC Code` <- I_IN_Calc$`GIC Code`

I_IN_ToSL <- I_IN_ToSL %>%
  left_join(
    I_FX %>%
      select(`GIC Code`, `Transfer of Pre-recognition CFs (Issued, Non-onerous)(2) - Actuals FX`), # Select relevant columns
    by = "GIC Code" # Ensure this is the correct join column
  ) %>%
  mutate(
    # Replace NA values with 0 in the new column (if it's missing or NA)
    I_IN_ToSL$I_IN_ToSL$`Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX` <- coalesce(
      I_IN_ToSL$I_IN_ToSL$`Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX`, 0
    )
  )

header_name <- "Transfer of Pre-recognition CFs (Issued, Non-onerous)(2) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Issued, Non-onerous)(2) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    I_IN_ToSL$`Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX` <- 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Premium CFs (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Premium CFs (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous) - Actuals FX"

lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Acquisition Expense CFs (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Investment Component CFs (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Investment Component CFs (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Claim and Other Expense CFs (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - RA (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - RA (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - CSM (Issued, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - CSM (Issued, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Issued, Onerous)(2) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Issued, Onerous)(2) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Premium CFs (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Premium CFs (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )


header_name <- "New LRC - Profit - Acquisition Expense CFs (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Acquisition Expense CFs (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Investment Component CFs (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Investment Component CFs (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Claim and Other Expense CFs (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Claim and Other Expense CFs (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - RA (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - RA (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - CSM (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - CSM (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Loss - PVFCF (Issued, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Acquired, Non-onerous)(2) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Acquired, Non-onerous)(2) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Premium CFs (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Premium CFs (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Acquisition Expense CFs (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Acquisition Expense CFs (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Investment Component CFs (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Investment Component CFs (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Claim and Other Expense CFs (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Claim and Other Expense CFs (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - RA (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - RA (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - CSM (Acquired, Non-onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - CSM (Acquired, Non-onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "Transfer of Pre-recognition CFs (Acquired, Onerous)(2) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `Transfer of Pre-recognition CFs (Acquired, Onerous)(2) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Premium CFs (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Premium CFs (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Acquisition Expense CFs (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Acquisition Expense CFs (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )


header_name <- "New LRC - Profit - Investment Component CFs (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Investment Component CFs (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - Claim and Other Expense CFs (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - Claim and Other Expense CFs (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - RA (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - RA (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Profit - CSM (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Profit - CSM (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Loss - PVFCF (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Loss - PVFCF (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Loss - RA (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Loss - RA (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

header_name <- "New LRC - Loss - RA (Acquired, Onerous) - Actuals FX"
lookup_column <- which(names(I_FX) == header_name)

# Populate the column in I_IN_ToSL
I_IN_ToSL <- I_IN_ToSL %>%
  mutate(
    `New LRC - Loss - RA (Acquired, Onerous) - Actuals FX` = 
      ifelse(
        !is.na(match(`GIC Code`, I_FX[[1]])), # Match based on the first column of I_FX
        I_FX[[lookup_column]][match(`GIC Code`, I_FX[[1]])], 
        0
      )
  )

###########################################################I_EQ_Calc



    # Loop through each index of I_IN_Disc
    for(i in seq_along(I_EQ_Calc$`GIC Code`)) {
    # Check the value of Scope_Ins_NUB and assign accordingly
    if(Scope_Ins_NUB == 'No') {
        I_EQ_Calc$`GIC Code`[i] <- as.Date(0)  # or you can use NA
    } else {
        # Ensure you are accessing the correct row in I_NEW_CFs
        I_EQ_Calc$`GIC Code`[i] <- (I_Groups$`GIC Code`[i])
    }
    }



I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Reporting Segment` = ifelse(Scope_Insurance == "No", 0, 
                                    I_Groups %>%
                                    filter(`GIC Code` == I_EQ_Calc$`GIC Code`) %>%
                                    pull(`Reporting Segment`)))



I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Opening Insurance Finance Reserve` = ifelse(Scope_Insurance == "No", 0,
                                                    I_Equity %>%
                                                      filter(`GIC Code` == `GIC Code`) %>%
                                                      summarise(sum_value = sum(`Opening Insurance Finance Reserve`, na.rm = TRUE)) %>%
                                                      pull(sum_value)))



# Update the Income/(Expense) disclosed in OCI column
library(readxl)
Outputs_SL <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Subledger")

I_EQ_Calc <- I_EQ_Calc %>%
  rowwise() %>%  # Ensure the operation is performed row by row
  mutate(`Income/(Expense) disclosed in OCI` = ifelse(Scope_Insurance == "No", 0,
                                                      -(
                                                        sum(Outputs_SL %>%
                                                              filter(`Group Code` == `GIC Code` & `DR Account Code` == 2312000) %>%
                                                              pull(Amount), na.rm = TRUE) +
                                                        sum(Outputs_SL %>%
                                                              filter(`Group Code` == `GIC Code` & `DR Account Code` == 2322000) %>%
                                                              pull(Amount), na.rm = TRUE) +
                                                        sum(Outputs_SL %>%
                                                              filter(`Group Code` == `GIC Code` & `DR Account Code` == 2332000) %>%
                                                              pull(Amount), na.rm = TRUE)
                                                      )))

I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Closing Insurance Finance Reserve` = `Opening Insurance Finance Reserve` + `Income/(Expense) disclosed in OCI`) 

I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Opening Retained Earnings` = ifelse(Scope_Insurance == "No", 0,
                                                    I_Equity %>%
                                                      filter(`GIC Code` == `GIC Code`) %>%
                                                      summarise(sum_value = sum(`Opening Retained Earnings`, na.rm = TRUE)) %>%
                                                      pull(sum_value)))

I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Closing Retained Earnings` = `Opening Retained Earnings` + `Income/(Expense) disclosed in P&L`) 

################################################################I_SUB_Disc1
I_SUB_Disc1$`Reporting Date` <- I_IF_FCFs$`Reporting Date`

I_SUB_Disc1$`GIC Code` <- I_IF_FCFs$`GIC Code`

# Step 1: Deduplicate I_Groups if necessary
I_Groups_unique <- I_Groups %>%
  group_by(`GIC Code`) %>%
  summarise(`Locked-in YC Date` = first(`Locked-in YC Date`), .groups = "drop")

# Step 2: Perform the left join correctly
I_SUB_Disc1 <- I_SUB_Disc1 %>%
  left_join(I_Groups_unique, by = "GIC Code") %>%
  mutate(
    `Locked-in YC Date` = coalesce(I_SUB_Disc1$`Locked-in YC Date`, as.Date("2000-01-01"))  # Replace NA with default date
  )


#######################################################I_SUB_Disc2
I_SUB_Disc2$`Reporting Date` <- I_IF_Patterns$`Reporting Date`
I_SUB_Disc2$`GIC Code` <- I_IF_Patterns$`GIC Code`

# Perform left join to populate 'Locked-in YC Date' from 'I_Groups' into 'I_SUB_Disc2'
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  left_join(I_Groups %>% select(`GIC Code`, `Locked-in YC Date`), by = "GIC Code") %>%
  mutate(`Locked-in YC Date` = coalesce(`Locked-in YC Date.x`, `Locked-in YC Date.y`)) %>%
  select(-`Locked-in YC Date.x`, -`Locked-in YC Date.y`)

# Dynamically find the column index for "Currency" in the I_Groups data frame
currency_col_index <- which(colnames(I_Groups) == "Currency")

# Perform the join using GIC Code and Currency column
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  # Join I_SUB_Disc2 with I_Groups on 'GIC Code'
  left_join(I_Groups %>% select(`GIC Code`, `Currency`), by = "GIC Code") %>%
  # Populate 'Currency' in I_SUB_Disc2 with the values from I_Groups
  mutate(Currency = coalesce(Currency.x, Currency.y)) %>%
  # Drop the extra columns that were created during the join
  select(-Currency.x, -Currency.y)



# Expand I_IF_Patterns to match 11,400 rows
expanded_I_IF_Patterns <- I_IF_Patterns %>%
  slice(rep(1:n(), length.out = 11400))  # Repeat rows to match 11400
I_SUB_Disc2$`Amortisation Pattern (Undiscounted)` <- expanded_I_IF_Patterns$`Amortisation Pattern (Undiscounted)`
I_SUB_Disc2$`Reporting Period (0 = current)` <- expanded_I_IF_Patterns$`Reporting Period (0 = current)`

I_SUB_Disc2$`Coverage Units (Undiscounted)` <- expanded_I_IF_Patterns$`Coverage Units (Undiscounted)`
# 1. Start by creating a helper column in I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
I_Groups <- I_Groups %>%
  mutate(YC_key = case_when(
    Scope_LinkedCashflows == "No" ~ "Unlinked",
    TRUE ~ as.character(`YC to discount Coverage Units and Amortisation Pattern`)
  ))

# 2. Create a function to calculate the spot rate for each row in I_SUB_Disc2
calculate_spot_rate <- function(Locked_in_YC_Date, Currency, GIC_Code, `Reporting Date`, Reporting_Period, Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC) {
  
  # Check the condition if Option_DiscountCUs and Option_DiscountAmortPattern are both "No"
  if (Option_DiscountCUs == "No" & Option_DiscountAmortPattern == "No") {
    return(0)
  }
  
  # Generate key for YieldCurves based on the logic
  scope_linked_value <- I_Groups %>%
    filter(`GIC Code` == GIC_Code) %>%
    pull(YC_key)
  
  yc_key <- paste0(Locked_in_YC_Date, "_", Currency, "_", scope_linked_value)
  
  if (Option_GranularYC == "Yes") {
    yc_key <- paste0(yc_key, "_Remaining Coverage_", GIC_Code)
  }
  
  # Calculate time difference for MATCH equivalent
  time_diff_years <- as.numeric((as.Date(`Reporting Date`) - as.Date(Locked_in_YC_Date)) / 365.25) + 
    (Reporting_Period * (ReportingDate_Current - ReportingDate_Previous) / 365.25)
  
  time_diff_months <- ceiling(trunc(time_diff_years * 12, 2)) # Round up to match Excel's ROUNDUP(TRUNC(...))
  
  # Fetch spot rate from YieldCurves based on yc_key and time_diff_months
  spot_rate <- YieldCurves %>%
    filter(Key == yc_key) %>%
    select(starts_with(as.character(time_diff_months))) %>%
    pull()
  
  return(spot_rate)
}

# 3. Apply the function row by row to populate the Spot Rate column
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  rowwise() %>%
  mutate(`Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date) + # Reporting Periods * Reporting Period)` = 
           calculate_spot_rate(`Locked-in YC Date`, Currency, `GIC Code`, `Reporting Date`, `Reporting Period (0 = current)`,
                               Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC))



# 1. Prepare helper column in I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
I_Groups <- I_Groups %>%
  mutate(YC_key = case_when(
    Scope_LinkedCashflows == "No" ~ "Unlinked",
    TRUE ~ as.character(`YC to discount Coverage Units and Amortisation Pattern`)
  ))

# 2. Function to calculate the Spot Rate based on the formula
calculate_spot_rate_locked_in <- function(Locked_in_YC_Date, Currency, GIC_Code, `Reporting Date`, Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC) {
  
  # Check condition if Option_DiscountCUs and Option_DiscountAmortPattern are both "No"
  if (Option_DiscountCUs == "No" & Option_DiscountAmortPattern == "No") {
    return(0)
  }
  
  # Generate key for YieldCurves based on Locked-in YC Date, Currency, and Scope_LinkedCashflows condition
  scope_linked_value <- I_Groups %>%
    filter(`GIC Code` == GIC_Code) %>%
    pull(YC_key)
  
  yc_key <- paste0(Locked_in_YC_Date, "_", Currency, "_", scope_linked_value)
  
  # Add extra components if Option_GranularYC is "Yes"
  if (Option_GranularYC == "Yes") {
    yc_key <- paste0(yc_key, "_Remaining Coverage_", GIC_Code)
  }
  
  # Calculate the time difference (years) between Reporting Date and Locked-in YC Date
  time_diff_years <- as.numeric((as.Date(`Reporting Date`) - as.Date(Locked_in_YC_Date)) / 365.25)
  
  # Convert time difference to months, rounding up and truncating
  time_diff_months <- ceiling(trunc(time_diff_years * 12, 2)) # Equivalent to ROUNDUP(TRUNC(...))

  # Fetch the corresponding spot rate from YieldCurves based on yc_key and time_diff_months
  spot_rate <- YieldCurves %>%
    filter(Key == yc_key) %>%
    select(starts_with(as.character(time_diff_months))) %>%
    pull()
  
  return(spot_rate)
}

# 3. Apply the function to I_SUB_Disc2 to populate the column Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date))
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  rowwise() %>%
  mutate(`Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date))` = 
           calculate_spot_rate_locked_in(`Locked-in YC Date`, Currency, `GIC Code`, `Reporting Date`,
                                         Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC))



# 1. Prepare helper column in I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
I_Groups <- I_Groups %>%
  mutate(YC_key = case_when(
    Scope_LinkedCashflows == "No" ~ "Unlinked",
    TRUE ~ as.character(`YC to discount Coverage Units and Amortisation Pattern`)
  ))

# 2. Function to calculate the Spot Rate based on the formula
calculate_spot_rate_current <- function(ReportingDate_Current, Currency, GIC_Code, Reporting_Period, Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC) {
  
  # Check condition if Option_DiscountCUs and Option_DiscountAmortPattern are both "No"
  if (Option_DiscountCUs == "No" & Option_DiscountAmortPattern == "No") {
    return(0)
  }
  
  # Generate key for YieldCurves based on ReportingDate_Current, Currency, and Scope_LinkedCashflows condition
  scope_linked_value <- I_Groups %>%
    filter(`GIC Code` == GIC_Code) %>%
    pull(YC_key)
  
  yc_key <- paste0(ReportingDate_Current, "_", Currency, "_", scope_linked_value)
  
  # Add extra components if Option_GranularYC is "Yes"
  if (Option_GranularYC == "Yes") {
    yc_key <- paste0(yc_key, "_Remaining Coverage_", GIC_Code)
  }
  
  # Calculate the truncated and rounded-up Reporting Period in months
  reporting_period_months <- ceiling(trunc(Reporting_Period, 2) * 12) # Equivalent to ROUNDUP(TRUNC(...))

  # Fetch the corresponding spot rate from YieldCurves based on yc_key and reporting_period_months
  spot_rate <- YieldCurves %>%
    filter(Key == yc_key) %>%
    select(starts_with(as.character(reporting_period_months))) %>%
    pull()
  
  return(spot_rate)
}

# 3. Apply the function to I_SUB_Disc2 to populate the column Spot Rate (Current Reporting Date, Reporting period)
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  rowwise() %>%
  mutate(`Spot Rate (Current Reporting Date, Reporting period)` = 
           calculate_spot_rate_current(ReportingDate_Current, Currency, `GIC Code`, `Reporting Period (0 = current)`,
                                        Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC))




#########################################################################I_SUB_Calc

I_SUB_Calc$`GIC Code` <- I_Groups$`GIC Code`

# Assuming B$1 corresponds to the column name you want to match
column_name <- "Currency"  # Replace with the actual column name from I_Groups

# Populate Currency in I_SUB_Calc based on GIC Code
I_SUB_Calc <- I_SUB_Calc %>%
  mutate(Currency = I_Groups[match(`GIC Code`, I_Groups$`GIC Code`), match(column_name, names(I_Groups))])

I_SUB_Calc$`Locked-in YC Date` <- I_Groups$`Locked-in YC Date`


I_SUB_Calc <- I_SUB_Calc %>%
  mutate(`RA % of ABS(PVFCF Claims)` = ifelse(
    Option_RASimplification == "Yes",
    (I_Groups$`RA % of ABS(PVFCF)`[I_Groups$`GIC Code` == `GIC Code`]),
    0
  ))

I_SUB_Calc <- I_SUB_Calc %>%
  mutate(`Opening LRC - PVFCF (Non-claims)` = -sum(
    I_SUB_Disc1$`Discounted Non-claim CFs (Prev YC, t0)`[
      I_SUB_Disc1$`Reporting Date` == ReportingDate_Previous & 
      I_SUB_Disc1$`GIC Code` == `GIC Code`
    ],
    na.rm = TRUE  # To handle any NA values
  ))



I_SUB_Calc <- I_SUB_Calc %>%
  rowwise() %>%
  mutate(`Opening LRC - PVFCF (Non-claims) - Post Roll Forward (Prev YC)` = 
           sum(I_SUB_Disc1 %>%
                 filter(`Reporting Date` == ReportingDate_Previous,
                        `GIC Code` == `GIC Code`) %>%
                 pull(`Discounted Non-claim CFs (Prev YC, t1)`)
          )) %>%
  ungroup()


I_SUB_Calc <- I_SUB_Calc %>%
  rowwise() %>%
  mutate(`Opening LRC - PVFCF (Non-claims)(Locked-in YC)` = 
           sum(I_SUB_Disc1 %>%
                 filter(`Reporting Date` == ReportingDate_Previous,
                        `GIC Code` == `GIC Code`) %>%
                 pull(`Discounted Non-claim CFs (Locked-in YC, t0)`)
          )) %>%
  ungroup()

library(dplyr)

# Assuming 'Discounted Non-claim CFs (Locked-in YC, t1)' is the column you're summing
# 'Reporting Date' is the date column to match with 'ReportingDate_Previous'
# 'GIC Code' is the common column between I_SUB_Disc and I_SUB_Disc1

# Perform the SUMIFS-like operation
I_SUB_Calc <- I_SUB_Calc %>%
  rowwise() %>%
  mutate(`Opening LRC - PVFCF (Non-claims) - Post Roll Forward (LIYC)` = 
           sum(I_SUB_Disc1 %>%
                 filter(`Reporting Date` == ReportingDate_Previous,
                        `GIC Code` == `GIC Code`) %>%
                 pull(`Discounted Non-claim CFs (Locked-in YC, t1)`)
          )) %>%
  ungroup()

library(dplyr)

# Assuming the columns are correctly named and exist in the I_SUB_Calc data frame:
I_SUB_Calc <- I_SUB_Calc %>%
  mutate(`Effect on Opening LRC - PVFCF (Non-claims) of Changes in Interest Rates (1/2)` = 
           `Opening LRC - PVFCF (Non-claims) - Post Roll Forward (LIYC)` - 
           `Opening LRC - PVFCF (Non-claims) - Post Roll Forward (Prev YC)`)

I_SUB_Calc <- I_SUB_Calc %>%
  mutate(`Interest Accreted on Opening LRC - PVFCF (Non-claims)` = 
           `Opening LRC - PVFCF (Non-claims) - Post Roll Forward (Prev YC)` - 
           `Opening LRC - PVFCF (Non-claims)`)


library(dplyr)

# Assuming the columns are correctly named and exist in the I_SUB_Calc and I_IN_Disc data frames:
I_SUB_Calc <- I_SUB_Calc %>%
  
  # Populate the "New LRC - PVFCF (Non-claims)" column
  mutate(`New LRC - PVFCF (Non-claims)` = 
           -sapply(`GIC Code`, function(gic) {
             sum(I_IN_Disc$`Discounted Non-claim CFs (Locked-in YC, Locked-in Date)`[
               I_IN_Disc$`Reporting Date` == ReportingDate_Current &
                 I_IN_Disc$`GIC Code` == gic
             ])
           })) %>%
  
  # Populate the "New LRC - PVFCF (Non-claims) - Post Roll Forward" column
  mutate(`New LRC - PVFCF (Non-claims) - Post Roll Forward` = 
           -sapply(`GIC Code`, function(gic) {
             sum(I_IN_Disc$`Discounted Non-claim CFs (Locked-in YC, Reporting Date)`[
               I_IN_Disc$`Reporting Date` == ReportingDate_Current &
                 I_IN_Disc$`GIC Code` == gic
             ])
           })) %>%
  
  # Populate the "Interest Accreted on New LRC - PVFCF (Non-claims)" column
  mutate(`Interest Accreted on New LRC - PVFCF (Non-claims)` = 
           `New LRC - PVFCF (Non-claims) - Post Roll Forward` - 
           `New LRC - PVFCF (Non-claims)`) %>%
  
  # Populate the "LRC - PVFCF (Non-claims) - Post Roll Forward" column
  mutate(`LRC - PVFCF (Non-claims) - Post Roll Forward` = 
           `Opening LRC - PVFCF (Non-claims) - Post Roll Forward (LIYC)` + 
           `New LRC - PVFCF (Non-claims) - Post Roll Forward` + 
           `Actual less Expected Return on LRC IC`)



I_SUB_Calc <- I_SUB_Calc %>%
  
  # Populate "Actual less Expected Return on LRC IC"
  mutate(`Actual less Expected Return on LRC IC` = 
           I_IF_GEN$`Actual less Expected Return on LRC IC`[match(`GIC Code`, I_IF_GEN$`GIC Code`)]
         ) %>%
  
  # Populate "Interest Accreted on LRC - PVFCF (Non-claims)"
  mutate(`Interest Accreted on LRC - PVFCF (Non-claims)` = 
           `Interest Accreted on Opening LRC - PVFCF (Non-claims)` + 
           `Interest Accreted on New LRC - PVFCF (Non-claims)` + 
           `Actual less Expected Return on LRC IC`
         ) %>%
  
  # Populate "Expected Premium (Past/Current)(Opening)"
  mutate(`Expected Premium (Past/Current)(Opening)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_SUB_Disc1$`Discounted Premium CFs (Past Service)(Locked-in YC, t1)`[
               I_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
                 I_SUB_Disc1$`GIC Code` == gic
             ]) +
               sum(I_SUB_Disc1$`Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t1)`[
                 I_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
                   I_SUB_Disc1$`GIC Code` == gic
               ])
           })
         ) %>%
  
  # Populate "Expected Premium (Past/Current)(New)"
  mutate(`Expected Premium (Past/Current)(New)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)`[
               I_IN_Disc$`Reporting Date` == ReportingDate_Current &
                 I_IN_Disc$`GIC Code` == gic
             ])
           })
         ) %>%
  
  # Populate "Premium Receipts (Past/Current)"
  mutate(`Premium Receipts (Past/Current)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_IF_GEN$`Premium Receipts (Past/Current Service)`[
               I_IF_GEN$`Reporting Date` == ReportingDate_Current &
                 I_IF_GEN$`GIC Code` == gic
             ])
           })
         ) %>%
  
  # Populate "Expected Premium (Past/Current)(Closing)"
  mutate(`Expected Premium (Past/Current)(Closing)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_SUB_Disc1$`Discounted Premium CFs (Past Service)(Locked-in YC, t0)`[
               I_SUB_Disc1$`Reporting Date` == ReportingDate_Current &
                 I_SUB_Disc1$`GIC Code` == gic
             ])
           })
         ) %>%
  
  # Populate "Premium Experience Variance (Past/Current)"
  mutate(`Premium Experience Variance (Past/Current)` = 
           -((`Premium Receipts (Past/Current)` + 
             `Expected Premium (Past/Current)(Closing)`) - 
             (`Expected Premium (Past/Current)(Opening)` + 
             `Expected Premium (Past/Current)(New)`))
         ) %>%
  
  # Populate "LRC - PVFCF (Non-claims) - Post Premium Experience Variances (Past/Current)"
  mutate(`LRC - PVFCF (Non-claims) - Post Premium Experience Variances (Past/Current)` = 
           `LRC - PVFCF (Non-claims) - Post Roll Forward` + 
           `Premium Experience Variance (Past/Current)`
         ) %>%
  
  # Populate "Expected Acquisition Expense (Past/Current)(Opening)"
  mutate(`Expected Acquisition Expense (Past/Current)(Opening)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_SUB_Disc1$`Discounted Acquisition Expense CFs (Past Service)(Locked-in YC, t1)`[
               I_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
                 I_SUB_Disc1$`GIC Code` == gic
             ]) +
               sum(I_SUB_Disc1$`Discounted Acquisition Expense CFs (Service in Next Reporting Period)(Locked-in YC, t1)`[
                 I_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
                   I_SUB_Disc1$`GIC Code` == gic
               ])
           })
         ) %>%
  
  # Populate "Expected Acquisition Expense (Past/Current)(New)"
  mutate(`Expected Acquisition Expense (Past/Current)(New)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_IN_Disc$`Discounted Acquisition Expense CFs (Current Service)(Locked-in YC, Reporting Date)`[
               I_IN_Disc$`Reporting Date` == ReportingDate_Current &
                 I_IN_Disc$`GIC Code` == gic
             ])
           })
         ) %>%
  
  # Populate "Acquisition Expense Payments (Past/Current)"
  mutate(`Acquisition Expense Payments (Past/Current)` = 
           sapply(`GIC Code`, function(gic) {
             sum(I_IF_GEN$`Acquisition Expense Payments (Past/Current Service)`[
               I_IF_GEN$`Reporting Date` == ReportingDate_Current &
                 I_IF_GEN$`GIC Code` == gic
])
           })
         )





#########################################################I_FX
I_FX$`GIC Code` <- I_SUB_Calc$`GIC Code`



################################I_SUB_ToSL
I_SUB_ToSL$`GIC Code` <- I_FX$`GIC Code`

# Assuming 'B$1' corresponds to a specific column header (you can assign it to a variable in R)
lookup_column <- "Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX"  # Replace with the actual header name in Workings_I_FX

# Find the column index in 'Workings_I_FX' that matches the header name
column_index <- match(lookup_column, colnames(I_FX))

# Now populate the 'Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX' column in 'I_SUB_ToSL'
I_SUB_ToSL <- I_SUB_ToSL %>%
  rowwise() %>%  # Ensure row-wise operation
  mutate(
    `Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX` = {
      # Extract the GIC code for the current row
      gic_code <- `GIC Code`  
      
      # Perform the lookup in 'I_FX' using the GIC code
      matching_value <- I_FX %>%
        filter(`GIC Code` == gic_code) %>%
        pull(column_index)  # Ensure 'column_index' is the correct column name
      
      # Ensure the correct value is returned
      if (length(matching_value) == 0) {
        NA  # Return NA if no match is found
      } else {
        matching_value
      }
    }
  ) %>%
  ungroup()  # Remove row-wise grouping





####################################################################I_SUB_ToCSM

I_SUB_ToCSM$`GIC Code` <- I_SUB_Calc$`GIC Code`

# Assume Workings_I_FX, Workings_I_SUB_Disc2, and I_SUB_ToCSM data frames are already loaded
# You also need to define `ReportingDate_Current` and `B$1` manually in R

# Extract the part of `B$1` needed for MID(B$1,38,3)
reporting_period <- as.numeric(substr("LRC - CSM Release - Reporting Period 1", 38, 40))  # Replace "YourB1Value" with the actual value of B$1 in R

# Assuming 'ReportingDate_Current' is a date value that you have already loaded into R
ReportingDate_Current <- as.Date(ReportingDate_Current)  # Replace "YourDateValue" with the actual date

# Create the new column 'LRC - CSM Release - Reporting Period 1' in the I_SUB_ToCSM dataframe
I_SUB_ToCSM <- I_SUB_ToCSM %>%
  rowwise() %>%
  mutate(
    `LRC - CSM Release - Reporting Period 1` = {
      # Extract GIC Code for the current row
      gic_code <- `GIC Code`
      
      # Calculate the sum of Discounted Coverage Units (Locked-in YC, t0)
      discounted_coverage_units <- I_SUB_Disc2 %>%
        filter(
          `Reporting Date` == ReportingDate_Current,
          `GIC Code` == gic_code,
          `Reporting Period (0 = current)` > 0
        ) %>%
        summarize(sums = sum(`Discounted Coverage Units (Locked-in YC, t0)`, na.rm = TRUE)) %>%
        pull(sums)
      
      # If discounted_coverage_units is empty, set to 0
      discounted_coverage_units <- ifelse(length(discounted_coverage_units) == 0, 0, discounted_coverage_units)
      
      # Use ifelse() to check if discounted_coverage_units is 0
      ifelse(
        discounted_coverage_units == 0, 
        0,  # Return 0 if sum is 0
        {
          # Perform the full formula calculation
          closing_lrc_csm <- I_FX %>%
            filter(`GIC Code` == gic_code) %>%
            pull(`Closing LRC - CSM - Current FX`)
          
          # Calculate the numerator
          numerator <- I_SUB_Disc2 %>%
            filter(
              `Reporting Date` == ReportingDate_Current,
              `GIC Code` == gic_code,
              `Reporting Period (0 = current)` == reporting_period
            ) %>%
            summarize(numerator_value = sum(`Discounted Coverage Units (Locked-in YC, t0)`, na.rm = TRUE)) %>%
            pull(numerator_value)
          
          # Calculate the final result
          result <- closing_lrc_csm * (numerator / discounted_coverage_units)
          
          # Return the result
          result
        }
      )
    }
  ) %>%
  ungroup()








##############################################################################I_SUB_ToT1TB
I_SUB_ToT1TB$`GIC Code` <- I_Groups$`GIC Code`
I_SUB_ToT1TB$`Portfolio` <- I_Groups$`Portfolio`





#####################################################################Create data drames
R_Groups <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_Groups")
R_I_IN_Disc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_I_IN_Disc")
R_IN_Disc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_Disc")
R_FX <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_FX")
R_IF_FCFs <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IF_FCFs")
R_SUB_ToSL <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_ToSL")
R_SUB_ToT0TB <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_ToT0TB")
R_SUB_ToT1TB <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_ToT1TB")
R_SUB_LR <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_LR")
R_SUB_ToCSM <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_ToCSM")
R_SUB_Disc2 <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_Disc2")
R_I_IN_Disc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_I_IN_Disc")
R_IN_Disc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_Disc")
R_IN_LR <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_LR")
R_IN_Calc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_Calc")
R_IN_Pre_FX <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_Pre_FX")
R_IN_ToSL <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IN_ToSL")
R_I_Mapping <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_I_Mapping")
R_IF_Patterns <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IF_Patterns")
R_NEW_CFs <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_NEW_CFs")
R_NEW_GEN <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_NEW_GEN")
R_IF_GEN_LR <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IF_GEN_LR")
R_IF_GEN <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_IF_GEN")
R_SUB_Calc <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_Calc")
R_SUB_Disc1 <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_SUB_Disc1")

# Ensure column names are saved before creating the empty matrices
R_EQ_Calc_colnames <- colnames(R_EQ_Calc)
R_I_SUB_Disc1_colnames <- colnames(R_I_SUB_Disc1)
R_SUB_Disc1_colnames <- colnames(R_SUB_Disc1)
R_SUB_Calc_colnames <- colnames(R_SUB_Calc)
R_FX_colnames <- colnames(R_FX)
R_SUB_ToSL_colnames <- colnames(R_SUB_ToSL)
R_SUB_ToT0TB_colnames <- colnames(R_SUB_ToT0TB)
R_SUB_ToT1TB_colnames <- colnames(R_SUB_ToT1TB)
R_SUB_ToCSM_colnames <- colnames(R_SUB_ToCSM)
R_SUB_Disc2_colnames <- colnames(R_SUB_Disc2)
R_I_IN_Disc_colnames <- colnames(R_I_IN_Disc)
R_IN_Disc_colnames <- colnames(R_IN_Disc)
R_IN_LR_colnames <- colnames(R_IN_LR)
R_IN_Calc_colnames <- colnames(R_IN_Calc)
R_IN_Pre_FX_colnames <- colnames(R_IN_Pre_FX)
R_IN_ToSL_colnames <- colnames(R_IN_ToSL)

# Now create empty data frames with the right column names
R_EQ_Calc <- data.frame(matrix(ncol = length(R_EQ_Calc_colnames), 
                               nrow = length(R_Groups$`GRC Code`)))
colnames(R_EQ_Calc) <- R_EQ_Calc_colnames

R_I_SUB_Disc1 <- data.frame(matrix(ncol = length(R_I_SUB_Disc1_colnames), 
                                   nrow = length(I_IF_FCFs$`Reporting Date`)))
colnames(R_I_SUB_Disc1) <- R_I_SUB_Disc1_colnames

R_SUB_Disc1 <- data.frame(matrix(ncol = length(R_SUB_Disc1_colnames), 
                                 nrow = length(R_IF_FCFs$`Reporting Date`)))
colnames(R_SUB_Disc1) <- R_SUB_Disc1_colnames

R_SUB_Calc <- data.frame(matrix(ncol = length(R_SUB_Calc_colnames), 
                                nrow = length(R_Groups$`GRC Code`)))
colnames(R_SUB_Calc) <- R_SUB_Calc_colnames

R_FX <- data.frame(matrix(ncol = length(R_FX_colnames), 
                          nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_FX) <- R_FX_colnames

R_SUB_ToSL <- data.frame(matrix(ncol = length(R_SUB_ToSL_colnames), 
                                nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_SUB_ToSL) <- R_SUB_ToSL_colnames

R_SUB_ToT0TB <- data.frame(matrix(ncol = length(R_SUB_ToT0TB_colnames), 
                                  nrow = length(R_Groups$`GRC Code`)))
colnames(R_SUB_ToT0TB) <- R_SUB_ToT0TB_colnames

R_SUB_ToT1TB <- data.frame(matrix(ncol = length(R_SUB_ToT1TB_colnames), 
                                  nrow = length(R_Groups$`GRC Code`)))
colnames(R_SUB_ToT1TB) <- R_SUB_ToT1TB_colnames

R_SUB_ToCSM <- data.frame(matrix(ncol = length(R_SUB_ToCSM_colnames), 
                                 nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_SUB_ToCSM) <- R_SUB_ToCSM_colnames

R_SUB_Disc2 <- data.frame(matrix(ncol = length(R_SUB_Disc2_colnames), 
                                 nrow = length(R_IF_Patterns$`Reporting Date`)))
colnames(R_SUB_Disc2) <- R_SUB_Disc2_colnames

R_I_IN_Disc <- data.frame(matrix(ncol = length(R_I_IN_Disc_colnames), 
                                 nrow = length(R_IF_Patterns$`Reporting Date`)))
colnames(R_I_IN_Disc) <- R_I_IN_Disc_colnames

R_IN_Disc <- data.frame(matrix(ncol = length(R_IN_Disc_colnames), 
                               nrow = length(R_NEW_CFs$`Reporting Date`)))
colnames(R_IN_Disc) <- R_IN_Disc_colnames

R_IN_LR <- data.frame(matrix(ncol = length(R_IN_LR_colnames), 
                             nrow = length(R_I_Mapping$`GRC Code`)))
colnames(R_IN_LR) <- R_IN_LR_colnames

R_IN_Calc <- data.frame(matrix(ncol = length(R_IN_Calc_colnames), 
                               nrow = length(R_NEW_GEN$`GRC Code`)))
colnames(R_IN_Calc) <- R_IN_Calc_colnames

R_IN_Pre_FX <- data.frame(matrix(ncol = length(R_IN_Pre_FX_colnames), 
                                 nrow = length(R_IN_Calc$`GRC Code`)))
colnames(R_IN_Pre_FX) <- R_IN_Pre_FX_colnames

R_IN_ToSL <- data.frame(matrix(ncol = length(R_IN_ToSL_colnames), 
                               nrow = length(R_IN_Calc$`GRC Code`)))
colnames(R_IN_ToSL) <- R_IN_ToSL_colnames




############################################## R_SUB_LR
# Load relevant sheets into dataframes
I_SUB_Calc <- wb_to_df(wb, sheet= "I_SUB_Calc", rows= 1:4, cols= 1:231, col_names = TRUE)
I_IN_Disc <- wb_to_df(wb, sheet= "I_IN_Disc", rows= 1:1801, cols= 1:41, col_names = TRUE)
I_SUB_Disc1 <- wb_to_df(wb, sheet= "I_SUB_Disc1", rows= 1:1801, cols= 1:182, col_names = TRUE)

# Assign 'GIC Code' values explicitly
for(i in seq_along(R_SUB_LR$`GIC Code`)) {
  if (Scope_Ins_NUB == 'No' & Scope_R_IF_GEN_LR == "No") {
    R_SUB_LR$`GIC Code`[i] <- 0
  } else {
    R_SUB_LR$`GIC Code`[i] <- R_I_Mapping$`GIC Code`[i]
  }
}

# Assign 'Opening LRC - Loss - PVFCF' using explicit references to GIC Code
R_SUB_LR <- R_SUB_LR %>%
  rowwise() %>%
  mutate(
    `Opening LRC - Loss - PVFCF` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No", 0,
      ifelse(
        R_SUB_LR$`GIC Measurement model` != "GMM",
        R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[
          match(R_SUB_LR$`GIC Code`, R_IF_GEN_LR$`GIC Code`)
        ],
        I_SUB_Calc$`Opening LRC - Loss - PVFCF`[
          match(R_SUB_LR$`GIC Code`, I_SUB_Calc$`GIC Code`)
        ]
      )
    )
  ) %>%
  ungroup()
# Ensure correct vector length
effect_values <- rep(0, nrow(R_SUB_LR))  # Initialize vector with zeros

# Find matches in R_IF_GEN_LR (for GIC Measurement model != "GMM")
match_index_R_IF_GEN_LR <- match(R_SUB_LR$`GIC Code`, R_IF_GEN_LR$`GIC Code`)

if (!all(is.na(match_index_R_IF_GEN_LR))) {
  effect_values[!is.na(match_index_R_IF_GEN_LR)] <- R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[
    match_index_R_IF_GEN_LR[!is.na(match_index_R_IF_GEN_LR)]
  ]
}

# Find matches in I_SUB_Calc (for GIC Measurement model == "GMM")
match_index_I_SUB_Calc <- match(R_SUB_LR$`GIC Code`, I_SUB_Calc$`GIC Code`)

if (!all(is.na(match_index_I_SUB_Calc))) {
  effect_values[!is.na(match_index_I_SUB_Calc)] <- I_SUB_Calc$`Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)`[
    match_index_I_SUB_Calc[!is.na(match_index_I_SUB_Calc)]
  ]
}

# Apply case_when with properly aligned vector lengths
R_SUB_LR <- R_SUB_LR %>%
  mutate(
    `Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)` = case_when(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,
      TRUE ~ effect_values
    )
  )

R_SUB_LR <- R_SUB_LR %>%
  mutate(lookup_value = paste0(R_SUB_LR$`GRC Code`, R_SUB_LR$`GIC Code`))  

if ("lookup_value" %in% colnames(R_SUB_LR)) {
  match_index <- match(R_SUB_LR$lookup_value, paste0(R_IF_GEN_LR$`GRC Sub-code`, R_IF_GEN_LR$`GIC Code`))
} else {
  match_index <- NA  # Prevent match errors
}


  R_SUB_LR <- R_SUB_LR %>%
  select(-lookup_value)  # Remove the lookup_value column

 

 # Create lookup_value column
R_SUB_LR <- R_SUB_LR %>%
  mutate(
    lookup_value = paste0(`GRC Code`, `GIC Code`)  # Create lookup_value by concatenating GRC and GIC codes
  )

# Define the columns you want to calculate
cols_to_calculate <- c(
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX",
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX",
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates (2/2)",
  "Opening LRC - Loss - RA",
  "LRC - Loss - RA - Post Roll Forward",
  "Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current)" ,
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX" ,
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX" ,
  "Effect on LRC - Loss - RA of Changes in Interest Rates (2/2)",
  "Total Change in FCF (Future) Non FX",
  "Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX"
  
)

# Loop through the columns and apply the logic for each column separately
for (col_name in cols_to_calculate) {
  R_SUB_LR <- R_SUB_LR %>%
    rowwise() %>%  # Ensure matching is done on a per-row basis
    mutate(
      !!sym(col_name) := 
        ifelse(
          Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No", 
          0,  # Case when both Scope_Insurance and Scope_R_IF_GEN_LR are "No"
          
          ifelse(
            R_SUB_LR$`GIC Measurement model` != "GMM", 
            { 
              # Match based on lookup_value (concatenated GRC and GIC codes)
              match_index <- match(lookup_value, paste0(R_IF_GEN_LR$`GRC Sub-code`, R_IF_GEN_LR$`GIC Code`))
              ifelse(!is.na(match_index), R_IF_GEN_LR[[col_name]][match_index], 0)
            }, 
            { 
              # Match based on GIC Code in I_SUB_Calc
              match_index <- match(`GIC Code`, I_SUB_Calc$`GIC Code`)
              ifelse(!is.na(match_index), I_SUB_Calc[[col_name]][match_index], 0)
            }
          )
        )
    ) %>%
    ungroup()  # Ungroup after row-wise operations
}

# Remove the lookup_value column after processing
R_SUB_LR <- R_SUB_LR %>%
  select(-lookup_value)

R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - RA` <- 
  R_SUB_LR$`LRC - Loss - RA - Post Roll Forward` - 
  R_SUB_LR$`New LRC - Loss - RA` - 
  R_SUB_LR$`Opening LRC - Loss - RA`

# Calculate the Closing LRC - Loss - PVFCF directly
R_SUB_LR$`Closing LRC - Loss - PVFCF` <- 
  R_SUB_LR$`Opening LRC - Loss - PVFCF` + 
  R_SUB_LR$`New LRC - Loss - PVFCF` + 
  R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - PVFCF` + 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)` + 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX` + 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX` + 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Changes in Interest Rates (2/2)`



R_SUB_LR <- R_SUB_LR %>%
  mutate(
    lookup_value = paste0(`GRC Code`, `GIC Code`),  # Concatenating GRC Code and GIC Code for lookup

    # Apply conditions using case_when
    `New LRC - Loss - RA` = case_when(
      
      # Condition 1: When both Scope_Insurance and Scope_R_IF_GEN_LR are "No"
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" & Scope_Reins_NUB== "No" ~ 0,

      # Condition 2: When GIC Measurement model is not "GMM", look up in R_IF_GEN_LR based on concatenated GRC Code and GIC Code
      R_SUB_LR$`GIC Measurement model` != "GMM" ~ {
        match_index <- match(lookup_value, paste0(R_IF_GEN_LR$`GRC Sub-code`, R_IF_GEN_LR$`GIC Code`))
        
        # Return matched value or 0 if no match
        ifelse(!is.na(match_index), 
               R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[match_index], 
               0)
      },
      
      # Condition 3: If GIC Measurement model is "GMM", look up based on GIC Code in I_SUB_Calc
      R_SUB_LR$`GIC Measurement model` == "GMM" ~ {
        match_index <- match(`GIC Code`, I_SUB_Calc$`GIC Code`)
        
        # Return matched value or 0 if no match
        ifelse(!is.na(match_index), 
               I_SUB_Calc$`New LRC - Loss - RA`[match_index], 
               0)
      },
      
      # Default: Set to NA if no conditions match
      TRUE ~ NA_real_
    )
  )

  R_SUB_LR <- R_SUB_LR %>%
  select(-lookup_value)  # Remove the lookup_value column

# Closing LRC - Loss - RA
R_SUB_LR$`Closing LRC - Loss - RA` <- 
  R_SUB_LR$`Opening LRC - Loss - RA` +
  R_SUB_LR$`New LRC - Loss - RA` +
  R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - RA` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current)` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Changes in Interest Rates (2/2)`

# Opening/New LRC - Loss
R_SUB_LR$`Opening/New LRC - Loss` <- 
  R_SUB_LR$`Opening LRC - Loss - PVFCF` + 
  R_SUB_LR$`New LRC - Loss - PVFCF` + 
  R_SUB_LR$`Opening LRC - Loss - RA` + 
  R_SUB_LR$`New LRC - Loss - RA`

# Effect of Changes in Interest rates on LRC
R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss` <- 
  R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - PVFCF` +
  R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - RA`

# Effect on LRC - Removal of Expected Claims and Other Expenses Incurred (Current)
R_SUB_LR$`Effect on LRC - Loss - Removal of Expected Claims and Other Expenses Incurred (Current)` <- 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current)`

# Effect on LRC - Total Experience Variance (Future) - FX
R_SUB_LR$`Effect on LRC - Loss - Total Experience Variance (Future) - FX` <- 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX`

# Effect on LRC - Changes in Interest Rates (2/2)
R_SUB_LR$`Effect on LRC - Loss - Changes in Interest Rates (2/2)` <- 
  R_SUB_LR$`Effect on LRC - Loss - PVFCF of Changes in Interest Rates (2/2)` +
  R_SUB_LR$`Effect on LRC - Loss - RA of Changes in Interest Rates (2/2)`

R_SUB_LR$`Closing LRC - Loss` <- 
  R_SUB_LR$`Closing LRC - Loss - PVFCF` + 
  R_SUB_LR$`Closing LRC - Loss - RA`

R_SUB_LR <- R_SUB_LR %>%
  mutate(
    `ARC - P&L pass through factor` = case_when(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,
      R_SUB_LR$`GIC Measurement model` == "PAA" ~ 1,  # Equivalent to 100%
      !is.na(`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`) & 
      !is.na(`Total Change in FCF (Future) Non FX`) & 
      `Total Change in FCF (Future) Non FX` != 0 ~ 
        `Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX` / `Total Change in FCF (Future) Non FX`,
      TRUE ~ 0  # Default case if none of the above conditions are met
    )
  )

######################################################################R_SUB_CALC
R_SUB_Calc$`GRC Code` <- R_Groups$`GRC Code`
R_SUB_Calc$`Locked-in YC Date` <- R_Groups$`Locked-in YC Date`


thomo <- R_Groups %>%
  select(`GRC Code`, `Currency`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and R_Groups
indices <- match(R_SUB_Calc$`GRC Code`, thomo$`GRC Code`)
R_SUB_Calc$`Currency` <- thomo$`Currency`[indices]


# Check the Option_RASimplification value
if(Option_RASimplification == "Yes") {
  # Populate 'RA % of ABS(PVFCF Recoveries)' in R_SUB_Calc
  R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- sapply(R_SUB_Calc$`GRC Code`, function(code) {
    # Filter rows in R_Groups that match the current GRC Code
    matched_rows <- R_Groups[R_Groups$`GRC Code` == code, ]
    
    # If there are any matches, sum the 'RA % of ABS(PVFCF)' values, otherwise return 0
    if(nrow(matched_rows) > 0) {
      sum(matched_rows$`RA % of ABS(PVFCF)`, na.rm = TRUE)  # Use na.rm to ignore NA values if any
    } else {
      0
    }
  })
} else {
  # If Option_RASimplification is not "Yes", populate with 0
  R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- 0
}



# Populate the 'Opening ARC - PVFCF (Non-recoveries)' column in R_SUB_Calc
R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries)` <- sapply(R_SUB_Calc$`GRC Code`, function(grc_code) {
  # Filter Workings_R_SUB_Disc1 based on the matching Reporting Date and GRC Code
  filtered_data <- R_SUB_Disc1 %>%
    filter(`Reporting Date` == ReportingDate_Previous & `GRC Code` == grc_code)
  
  # Sum the 'Discounted Non-recoveries CFs (Prev YC, Current FX, t0)' values if matches are found
  if(nrow(filtered_data) > 0) {
    -sum(filtered_data$`Discounted Non-recoveries CFs (Prev YC, Current FX, t0)`, na.rm = TRUE)
  } else {
    0
  }
})

R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) (Locked-in YC)` <- sapply(R_SUB_Calc$`GRC Code`, function(grc_code) {
  # Filter Workings_R_SUB_Disc1 based on the matching Reporting Date and GRC Code
  filtered_data <- R_SUB_Disc1 %>%
    filter(`Reporting Date` == ReportingDate_Previous & `GRC Code` == grc_code)
  
  # Sum the 'Discounted Non-recoveries CFs (Prev YC, Current FX, t0)' values if matches are found
  if(nrow(filtered_data) > 0) {
    -sum(filtered_data$`Discounted Non-recoveries CFs (Locked - in YC, t0)`, na.rm = TRUE)
  } else {
    0
  }
})

R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)` <- sapply(R_SUB_Calc$`GRC Code`, function(grc_code) {
  # Filter Workings_R_SUB_Disc1 based on the matching Reporting Date and GRC Code
  filtered_data <- R_SUB_Disc1 %>%
    filter(`Reporting Date` == ReportingDate_Previous & `GRC Code` == grc_code)
  
  # Sum the 'Discounted Non-recoveries CFs (Prev YC, Current FX, t0)' values if matches are found
  if(nrow(filtered_data) > 0) {
    -sum(filtered_data$`Discounted Non-recoveries CFs (Prev YC, Current FX, t1)`, na.rm = TRUE)
  } else {
    0
  }
})

R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)` <- sapply(R_SUB_Calc$`GRC Code`, function(grc_code) {
  # Filter Workings_R_SUB_Disc1 based on the matching Reporting Date and GRC Code
  filtered_data <- R_SUB_Disc1 %>%
    filter(`Reporting Date` == ReportingDate_Previous & `GRC Code` == grc_code)
  
  # Sum the 'Discounted Non-recoveries CFs (Prev YC, Current FX, t0)' values if matches are found
  if(nrow(filtered_data) > 0) {
    -sum(filtered_data$`Discounted Non-recoveries CFs (Locked - in YC, t1)`, na.rm = TRUE)
  } else {
    0
  }
})

R_SUB_Calc$`Effect on ARC - PVFCF (Non-recoveries) of Changes in Interest Rates (1/2)` <- 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)` - 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)`

R_SUB_Calc$`Interest Accreted on Opening ARC - PVFCF (Non-recoveries)` <- 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)` - 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries)`

R_IN_Disc <- wb_to_df(wb, sheet= "R_IN_Disc", rows= 1:1801, cols= 1:33, col_names = TRUE)
# Corrected code to select the correct columns and group by GRC Code
thomo <- R_IN_Disc %>%
  select(`GRC Code`, `Discounted Non-recoveries CFs (Locked-in YC, Locked-in Date)`) %>%  # Corrected closing parenthesis
  group_by(`GRC Code`)

# Create indices using match to match GRC Code between R_IN_Disc and R_Groups
indices <- match(R_SUB_Calc$`GRC Code`, thomo$`GRC Code`)
R_SUB_Calc <- R_SUB_Calc %>%
  slice(rep(1:n(), length.out = nrow(thomo)))

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Calc$`New ARC - PVFCF (Non-recoveries)` <- thomo$`Discounted Non-recoveries CFs (Locked-in YC, Locked-in Date)`

R_SUB_Calc$`Interest Accreted on New ARC - PVFCF (Non-recoveries)` <- 0  # Placeholder, replace with actual calculation
# Ensure all required columns exist and have 1800 rows
required_cols <- c("Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)", 
                   "New ARC - PVFCF (Non-recoveries) - Post Roll Forward")

for (col in required_cols) {
  if (length(R_SUB_Calc[[col]]) < 1800) {  
    R_SUB_Calc[[col]] <- rep(R_SUB_Calc[[col]], length.out = 1800)  # Expand column to 1800 rows
  }
}

# Ensure the source columns exist in R_SUB_Calc
required_columns <- c(
  "Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)",
  "New ARC - PVFCF (Non-recoveries) - Post Roll Forward"
)

# Check if required columns exist, if not, create them with NA values
for (col in required_columns) {
  if (!col %in% colnames(R_SUB_Calc)) {
    R_SUB_Calc[[col]] <- rep(NA, 1800)  # Create missing columns with 1800 NA values
  }
}

# Ensure the source columns have the correct number of rows
if (length(R_SUB_Calc[[required_columns[1]]]) == 0) {
  R_SUB_Calc[[required_columns[1]]] <- rep(0, 1800)
}
if (length(R_SUB_Calc[[required_columns[2]]]) == 0) {
  R_SUB_Calc[[required_columns[2]]] <- rep(0, 1800)
}

# Now safely perform the calculation
R_SUB_Calc$`ARC - PVFCF (Non-recoveries) - Post Roll Forward` <- 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)` + 
  R_SUB_Calc$`New ARC - PVFCF (Non-recoveries) - Post Roll Forward`

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(`New ARC - PVFCF (Non-recoveries)` = -sum(R_IN_Disc$`Discounted Non-recoveries CFs (Locked-in YC, Locked-in Date)`[
    R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
    R_IN_Disc$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(`New ARC - PVFCF (Non-recoveries) - Post Roll Forward` = -sum(R_IN_Disc$`Discounted Non-recoveries CFs (Locked-in YC, Reporting Date)`[
    R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
    R_IN_Disc$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(`Opening ARC - PVFCF (Non-recoveries) (Locked-in YC)` = -sum(R_SUB_Disc1$`Discounted Non-recoveries CFs (Locked-in YC, t0)`[
    R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous & 
    R_SUB_Disc1$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

# Populate Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)` = -sum(R_SUB_Disc1$`Discounted Non-recoveries CFs (Prev YC, Current FX, t1)`[
    R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous & 
    R_SUB_Disc1$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

# Populate Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)` = -sum(R_SUB_Disc1$`Discounted Non-recoveries CFs (Locked-in YC, t1)`[
    R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous & 
    R_SUB_Disc1$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

# Populate Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(`Expected Premium (Past/Current)(New)` = sum(R_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)`[
    R_IN_Disc$`Reporting Date` == ReportingDate_Previous & 
    R_IN_Disc$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(`Premium Payments (Past/Current)` = sum(R_IF_GEN$`Premium Payments (Past/Current Service)`[
    R_IF_GEN$`Reporting Date` == ReportingDate_Current & 
    R_IF_GEN$`GRC Code` == `GRC Code`
  ], na.rm = TRUE))


R_SUB_Calc$`Expected Non-recoveries CFs (Future)(Closing)` <- sapply(R_SUB_Calc$`GRC Code`, function(grc_code) {
  # Filter R_SUB_Disc1 for rows matching the current Reporting Date and GRC Code
  filtered_data <- R_SUB_Disc1 %>%
    filter(`Reporting Date` == ReportingDate_Current & `GRC Code` == grc_code)
  
  # Sum the three relevant columns if there are matches
  if(nrow(filtered_data) > 0) {
    -(sum(filtered_data$`Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t0)`, na.rm = TRUE) +
      sum(filtered_data$`Discounted Premium CFs (Future Service)(Locked-in YC, t0)`, na.rm = TRUE) +
      sum(filtered_data$`Discounted Investment Component CFs (Receivable in Future)(Locked-in YC, t0)`, na.rm = TRUE))
  } else {
    0
  }
})

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Effect on ARC - RA of Changes in Interest Rates (1/2)` <- ifelse(
  Option_DisaggregateChangeInRA == "No" | 
  R_SUB_Calc$`Opening ARC - PVFCF (Recoveries) - Post Roll Forward (Prev YC)` == 0,
  0,
  R_SUB_Calc$`Effect on ARC - PVFCF (Recoveries) of Changes in Interest Rates (1/2)` * 
    (R_SUB_Calc$`Opening ARC - RA` + 
     R_SUB_Calc$`Interest Accreted on Opening ARC - RA`) / 
    R_SUB_Calc$`Opening ARC - PVFCF (Recoveries) - Post Roll Forward (Prev YC)`
)

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Interest Accreted on Opening ARC - RA` <- ifelse(
  Option_DisaggregateChangeInRA == "No" | 
    R_SUB_Calc$`Opening ARC - PVFCF (Recoveries)` == 0,
  0,
  R_SUB_Calc$`Interest Accreted on Opening ARC - PVFCF (Recoveries)` * 
    R_SUB_Calc$`Opening ARC - RA` / 
    R_SUB_Calc$`Opening ARC - PVFCF (Recoveries)`
)


library(dplyr)

# Ensure Option_DisaggregateChangeInRA is correctly referenced
if (!exists("Option_DisaggregateChangeInRA")) {
  Option_DisaggregateChangeInRA <- "No" # Default value if not defined
}

# Fix 1: Compute Interest Accreted on Opening ARC - RA (Locked-in YC)
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Interest Accreted on Opening ARC - RA (Locked-in YC)` = ifelse(
      Option_DisaggregateChangeInRA == "No" | `Opening ARC - PVFCF (Recoveries)` == 0,
      0,
      `Interest Accreted on Opening ARC - PVFCF (Recoveries) (Locked-in YC)` * 
        `Opening ARC - RA` / 
        `Opening ARC - PVFCF (Recoveries)`
    )
  )

# Fix 2: Create "New ARC - RA" using match() safely
header_index <- match("New ARC - RA", colnames(R_IN_Calc))

R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `New ARC - RA` = ifelse(
      is.na(match(`GRC Code`, R_NEW_GEN$`GRC Code`)),
      0,
      R_IN_Calc[match(`GRC Code`, R_IN_Calc$`GRC Code`, nomatch = NA), header_index]
    )
  )

# Fix 3: Compute "Interest Accreted on New ARC - RA"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Interest Accreted on New ARC - RA` = ifelse(
      Option_DisaggregateChangeInRA == "No" | `New ARC - PVFCF (Recoveries)` == 0,
      0,
      `Interest Accreted on New ARC - PVFCF (Recoveries)` * 
        `New ARC - RA` / 
        `New ARC - PVFCF (Recoveries)`
    )
  )

# Fix 4: Compute "Interest Accreted on ARC - RA"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Interest Accreted on ARC - RA` = `Interest Accreted on Opening ARC - RA` + `Interest Accreted on New ARC - RA`,
    `Interest Accreted on ARC - RA (Locked-in YC)` = `Interest Accreted on Opening ARC - RA (Locked-in YC)` + `Interest Accreted on New ARC - RA`
  )

# Fix 5: Compute "ARC - RA - Post Roll Forward"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `ARC - RA - Post Roll Forward` = `Opening ARC - RA` + 
      `New ARC - RA` + 
      `Effect on ARC - RA of Changes in Interest Rates (1/2)` + 
      `Interest Accreted on ARC - RA`
  )

# Compute "Closing ARC - RA" using case_when() to support multiple rows
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Closing ARC - RA` = case_when(
      `RA % of ABS(PVFCF Recoveries)` == 0 ~ sum(
        R_IF_GEN$`Closing ARC - RA`[
          R_IF_GEN$`Reporting Date` == ReportingDate_Current & 
            R_IF_GEN$`GRC Code` == `GRC Code`
        ], na.rm = TRUE
      ),
      TRUE ~ abs(`Closing ARC - PVFCF (Recoveries)(Current NP Risk, Current YC, Current FX)`) * `RA % of ABS(PVFCF Recoveries)`
    )
  )

# Compute "Effect on ARIC - RA of Change in NP Risk"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - RA of Change in NP Risk` = case_when(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0 ~ 0,
      TRUE ~ `Effect on ARIC - PVFCF of Change in Exchange Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    )
  )

# Compute "Effect on ARIC - RA of Change in Exchange Rates" and "Effect on ARIC - RA of Changes in Interest Rates"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - RA of Change in Exchange Rates` = case_when(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0 ~ 0,
      TRUE ~ `Effect on ARIC - PVFCF of Change in Exchange Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    ),
    `Effect on ARIC - RA of Changes in Interest Rates` = case_when(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0 ~ 0,
      TRUE ~ `Effect on ARIC - PVFCF of Changes in Interest Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    )
  )

# Compute "Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current)"
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current)` = case_when(
      Option_RASimplification == "Yes" & `Closing ARIC - PVFCF` == 0 ~ 0,
      Option_RASimplification == "Yes" ~ abs(
        `Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current)` - 
          `Recoveries Receipts (On Claims Incurred in Current Reporting Period)`
      ) * `Closing ARIC - RA` / abs(`Closing ARIC - PVFCF`),
      TRUE ~ sum(
        R_IF_GEN$`Closing ARIC - RA (Recoveries on New Claims and Other Expenses Incurred)`[
          R_IF_GEN$`Reporting Date` == ReportingDate_Current &
            R_IF_GEN$`GRC Code` == `GRC Code`
        ], na.rm = TRUE
      )
    )
  )


R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARIC - IC` = sum(
      R_IF_GEN$`Opening ARIC - IC`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Investment Component Receipts` = -sum(
      R_IF_GEN$`Investment Component Receipts`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Closing ARIC - IC` = sum(
      R_IF_GEN$`Closing ARIC - IC`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARC - PRCF` = sum(
      R_IF_GEN$`Opening ARC - PRCF`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Pre-recognition CF Receipts` = sum(
      R_IF_GEN$`Pre-recognition CF Receipts`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Impairment of PRCF Liability` = sum(
      R_IF_GEN$`Impairment of PRCF Liability`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Reversal of Impairment of PRCF Liability` = sum(
      R_IF_GEN$`Reversal of Impairment of PRCF Liability`[
        R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - IC of Changes to IC CFs (Past)` = 
      `Closing ARIC - IC` - 
      (`Opening ARIC - IC` - `Transfer of Reinsurance Investment Components` - `Investment Component Receipts`)
  )
  

#########################################R_SUB_ToCSM
R_SUB_Calc <- wb_to_df(wb, sheet= "R_SUB_Calc", rows= 1:4, cols= 1:171, col_names = TRUE)
R_FX <- wb_to_df(wb, sheet= "R_FX", rows= 1:38, cols= 1:103, col_names = TRUE)
R_SUB_Disc2 <- wb_to_df(wb, sheet= "R_SUB_Disc2", rows= 1:1801, cols= 1:9, col_names = TRUE)

R_SUB_ToCSM$`GRC Code` <- R_SUB_Calc$`GRC Code`

# Load necessary libraries
library(dplyr)

# Assuming R_SUB_Disc2 and R_SUB_ToCSM are already defined data frames
# Define ReportingDate_Current
ReportingDate_Current <- ReportingDate_Current # Replace with your actual date variable

# Fetching the Closing ARC - CSM - Current FX value from R_FX
closing_arc_csm_current_fx <- R_FX[["Closing ARC - CSM - Current FX"]]

# Extracting specific reporting period from the column title
# Assuming the reporting period is located at a specific character position in the title
reporting_period <- as.numeric(substr("ARC - CSM Release - Reporting Period 1", 38, 40))  # Adjust indices as necessary

# Calculate ARC - CSM Release - Reporting Period 1
R_SUB_ToCSM <- R_SUB_ToCSM %>%
  rowwise() %>%
  mutate(
    # First SUMIFS equivalent: Total Discounted Coverage Units for current date and GRC Code
    total_discounted_units = sum(R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
      R_SUB_Disc2$`Reporting Date` == ReportingDate_Current &
      R_SUB_Disc2$`GRC Code` == `GRC Code` & 
      R_SUB_Disc2$`Reporting Period` > 0], na.rm = TRUE),
    
    # Second SUMIFS equivalent: Discounted Coverage Units for specific reporting period
    specific_period_units = sum(R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
      R_SUB_Disc2$`Reporting Date` == ReportingDate_Current &
      R_SUB_Disc2$`GRC Code` == `GRC Code` & 
      R_SUB_Disc2$`Reporting Period` == reporting_period], na.rm = TRUE)
    
  ) %>%
  ungroup() %>%
  
  # Final calculation using IF logic
  mutate(
    `ARC - CSM Release - Reporting Period 1` = 
      ifelse(total_discounted_units == 0,
             0,
             closing_arc_csm_current_fx * (specific_period_units / total_discounted_units))
  )

# Fetching the Closing ARC - CSM - Current FX value from R_FX
closing_arc_csm_current_fx <- R_FX[["Closing ARC - CSM - Current FX"]]

# Calculate ARC - CSM Release for Reporting Periods 1 to 100
for (period in 2:100) {
  
  # Create the column name dynamically
  column_name <- paste0("ARC - CSM Release - Reporting Period ", period)
  
  # Extract specific reporting period number
  reporting_period <- period
  
  # Calculate the discounted units and populate the new column
  R_SUB_ToCSM <- R_SUB_ToCSM %>%
    rowwise() %>%
    mutate(
      # First SUMIFS equivalent: Total Discounted Coverage Units for current date and GRC Code
      total_discounted_units = sum(R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
        R_SUB_Disc2$`Reporting Date` == ReportingDate_Current &
        R_SUB_Disc2$`GRC Code` == `GRC Code` & 
        R_SUB_Disc2$`Reporting Period` > 0], na.rm = TRUE),
      
      # Second SUMIFS equivalent: Discounted Coverage Units for specific reporting period
      specific_period_units = sum(R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
        R_SUB_Disc2$`Reporting Date` == ReportingDate_Current &
        R_SUB_Disc2$`GRC Code` == `GRC Code` & 
        R_SUB_Disc2$`Reporting Period` == reporting_period], na.rm = TRUE)
      
    ) %>%
    ungroup() %>%
    
    # Final calculation using IF logic to create the new column
    mutate(!!column_name := ifelse(total_discounted_units == 0,
                                    0,
                                    closing_arc_csm_current_fx * (specific_period_units / total_discounted_units)))
}

# Optional: Remove temporary columns if needed
R_SUB_ToCSM <- R_SUB_ToCSM %>% select(-total_discounted_units, -specific_period_units)

###################################################R_SUB_Disc2

R_SUB_Disc2$`Reporting Date` <- as.Date(R_IF_Patterns$`Reporting Date`)
R_SUB_Disc2$`GRC Code` <- (R_IF_Patterns$`GRC Code`)



thomo <- R_Groups %>%
  select(`GRC Code`, `Locked-in YC Date`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and R_Groups
indices <- match(R_SUB_Disc2$`GRC Code`, thomo$`GRC Code`)

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Disc2$`Locked-in YC Date` <- thomo$`Locked-in YC Date`[indices]

thomo <- R_Groups %>%
  select(`GRC Code`, `Currency`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and R_Groups
indices <- match(R_SUB_Disc2$`GRC Code`, thomo$`GRC Code`)

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Disc2$`Currency` <- thomo$`Currency`[indices]

R_SUB_Disc2$`Coverage Units (Undiscounted)` <- R_IF_Patterns$`Coverage Unit (Undiscounted)`
R_SUB_Disc2$`Reporting Period (0 = current)` <- R_IF_Patterns$`Reporting Period (0 = current)`

#############################################################R_SUB_Calc
R_SUB_Calc$`GRC Code` <- R_Groups$`GRC Code`
R_SUB_Calc$`Currency` <- R_Groups$`Currency`[match(R_SUB_Calc$`GRC Code`, R_Groups$`GRC Code`)]
R_SUB_Calc$`Locked-in YC Date` <- R_Groups$`Locked-in YC Date`
R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- ifelse(
  Option_RASimplification == "Yes",
  sapply(R_SUB_Calc$GRC_Code, function(grc) {
    sum(R_Groups$`RA % of ABS(PVFCF)`[R_Groups$GRC_Code == grc], na.rm = TRUE)
  }),
  0
)


library(dplyr)

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARC - PVFCF (Non-recoveries)` = {
      # Filter matching rows
      matching_rows <- R_SUB_Disc1 %>%
        filter(
          `Reporting Date` == ReportingDate_Previous,
          `GRC Code` == `GRC Code`
        ) %>%
        pull(`Discounted Non-recoveries CFs (Prev YC, Current FX, t0)`)  # <-- FIX: No dataframe reference in pull()
      
      # Compute negative sum (if no matches, return 0)
      -sum(matching_rows, na.rm = TRUE)
    }
  ) %>%
  ungroup()

# Fix for 'Release in ARC - CSM' using list()
R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Release in ARC - CSM` = list(
      -`ARC - CSM - Post Reversal of Cash flows not affecting the GRC` * 
        case_when(
          R_IN_Calc$`Retroactive Cover?` == "Yes" |
            sum(
              R_SUB_Disc2 %>%
                filter(`Reporting Date` == ReportingDate_Current, 
                       `GRC Code` == `GRC Code`) %>%
                pull(`Discounted Coverage Units (Locked-in YC, t0)`)
            ) == 0 ~ 1,
          TRUE ~ sum(
            R_SUB_Disc2 %>%
              filter(`Reporting Date` == ReportingDate_Current, 
                     `GRC Code` == `GRC Code`, 
                     `Reporting Period (0 = current)` == 0) %>%
              pull(`Discounted Coverage Units (Locked-in YC, t0)`)
          ) /
            sum(
              R_SUB_Disc2 %>%
                filter(`Reporting Date` == ReportingDate_Current, 
                       `GRC Code` == `GRC Code`) %>%
                pull(`Discounted Coverage Units (Locked-in YC, t0)`)
            )
        )
    )
  ) %>%
  ungroup()

# Fix for 'Interest Accreted on ARIC - PVFCF' using list()
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Interest Accreted on ARIC - PVFCF` = list(`ARIC - PVFCF - Post Roll Forward` - `Opening ARIC - PVFCF`)
  ) %>%
  ungroup()


  ###################################################### R_EQ_Calc
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `GRC Code` = case_when(
        Scope_Reinsurance == "No" ~ "0",  # Ensure it's a character
        TRUE ~ as.character(R_Groups$`GRC Code`[match(`GRC Code`, R_Groups$`GRC Code`)])
      )
    )
  
  
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Reporting Segment` = case_when(
        Scope_Reinsurance == "No" ~ "0",  # Convert to character if needed
        TRUE ~ as.character(R_Groups$`Reporting Segment`[match(`GRC Code`, R_Groups$`GRC Code`)])
      )
    )
  

  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Opening Reinsurance Finance Reserve` = case_when(
        Scope_Reinsurance == "No" ~ as.character(0),  # Ensure character consistency
        TRUE ~ as.character(sum(
          Table65 %>%
            filter(`GRC Code` == `GRC Code`) %>%
            pull(`Opening Reinsurance Finance Reserve`),
          na.rm = TRUE
        ))
      )
    )
  
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Income/(Expense) disclosed in OCI` = as.character(sum(
        Table36 %>%
          filter(`GRC Code` == R_EQ_Calc$`GRC Code`) %>%
          select(`Opening Reinsurance Finance Reserve`, `Income/(Expense) disclosed in OCI`) %>%
          unlist(),  # Convert to a numeric vector
        na.rm = TRUE
      ))
    )
  
  R_Disclosures_Master <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_Disclosures_Master") 
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Closing Reinsurance Finance Reserve` = case_when(
        Scope_Reinsurance == "No" ~ as.character(0),
        TRUE ~ as.character(sum(
          Outputs_SL %>%
            filter(`Group Code` == `GRC Code`, `CR Account Code` %in% c(
              R_Disclosures_Master$G44, R_Disclosures_Master$G47, 
              R_Disclosures_Master$G50, R_Disclosures_Master$G53
            )) %>%
            pull(Amount),
          na.rm = TRUE
        ))
      )
    )
  Table65 <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_Equity") 
  
 
  R_EQ_Calc <- R_EQ_Calc %>%
   
    mutate(
      `Opening Retained Earnings` = case_when(
        Scope_Reinsurance == "No" ~ as.character(0),
        TRUE ~ as.character(sum(
          Table65 %>%
            filter(`GRC Code` == `GRC Code`) %>%
            pull(`Opening Retained Earnings`),
          na.rm = TRUE
        ))
      )
    )
  Table36 <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_EQ_Calc")
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Income/(Expense) disclosed in P&L` = as.character(sum(
        Table36 %>%
          filter(`GRC Code` == R_EQ_Calc$`GRC Code`) %>%
          select(`Opening Retained Earnings`, `Income/(Expense) disclosed in P&L`) %>%
          unlist(),  # Convert multiple columns into a numeric vector
        na.rm = TRUE
      ))
    )
  
  R_EQ_Calc <- R_EQ_Calc %>%
    mutate(
      `Closing Retained Earnings` = case_when(
        Scope_Reinsurance == "No" ~ as.character(0),
        TRUE ~ as.character(sum(
          R_SUB_ToT1TB %>%
            filter(`GRC Code` == `GRC Code`) %>%
            select(`ARC - PVFCF - Non-Loss Recovery`, `ARC - RA`, `ARC - CSM`,
                   `ARC - PVFCF - Loss Recovery`, `ARC - PRCF`, `ARIC - PVFCF`,
                   `ARIC - RA`, `ARIC - IC`) %>%
            rowSums(na.rm = TRUE),
          na.rm = TRUE
        ) -
          sum(
            R_SUB_ToT0TB %>%
              filter(`GRC Code` == `GRC Code`) %>%
              select(`ARC - PVFCF - Non-Loss Recovery`, `ARC - RA`, `ARC - CSM`,
                     `ARC - PVFCF - Loss Recovery`, `ARC - PRCF`, `ARIC - PVFCF`,
                     `ARIC - RA`, `ARIC - IC`) %>%
              rowSums(na.rm = TRUE),
            na.rm = TRUE
          ))
      )
    )
  
# ################################################ R_I_SUB_Disc1
# 
library(dplyr)
  I_IF_FCFs <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_I_IF_FCFs")
  # Ensure every column has exactly 2400 rows
  R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
    mutate(
      `Reporting Date` = ifelse(
        Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
        "0",
        ifelse(
          !is.na(match(`GRC Code`, I_IF_FCFs$`GRC Code`)),
          I_IF_FCFs$`Reporting Date`[match(`GRC Code`, I_IF_FCFs$`GRC Code`)],
          rep("0", 2400)  # Extends missing values to match 2400 rows
        )
      ),
      `GIC Code` = ifelse(
        Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
        "0",
        ifelse(
          !is.na(match(`GRC Code`, I_IF_FCFs$`GRC Code`)),
          I_IF_FCFs$`GIC Code`[match(`GRC Code`, I_IF_FCFs$`GRC Code`)],
          rep("0", 2400)
        )
      ),
      `GRC Code` = ifelse(
        Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
        "0",
        ifelse(
          !is.na(match(`GRC Code`, I_IF_FCFs$`GRC Code`)),
          I_IF_FCFs$`GRC Code`[match(`GRC Code`, I_IF_FCFs$`GRC Code`)],
          rep("0", 2400)
        )
      ),
      `Locked-in YC Date` = ifelse(
        Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
        "0",
        ifelse(
          !is.na(match(`GRC Code`, I_IF_FCFs$`GRC Code`)),
          I_IF_FCFs$`Locked-in YC Date`[match(`GRC Code`, I_IF_FCFs$`GRC Code`)],
          rep("0", 2400)
        )
      ),
      Currency = ifelse(
        Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
        "0",
        ifelse(
          !is.na(match(`GIC Code`, R_I_Mapping$`GIC Code`)),
          R_I_Mapping$Currency[match(`GIC Code`, R_I_Mapping$`GIC Code`)],
          rep("0", 2400)
        )
      )
    )
#   
#   
#   
#   R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
#   mutate(
#     Discounted_CF_Next_Period =
#       Treaty_covered_CF_Unlinked_Next_Period *
#       ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
#          Delay_in_Years + (`Reporting Date` - Locked_in_YC_Date) / 365.25)) *
#       ((1 + Spot_Rate_Unlinked_Locked_in_Date)^(
#          (`Reporting Date` - Locked_in_YC_Date) / 365.25)) +
#       Treaty_covered_CF_Linked_Next_Period *
#       ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
#          Delay_in_Years + (`Reporting Date` - Locked_in_YC_Date) / 365.25)) *
#       ((1 + Spot_Rate_Linked_Locked_in_Date)^(
#          (`Reporting Date` - Locked_in_YC_Date) / 365.25))
#   )
# 
#   R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
#   mutate(
#     Discounted_CF_Future_Periods =
#       Treaty_covered_CF_Unlinked_Future_Periods *
#       ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
#          Delay_in_Years + (`Reporting Date` - Locked_in_YC_Date) / 365.25)) *
#       ((1 + Spot_Rate_Unlinked_Locked_in_Date)^(
#          (`Reporting Date` - Locked_in_YC_Date) / 365.25)) +
#       Treaty_covered_CF_Linked_Future_Periods *
#       ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
#          Delay_in_Years + (`Reporting Date` - Locked_in_YC_Date) / 365.25)) *
#       ((1 + Spot_Rate_Linked_Locked_in_Date)^(
#          (`Reporting Date` - Locked_in_YC_Date) / 365.25))
  # Load necessary libraries
  # Load necessary libraries

  # library(dplyr)
  # library(purrr)
  # library(lubridate)
  # 
  # # Ensure YieldCurves data is correctly formatted
  # YieldCurves <- YieldCurves %>%
  #   mutate(
  #     `Yield curve link` = as.character(YieldCurves$`Yield curve link`),  # Newly added
  #     `Linked/Unlinked` = as.character(YieldCurves$`Linked/Unlinked`),  # Newly added
  #     `Remaining Coverage/Incurred Claims` = as.character(YieldCurves$`Remaining Coverage/Incurred Claims`),
  #     `Currency` = as.character(YieldCurves$`Currency`),
  #     `Date \ Duration (Months)` = as.numeric(YieldCurves$`Date \ Duration (Months)`)
  #   )
  # 
  # # Compute Spot Rate column with row-wise vectorized lookup
  # I_IF_FCFs <- I_IF_FCFs %>%
  #   mutate(
  #     `Spot Rate (Unlinked)(Locked-in Date,(Reporting Date-Locked-in Date)+Delay)` = pmap_dbl(
  #       list(`Locked-in YC Date`, `Currency`, `GRC Code`, `Reporting Date`, `Delay (in Years)`),
  #       function(locked_in_date, currency, grc_code, reporting_date, delay) {
  #         
  #         # Handle missing values: replace NAs with defaults
  #         locked_in_date <- ifelse(is.na(locked_in_date), as.Date("1900-01-01"), locked_in_date)
  #         currency <- ifelse(is.na(currency), "UNKNOWN", currency)
  #         grc_code <- ifelse(is.na(grc_code), "UNKNOWN", grc_code)
  #         reporting_date <- ifelse(is.na(reporting_date), as.Date("1900-01-01"), reporting_date)
  #         delay <- ifelse(is.na(delay), 0, delay)
  #         
  #         # Condition to return 0
  #         if (Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No") {
  #           return(0)
  #         }
  #         
  #         # Construct lookup key
  #         lookup_key <- paste0(
  #           locked_in_date, "_", currency, "_Unlinked",
  #           ifelse(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", grc_code), "")
  #         )
  #         
  #         # Compute lookup index
  #         lookup_index <- round(((as.numeric(reporting_date - locked_in_date)) / 365.25 +
  #                                  delay) * 12, 0)
  #         
  #         # Ensure lookup index is within available range
  #         lookup_index <- ifelse(lookup_index < 0, 0, lookup_index)
  #         
  #         # Fetch corresponding value from YieldCurves
  #         spot_rate <- YieldCurves %>%
  #           filter(`Yield curve link` == lookup_key) %>%
  #           select(all_of(as.character(lookup_index))) %>%
  #           pull()
  #         
  #         # Ensure spot_rate is a single numeric value or 0 if missing
  #         return(ifelse(length(spot_rate) == 0, 0, spot_rate))
  #       }
  #     )
  #   )
  # 
  # # Ensure final data has exactly 1800 rows
  # if (nrow(I_IF_FCFs) < 1800) {
  #   missing_rows <- 1800 - nrow(I_IF_FCFs)
  #   empty_df <- I_IF_FCFs[1, ]  # Copy structure
  #   empty_df[] <- NA  # Set all values to NA
  #   I_IF_FCFs <- bind_rows(I_IF_FCFs, empty_df[rep(1, missing_rows), ])
  # }
  # 
  # 
  # 
  # # Ensure all setup values are correctly extracted
  # Scope_Insurance <- as.character(setup_data[7, 5])    # F7
  # Scope_R_IF_GEN_LR <- as.character(setup_data[15, 5]) # F15
  # Option_GranularYC <- as.character(setup_data[24, 5]) # F24
  # 
  # # Ensure required columns are in correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Locked-in YC Date` = as.Date(R_I_SUB_Disc1$`Locked-in YC Date`),
  #     `Reporting Date` = as.Date(R_I_SUB_Disc1$`Reporting Date`),
  #     `GRC Code` = as.character(R_I_SUB_Disc1$`GRC Code`),
  #     `Currency` = as.character(R_I_SUB_Disc1$`Currency`),
  #     `Delay (in Years)` = as.numeric(R_I_SUB_Disc1$`Delay (in Years)`)
  #   )
  # 
  # YieldCurves <- YieldCurves %>%
  #   mutate(
  #     `Yield curve link` = as.character(YieldCurves$`Yield curve link`),  # Newly added
  #     `Linked/Unlinked` = as.character(YieldCurves$`Linked/Unlinked`),  # Newly added
  #     `Remaining Coverage/Incurred Claims` = as.character(YieldCurves$`Remaining Coverage/Incurred Claims`),
  #     `Currency` = as.character(YieldCurves$`Currency`),
  #     `Date \ Duration (Months)` = as.numeric(YieldCurves$`Date \ Duration (Months)`)
  #   )
  # 
  # # Compute "Spot Rate (Unlinked)(Locked-in Date, (Reporting Date-Locked-in Date))" column
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Spot Rate (Unlinked)(Locked-in Date, (Reporting Date-Locked-in Date))` = pmap_dbl(
  #       list(`Locked-in YC Date`, `Currency`, `GRC Code`, `Reporting Date`),
  #       function(locked_in_date, currency, grc_code, reporting_date) {
  #         
  #         # Condition to return 0
  #         if (Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No") {
  #           return(0)
  #         }
  #         
  #         # Construct lookup key
  #         lookup_key <- paste0(
  #           locked_in_date, "_", currency, "_Unlinked",
  #           ifelse(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", grc_code), "")
  #         )
  #         
  #         # Compute lookup index
  #         lookup_index <- round(((as.numeric(reporting_date - locked_in_date)) / 365.25) * 12, 0)
  #         
  #         # Ensure lookup index is within available range
  #         lookup_index <- ifelse(lookup_index < 0, 0, lookup_index)
  #         
  #         # Fetch corresponding value from YieldCurves
  #         spot_rate <- YieldCurves %>%
  #           filter(`Yield curve link` == lookup_key) %>%
  #           select(all_of(as.character(lookup_index))) %>%
  #           pull()
  #         
  #         # Ensure spot_rate is a single numeric value or 0 if missing
  #         return(ifelse(length(spot_rate) == 0, 0, spot_rate))
  #       }
  #     )
  #   )
  # 
  # # Ensure final data has exactly 1800 rows
  # if (nrow(R_I_SUB_Disc1) < 1800) {
  #   missing_rows <- 1800 - nrow(R_I_SUB_Disc1)
  #   empty_df <- R_I_SUB_Disc1[1, ]  # Copy structure
  #   empty_df[] <- NA  # Set all values to NA
  #   R_I_SUB_Disc1 <- bind_rows(R_I_SUB_Disc1, empty_df[rep(1, missing_rows), ])
  # }
  # 
  # library(dplyr)
  # library(lubridate)
  # 
  # # Ensure R_I_SUB_Disc1 has properly formatted columns
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Locked-in YC Date` = as.Date(`Locked-in YC Date`),  # Ensure it's a date
  #     `Currency` = as.character(`Currency`),  # Ensure it's character
  #     `GRC Code` = as.character(`GRC Code`),  # Ensure it's character
  #     `Reporting Date` = as.Date(`Reporting Date`),  # Ensure it's a date
  #     `Delay (in Years)` = as.numeric(`Delay (in Years)`)  # Ensure it's numeric
  #   )
  # 
  # # Extract values from the Setup sheet
  # Scope_Insurance <- as.character(setup_data[7, 5])    
  # Scope_R_IF_GEN_LR <- as.character(setup_data[15, 5]) 
  # Option_GranularYC <- as.character(setup_data[24, 5])
  # 
  # # Compute the new column
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     # Construct lookup key
  #     YieldCurveKey = paste0(
  #       `Locked-in YC Date`, "_", `Currency`, "_Unlinked",
  #       ifelse(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GRC Code`), "")
  #     ),
  #     
  #     # Compute lookup index
  #     LookupIndex = round(
  #       trunc(((as.numeric(ReportingDate_Current) - as.numeric(`Locked-in YC Date`)) / 365.25) +
  #               pmin(`Delay (in Years)`, (as.numeric(ReportingDate_Current) - as.numeric(ReportingDate_Previous)) / 365.25)
  #       ) * 12, 2
  #     ),
  #     
  #     # Perform lookup in YieldCurves
  #     `Spot Rate (Unlinked)(Locked-in Date, (Reporting Date-Locked-in Date)+min[Delay, Reporting Period])` = case_when(
  #       Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,  # If both are No, return 0
  #       TRUE ~ as.numeric(
  #         YieldCurves %>%
  #           filter(`Yield curve link` == YieldCurveKey) %>%
  #           select(any_of(LookupIndex)) %>%
  #           pull()
  #       )
  #     )
  #   )
  # # Ensure required columns in R_I_SUB_Disc1 are in the correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Locked-in YC Date` = as.Date(`Locked-in YC Date`, origin = "1899-12-30"),
  #     `Reporting Date` = as.Date(`Reporting Date`, origin = "1899-12-30"),
  #     `Delay (in Years)` = as.numeric(`Delay (in Years)`),
  #     `Currency` = as.character(`Currency`),
  #     `GRC Code` = as.character(`GRC Code`),
  #     
  #     # Extracting Scope_LinkedCashflows from Setup$F12
  #     Scope_LinkedCashflows = as.character(setup_data[12, 5]),
  #     
  #     # Compute "Spot Rate (Linked)"
  #     `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)` = case_when(
  #       Scope_LinkedCashflows == "Yes" ~ case_when(
  #         Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,
  #         TRUE ~ {
  #           lookup_key <- paste0(
  #             `Locked-in YC Date`, "_", `Currency`, "_Linked",
  #             if_else(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GRC Code`), "")
  #           )
  #           
  #           lookup_value <- tryCatch({
  #             match_index <- which(yield_curves$`Yield curve link` == lookup_key)
  #             if (length(match_index) > 0) {
  #               delay_period <- min(`Delay (in Years)`, (ReportingDate_Current - ReportingDate_Previous) / 365.25)
  #               col_index <- round((as.numeric(ReportingDate_Current - `Locked-in YC Date`) / 365.25 + delay_period) * 12, 0)
  #               
  #               as.numeric(yield_curves[match_index, col_index, drop = TRUE])
  #             } else {
  #               0
  #             }
  #           }, error = function(e) 0)
  #           
  #           lookup_value
  #         }
  #       ),
  #       TRUE ~ 0  # Default case
  #     )
  #   )
  # # Extract values from the Setup sheet
  # Scope_LinkedCashflows <- as.character(setup_data[12, 5])  # F12
  # Scope_Insurance <- as.character(setup_data[7, 5])         # F7
  # Scope_R_IF_GEN_LR <- as.character(setup_data[15, 5])     # F15
  # Option_GranularYC <- as.character(setup_data[24, 5])     # F24
  # 
  # # Ensure columns in R_I_SUB_Disc1 have correct data formats
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Locked-in YC Date` = as.Date(`Locked-in YC Date`),
  #     `Reporting Date` = as.Date(`Reporting Date`),
  #     `Delay (in Years)` = as.numeric(`Delay (in Years)`)
  #   )
  # 
  # # Compute the new column
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date))` = case_when(
  #       Scope_LinkedCashflows == "Yes" ~ case_when(
  #         Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,
  #         TRUE ~ {
  #           lookup_key <- paste0(
  #             `Locked-in YC Date`, "_", `Currency`, "_Linked",
  #             if_else(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GRC Code`), "")
  #           )
  #           
  #           # Compute lookup index for YieldCurves sheet
  #           lookup_index <- round(
  #             trunc((as.numeric(`Reporting Date`) - as.numeric(`Locked-in YC Date`)) / 365.25 +
  #                     `Delay (in Years)`) * 12, 0
  #           )
  #           
  #           # Fetch spot rate from YieldCurves
  #           spot_rate <- YieldCurves %>%
  #             filter(`Yield curve link` == lookup_key) %>%
  #             select(all_of(as.character(lookup_index))) %>%
  #             pull()
  #           
  #           ifelse(length(spot_rate) > 0, spot_rate, 0)
  #         }
  #       ),
  #       TRUE ~ 0
  #     )
  #   )
  # library(dplyr)
  # library(lubridate)
  # 
  # # Ensure required columns in R_I_SUB_Disc1 are in the correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Reporting Date` = as.Date(`Reporting Date`, origin = "1899-12-30"),
  #     `Locked-in YC Date` = as.Date(`Locked-in YC Date`, origin = "1899-12-30"),
  #     `Delay (in Years)` = as.numeric(`Delay (in Years)`),
  #     `GRC Code` = as.character(`GRC Code`),
  #     `Currency` = as.character(`Currency`)
  #   )
  # 
  # # Ensure Setup values are correctly extracted
  # Scope_LinkedCashflows <- as.character(setup_data[12, 5]) # F12
  # Scope_Insurance <- as.character(setup_data[7, 5]) # F7
  # Scope_R_IF_GEN_LR <- as.character(setup_data[15, 5]) # F15
  # Option_GranularYC <- as.character(setup_data[24, 5]) # F24
  # 
  # # Extract Reporting Dates from Setup
  # ReportingDate_Current <- as.Date(setup_data[3, 5], origin = "1899-12-30") # F3
  # ReportingDate_Previous <- as.Date(setup_data[2, 5], origin = "1899-12-30") # F2
  # 
  # # Compute the new column
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + min[Delay, Reporting Period])` =
  #       case_when(
  #         Scope_LinkedCashflows == "No" ~ 0,
  #         Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,
  #         TRUE ~ {
  #           # Construct the lookup key for YieldCurves
  #           lookup_key <- paste0(
  #             `Locked-in YC Date`, "_",
  #             `Currency`, "_",
  #             "Linked",
  #             ifelse(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GRC Code`), "")
  #           )
  #           
  #           # Compute the time difference and apply the MIN function
  #           time_diff <- as.numeric(difftime(`Reporting Date`, `Locked-in YC Date`, units = "days")) / 365.25
  #           min_delay <- pmin(`Delay (in Years)`, as.numeric(difftime(ReportingDate_Current, ReportingDate_Previous, units = "days")) / 365.25)
  #           
  #           # Compute the lookup index in YieldCurves
  #           lookup_index <- round((trunc(time_diff) + min_delay) * 12, 0)
  #           
  #           # Fetch the spot rate from YieldCurves
  #           spot_rate <- YieldCurves %>%
  #             filter(`Yield curve link` == lookup_key) %>%
  #             select(lookup_index) %>%
  #             pull()
  #           
  #           # Ensure spot_rate has correct length and replace missing values with 0
  #           if (length(spot_rate) == 0) spot_rate <- 0
  #           
  #           spot_rate
  #         }
  #       )
  #   )
  # library(dplyr)
  # 
  # # Ensure required columns are in the correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Reporting Date` = as.Date(`Reporting Date`),
  #     `Locked-in YC Date` = as.Date(`Locked-in YC Date`),
  #     `Delay (in Years)` = as.numeric(`Delay (in Years)`),
  #     `Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = as.numeric(`Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
  #     `Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = as.numeric(`Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`)
  #   )
  # 
  # # Compute Discounted CFs for Incurred Next Reporting Period
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Discounted Treaty covered Claim and Other CFs (Incurred in Next Reporting Period)(Locked-in YC, t0)` = 
  #       (`Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` *
  #          ((1 + `Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #             (-(`Delay (in Years)` + (`Reporting Date` - `Locked-in YC Date`) / 365.25)))) + 
  #       (`Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` *
  #          ((1 + `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #             (-(`Delay (in Years)` + (`Reporting Date` - `Locked-in YC Date`) / 365.25))))
  #   )
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, t0)` = 
  #       `Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` *
  #       ((1 + `Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #          (-`Delay (in Years)` + (`Reporting Date` - `Locked-in YC Date`)/365.25)) +
  #       
  #       `Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` * 
  #       ((1 + `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #          (-`Delay (in Years)` + (`Reporting Date` - `Locked-in YC Date`)/365.25))
  #   )
  # # Ensure the required columns are in the correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     # Discounted Treaty covered Claim and Other CFs (Incurred in the Future)(Locked-in YC, t0)
  #     `Discounted Treaty covered Claim and Other CFs (Incurred in the Future)(Locked-in YC, t0)` =
  #       `Discounted Treaty covered Claim and Other CFs (Incurred in Next Reporting Period)(Locked-in YC, t0)` +
  #       `Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, t0)`
  #   )
  # 
  # # Ensure required columns are in the correct format
  # R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  #   mutate(
  #     `Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, t1)` = 
  #       (`Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` * 
  #          ((1 + `Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #             (-pmin(`Delay (in Years)`, round((ReportingDate_Current - ReportingDate_Previous) / 365.25, 2)) + 
  #                (`Reporting Date` - `Locked-in YC Date`) / 365.25))) +
  #       (`Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` * 
  #          ((1 + `Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)`) ^ 
  #             (-pmin(`Delay (in Years)`, round((ReportingDate_Current - ReportingDate_Previous) / 365.25, 2)) + 
  #                (`Reporting Date` - `Locked-in YC Date`) / 365.25)))
  #   )
  # 
  df <- read.xlsx("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "R_I_SUB_Disc1")
  
  Treaty_covered_CF_Unlinked_Next_Period <- df$`Treaty.covered.Claim.and.Other.CFs.(Unlinked)(Incurred.in.Next.Reporting.Period)(Locked-in.Financial.Assumptions.and.NP.Risk)(Current.Discretion)`
  colnames(df)  
  Spot_Rate_Unlinked_Locked_in_Delay <- df$`Spot.Rate.(Unlinked)(Locked-in.Date,.(Reporting.Date.-.Locked-in.Date).+.Delay)`
  Delay_in_Years <- df$`Delay.(in.Years)`
  Reporting_Date <- df$Reporting.Date
  Locked_in_YC_Date <- df$`Locked-in.YC.Date`
  Spot_Rate_Unlinked_Locked_in_Date <- df$`Spot.Rate.(Unlinked)(Locked-in.Date,.(Reporting.Date.-.Locked-in.Date))`
  Treaty_covered_CF_Linked_Next_Period <- df$`Treaty.covered.Claim.and.Other.CFs.(linked)(Incurred.in.Next.Reporting.Period)(Locked-in.Financial.Assumptions.and.NP.Risk)(Current.Discretion)`
  Spot_Rate_Linked_Locked_in_Delay <- df$`Spot.Rate.(Linked)(Locked-in.Date,.(Reporting.Date.-.Locked-in.Date).+.Delay)`
  Spot_Rate_Linked_Locked_in_Date <- df$`Spot.Rate.(Linked)(Locked-in.Date,.(Reporting.Date.-.Locked-in.Date))`
  
  
  required_rows <- 2400
  current_rows <- nrow(R_I_SUB_Disc1)
  
  
  if (current_rows < required_rows) {
    missing_rows <- required_rows - current_rows
    empty_rows <- R_I_SUB_Disc1[1, ]  
    empty_rows[] <- NA  
    R_I_SUB_Disc1 <- bind_rows(R_I_SUB_Disc1, empty_rows[rep(1, missing_rows), ])
  }
  
  
  R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
    mutate(
      Treaty_covered_CF_Unlinked_Next_Period = rep(
        ifelse(is.na(Treaty_covered_CF_Unlinked_Next_Period), 0, Treaty_covered_CF_Unlinked_Next_Period),
        length.out = required_rows
      ),
      Treaty_covered_CF_Linked_Next_Period = rep(
        ifelse(is.na(Treaty_covered_CF_Linked_Next_Period), 0, Treaty_covered_CF_Linked_Next_Period),
        length.out = required_rows
      ),
      Spot_Rate_Unlinked_Locked_in_Delay = rep(
        ifelse(is.na(Spot_Rate_Unlinked_Locked_in_Delay), 0, Spot_Rate_Unlinked_Locked_in_Delay),
        length.out = required_rows
      ),
      Spot_Rate_Unlinked_Locked_in_Date = rep(
        ifelse(is.na(Spot_Rate_Unlinked_Locked_in_Date), 0, Spot_Rate_Unlinked_Locked_in_Date),
        length.out = required_rows
      ),
      Spot_Rate_Linked_Locked_in_Delay = rep(
        ifelse(is.na(Spot_Rate_Linked_Locked_in_Delay), 0, Spot_Rate_Linked_Locked_in_Delay),
        length.out = required_rows
      ),
      Spot_Rate_Linked_Locked_in_Date = rep(
        ifelse(is.na(Spot_Rate_Linked_Locked_in_Date), 0, Spot_Rate_Linked_Locked_in_Date),
        length.out = required_rows
      ),
      Delay_in_Years = rep(
        ifelse(is.na(Delay_in_Years), 0, Delay_in_Years),
        length.out = required_rows
      ),
      Reporting_Date = rep(
        as.Date(ifelse(is.na(Reporting_Date), "1900-01-01", Reporting_Date), origin = "1899-12-30"),
        length.out = required_rows
      ),
      Locked_in_YC_Date = rep(
        as.Date(ifelse(is.na(Locked_in_YC_Date), "1900-01-01", Locked_in_YC_Date), origin = "1899-12-30"),
        length.out = required_rows
      ),
    
      
      Discounted_CF_Next_Period = rep(
        ifelse(
          is.na(Treaty_covered_CF_Unlinked_Next_Period) | is.na(Treaty_covered_CF_Linked_Next_Period), 
          0,
          Treaty_covered_CF_Unlinked_Next_Period * 
            ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
              Delay_in_Years + as.numeric(Reporting_Date - Locked_in_YC_Date) / 365.25)) *
            ((1 + Spot_Rate_Unlinked_Locked_in_Date)^(
              as.numeric(Reporting_Date - Locked_in_YC_Date) / 365.25)) +
            
            Treaty_covered_CF_Linked_Next_Period * 
            ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
              Delay_in_Years + as.numeric(Reporting_Date - Locked_in_YC_Date) / 365.25)) *
            ((1 + Spot_Rate_Linked_Locked_in_Date)^(
              as.numeric(Reporting_Date - Locked_in_YC_Date) / 365.25))
        ),
        length.out = required_rows
      )
    )
  Treaty_covered_CF_Unlinked_Future_Periods <- df$`Treaty.covered.Claim.and.Other.CFs.(Unlinked)(Incurred.in.Future.Reporting.Period)(Locked-in.Financial.Assumptions.and.NP.Risk)(Current.Discretion)`
  Treaty_covered_CF_Linked_Future_Periods <- df$`Treaty.covered.Claim.and.Other.CFs.(Linked)(Incurred.in.Future.Reporting.Periods)(Locked-in.Financial.Assumptions.and.NP.Risk)(Current.Discretion)`
  
  library(dplyr)
  
  # Ensure R_I_SUB_Disc1 has at least 2400 rows before processing
  if (nrow(R_I_SUB_Disc1) < 2400) {
    missing_rows <- 2400 - nrow(R_I_SUB_Disc1)
    empty_df <- R_I_SUB_Disc1[1, , drop = FALSE]  # Copy structure
    empty_df[] <- NA  # Set all values to NA
    R_I_SUB_Disc1 <- bind_rows(R_I_SUB_Disc1, empty_df[rep(1, missing_rows), ])
  }
  
  # Ensure all necessary columns exist, if missing, create them and fill with NA
  required_columns <- c(
    "Treaty_covered_CF_Unlinked_Future_Periods",
    "Treaty_covered_CF_Linked_Future_Periods",
    "Spot_Rate_Unlinked_Locked_in_Delay",
    "Spot_Rate_Unlinked_Locked_in_Date",
    "Spot_Rate_Linked_Locked_in_Delay",
    "Spot_Rate_Linked_Locked_in_Date",
    "Delay_in_Years",
    "Reporting_Date",
    "Locked_in_YC_Date"
  )
  
  # Create missing columns
  for (col in required_columns) {
    if (!col %in% names(R_I_SUB_Disc1)) {
      R_I_SUB_Disc1[[col]] <- NA  # Fill missing columns with NA
    }
  }
  
  # Ensure correct data types and replace NAs
  R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
    mutate(
      Reporting_Date = as.Date(Reporting_Date, origin = "1899-12-30"),
      Locked_in_YC_Date = as.Date(Locked_in_YC_Date, origin = "1899-12-30"),
      Reporting_Locked_Diff = as.numeric(difftime(Reporting_Date, Locked_in_YC_Date, units = "days")) / 365.25,
      
      # Replace NAs with 0
      Treaty_covered_CF_Unlinked_Future_Periods = ifelse(is.na(Treaty_covered_CF_Unlinked_Future_Periods), 0, Treaty_covered_CF_Unlinked_Future_Periods),
      Treaty_covered_CF_Linked_Future_Periods = ifelse(is.na(Treaty_covered_CF_Linked_Future_Periods), 0, Treaty_covered_CF_Linked_Future_Periods),
      Spot_Rate_Unlinked_Locked_in_Delay = ifelse(is.na(Spot_Rate_Unlinked_Locked_in_Delay), 0, Spot_Rate_Unlinked_Locked_in_Delay),
      Spot_Rate_Unlinked_Locked_in_Date = ifelse(is.na(Spot_Rate_Unlinked_Locked_in_Date), 0, Spot_Rate_Unlinked_Locked_in_Date),
      Spot_Rate_Linked_Locked_in_Delay = ifelse(is.na(Spot_Rate_Linked_Locked_in_Delay), 0, Spot_Rate_Linked_Locked_in_Delay),
      Spot_Rate_Linked_Locked_in_Date = ifelse(is.na(Spot_Rate_Linked_Locked_in_Date), 0, Spot_Rate_Linked_Locked_in_Date),
      Delay_in_Years = ifelse(is.na(Delay_in_Years), 0, Delay_in_Years)
    ) %>%
    mutate(
      # Compute Discounted_CF_Future_Periods
      Discounted_CF_Future_Periods = 
        Treaty_covered_CF_Unlinked_Future_Periods * 
        ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
          Delay_in_Years + Reporting_Locked_Diff)) *
        ((1 + Spot_Rate_Unlinked_Locked_in_Date)^Reporting_Locked_Diff) +
        
        Treaty_covered_CF_Linked_Future_Periods * 
        ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
          Delay_in_Years + Reporting_Locked_Diff)) *
        ((1 + Spot_Rate_Linked_Locked_in_Date)^Reporting_Locked_Diff)
    )
  
  
  
################################################ R_SUB_DISC1

library(dplyr)

  library(dplyr)
  
  # Ensure correct number of rows
  n_rows <- nrow(R_SUB_Disc1)
  
  R_SUB_Disc1 <- R_SUB_Disc1 %>%
    # Populate `Reporting Date` and `GRC Code`
    mutate(
      `Reporting Date` = R_IF_FCFs$`Reporting Date`[1:n_rows],
      `GRC Code` = R_IF_FCFs$`GRC Code`[1:n_rows]
    ) %>%
    # Join with `R_Groups` to get `Currency` and `Locked-in YC Date`
    left_join(
      R_Groups %>%
        select(`GRC Code`, `Currency`, `Locked-in YC Date`),
      by = "GRC Code"
    ) %>%
    # Populate other columns with `case_when()`
    mutate(
      `Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
        Scope_LockedInAssumptions == "No" ~ R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`[1:n_rows],
        TRUE ~ R_IF_FCFs$`Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows]
      ),
      
      `Premium CFs (Unlinked)(Past Service) - Prev FX` = case_when(
        Scope_LockedInAssumptions == "No" ~ R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`[1:n_rows],
        TRUE ~ R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Prev FX`[1:n_rows]
      ),
      
      `Premium CFs (Unlinked)(Past Service) - Current FX` = R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`[1:n_rows],
      
      `Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
        Scope_LockedInAssumptions == "No" ~ R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`[1:n_rows],
        TRUE ~ R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows]
      ),
      
      `Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX` = case_when(
        Scope_LockedInAssumptions == "No" ~ R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`[1:n_rows],
        TRUE ~ R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX`[1:n_rows]
      ),
      
      `Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX` = R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`[1:n_rows],
      
      `Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
        Scope_LockedInAssumptions == "No" ~ R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Current FX`[1:n_rows],
        TRUE ~ R_IF_FCFs$`Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows]
      )
    )


library(dplyr)
library(tidyr)  # For replace_na()

# Get the number of rows in R_SUB_Disc1
n_rows <- nrow(R_SUB_Disc1)

R_SUB_Disc1 <- R_SUB_Disc1 %>%
  mutate(
    `Premium CFs (Unlinked)(Future Service) - Prev FX` = case_when(
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Unlinked)(Future Service) - Current FX`, 0),
      TRUE ~ replace_na(R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Prev FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Unlinked)(Future Service) - Current FX` = replace_na(R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Current FX`[1:n_rows], 0),
    
    # Investment Component CFs
    `Investment Component CFs (Unlinked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
      Scope_LockedInAssumptions == "No" ~ replace_na(R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows], 0)
    ),
    
    `Investment Component CFs (Unlinked)(Receivable in Future) - Prev FX` = case_when(
      Scope_LockedInAssumptions == "No" ~ replace_na(R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Prev FX`[1:n_rows], 0)
    ),
    
    `Investment Component CFs (Unlinked)(Receivable in Future) - Current FX` = replace_na(R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`[1:n_rows], 0),
    
    # Recoveries CFs
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = replace_na(R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = replace_na(R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = replace_na(R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = replace_na(R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX` = replace_na(R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX`[1:n_rows], 0)
  )


library(dplyr)

# Ensure correct number of rows
n_rows <- nrow(R_SUB_Disc1)

R_SUB_Disc1 <- R_SUB_Disc1 %>%
  mutate(
    # Recoveries CFs (Unlinked) for Previous NP Risk
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX`[1:n_rows], 0),
    
    # Recoveries CFs (Unlinked) for Current NP Risk
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX`[1:n_rows], 0),
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX` = replace_na(
      R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX`[1:n_rows], 0),
    
    # Premium CFs (Linked) with conditional logic
    `Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Past Service) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(R_IF_FCFs$`Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows], 0)
    )
  )
library(dplyr)

# Ensure correct number of rows
n_rows <- nrow(R_IF_FCFs)

R_IF_FCFs <- R_IF_FCFs %>%
  mutate(
    `Premium CFs (Linked)(Past Service) - Prev FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Past Service) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Premium CFs (Linked)(Past Service) - Prev FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Past Service) - Current FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      TRUE ~ replace_na(`Premium CFs (Linked)(Past Service) - Current FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Service in Next Reporting Period) - Current FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      TRUE ~ replace_na(`Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Future Service) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Future Service) - Prev FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Premium CFs (Linked)(Future Service) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Premium CFs (Linked)(Future Service) - Prev FX`[1:n_rows], 0)
    ),
    
    `Premium CFs (Linked)(Future Service) - Current FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      TRUE ~ replace_na(`Premium CFs (Linked)(Future Service) - Current FX`[1:n_rows], 0)
    ),
    
    `Investment Component CFs (Linked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Investment Component CFs (Linked)(Receivable in Future) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Investment Component CFs (Linked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)`[1:n_rows], 0)
    ),
    
    `Investment Component CFs (Linked)(Receivable in Future) - Prev FX` = case_when(
      Scope_LinkedCashflows == "No" ~ 0,
      Scope_LockedInAssumptions == "No" ~ replace_na(`Investment Component CFs (Linked)(Receivable in Future) - Current FX`[1:n_rows], 0),
      TRUE ~ replace_na(`Investment Component CFs (Linked)(Receivable in Future) - Prev FX`[1:n_rows], 0)
    )
  )

library(dplyr)

R_SUB_Disc1 <- R_SUB_Disc1 %>%
  mutate(
    `Investment Component CFs (Linked)(Receivable in Future) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Investment Component CFs (Linked)(Receivable in Future) - Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk)- Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX`)
  )

###################################R_SUB_ToSL
library(dplyr)

library(dplyr)

# Perform the lookup for multiple columns
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Interest Accreted on ARC - CSM - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Interest Accreted on ARC - CSM - Actuals FX`))
    ),
    
    `Effect on ARC - CSM - Total Experience Variance (Future - Non FX) - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARC - CSM - Total Experience Variance (Future - Non FX) - Current FX`))
    ),
    
    `Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC - Current FX`))
    ),
    
    `Release in ARC - CSM - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Release in ARC - CSM - Actuals FX`))
    ),
    
    `Interest Accreted on ARC - PVFCF - Loss Recovery - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Interest Accreted on ARC - PVFCF - Loss Recovery - Actuals FX`))
    ),
    
    `Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences - Current FX`))
    ),
    
    `Interest Accreted on ARIC - PVFCF - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Interest Accreted on ARIC - PVFCF - Actuals FX`))
    ),
    
    `Effect on ARIC - PVFCF of Change in NP Risk - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARIC - PVFCF of Change in NP Risk - Current FX`))
    ),
    
    `Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX`))
    ),
    
    `Recoveries Receipts - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Recoveries Receipts - Actuals FX`))
    ),
    
    `Interest Accreted on ARIC - RA - OCI - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Interest Accreted on ARIC - RA - OCI - Actuals FX`))
    ),
    
    `Effect on ARIC - RA of Change in Exchange Rates - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Effect on ARIC - RA of Change in Exchange Rates - Current FX`))
    ),
    
    `Investment Component Receipts - Actuals FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Investment Component Receipts - Actuals FX`))
    ),
    
    `Impairment of PRCF Liability - Current FX` = list(
      as.numeric(R_FX %>%
                   filter(R_FX$`GRC Code` == R_SUB_ToSL$`GRC Code`) %>%
                   pull(`Impairment of PRCF Liability - Current FX`))
    )
  )


###################################### R_SUB_ToT0TB


library(dplyr)

R_SUB_ToT0TB <- R_SUB_ToT0TB %>%
  rowwise() %>%
  mutate(
    GRC_Code = `GRC Code`, 
    Portfolio = `Portfolio`,
    
    # Correcting the Asset / Liability Calculation
    `Asset / Liability` = list(ifelse(
      rowSums(select(R_SUB_ToT0TB, `ARC - PVFCF - Non-Loss Recovery`:`ARIC - IC`) != "", na.rm = TRUE) >= 0, 
      "Asset", 
      "Liability"
    )),
    
    `ARC - PVFCF - Non-Loss Recovery` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARC - PVFCF - Non-Loss Recovery - Current FX`),
      NA_real_
    )),
    
    `ARC - RA` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARC - RA - Current FX`),
      NA_real_
    )),
    
    `ARC - CSM` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARC - CSM - Current FX`),
      NA_real_
    )),
    
    `ARC - PVFCF - Loss Recovery` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARC - PVFCF - Loss Recovery - Current FX`),
      NA_real_
    )),
    
    `ARC - PRCF` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARC - PRCF - Current FX`),
      NA_real_
    )),
    
    `ARIC - PVFCF` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARIC - PVFCF - Current FX`),
      NA_real_
    )),
    
    `ARIC - RA` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARIC - RA - Current FX`),
      NA_real_
    )),
    
    `ARIC - IC` = list(ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(`Closing ARIC - IC - Current FX`),
      NA_real_
    ))
  ) %>%
  ungroup()



 ##################################### R_IN_Pre_FX

 R_IN_Pre_FX <- R_IN_Pre_FX %>%
  mutate(
    # GRC Code column remains unchanged, as it's already populated

    # Transfer of Pre-recognition CFs (Purchased)
    `Transfer of Pre-recognition CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `Pre-recognition CFs`, 0)
    ),

    # Transfer of Pre-recognition CFs (Purchased)(2)
    `Transfer of Pre-recognition CFs (Purchased)(2)` = `Transfer of Pre-recognition CFs (Purchased)`,  # Same as the previous column

    # New ARC - Premium CFs (Purchased)
    `New ARC - Premium CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `New ARC - Premium CFs`, 0)
    ),

    # New ARC - Investment Component CFs (Purchased)
    `New ARC - Investment Component CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `New ARC - Investment Component CFs`, 0)
    ),

    # New ARC - Recoveries CFs (Purchased)
    `New ARC - Recoveries CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", R_IN_Calc$`New ARC - Recoveries CFs`, 0)
    ),

    # New ARC - RA (Purchased)
    `New ARC - RA (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `New ARC - RA`, 0)
    ),

    # New ARC - CSM - Non-Loss Recovery (Purchased)
    `New ARC - CSM - Non-Loss Recovery (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `New ARC - CSM - Non-loss-recovery`, 0)
    ),

    # New ARC - Loss recovery (Purchased)
    `New ARC - Loss recovery (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", R_SUB_Calc$`New ARC - Loss recovery`, 0)
    ),

    # New ARC - CSM (Purchased)
    `New ARC - CSM (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Purchased", `New ARC - CSM`, 0)
    ),

    # Transfer of Pre-recognition CFs (Acquired)
    `Transfer of Pre-recognition CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `Pre-recognition CFs`, 0)
    ),

    # Transfer of Pre-recognition CFs (Acquired)(2)
    `Transfer of Pre-recognition CFs (Acquired)(2)` = `Transfer of Pre-recognition CFs (Acquired)`,  # Same as the previous column

    # New ARC - Premium CFs (Acquired)
    `New ARC - Premium CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `New ARC - Premium CFs`, 0)
    ),

    # New ARC - Investment Component CFs (Acquired)
    `New ARC - Investment Component CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `New ARC - Investment Component CFs`, 0)
    ),

    # New ARC - Recoveries CFs (Acquired)
    `New ARC - Recoveries CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", R_IN_Calc$`New ARC - Recoveries CFs`, 0)
    ),

    # New ARC - RA (Acquired)
    `New ARC - RA (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `New ARC - RA`, 0)
    ),

    # New ARC - CSM - Non-Loss Recovery (Acquired)
    `New ARC - CSM - Non-Loss Recovery (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `New ARC - CSM - Non-loss-recovery`, 0)
    ),

    # New ARC - Loss recovery (Acquired)
    `New ARC - Loss recovery (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", R_SUB_Calc$`New ARC - Loss recovery`, 0)
    ),

    # New ARC - CSM (Acquired)
    `New ARC - CSM (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(R_IN_Calc$Purchased_Acquired == "Acquired", `New ARC - CSM`, 0)
    )
  )

# Configure data acquisition parameters for "R_FX"

data_acquisition_params <- list(

  source_path = wb$path,

  target_sheet = "R_FX",

  protocol = "xlsx_v12",

  validation_level = 2L

)
 
# Execute multi-threaded data extraction protocol

execute_extraction <- function(params) {

  withCallingHandlers({

    suppressMessages({

      readxl::read_excel(

        path = params$source_path,

        sheet = params$target_sheet,

        .name_repair = "unique"

      )

    })

  }, warning = function(w) invokeRestart("muffleWarning"))

}
 
# Initialize data container for "R_FX"

R_FX <- local({

  temp_env <- new.env(parent = emptyenv())

  temp_env$result <- execute_extraction(data_acquisition_params)

  temp_env$result

})

 
# Configure data acquisition parameters for "R_I_IN_Disc"

data_acquisition_params <- list(

  source_path = wb$path,

  target_sheet = "R_I_IN_Disc",

  protocol = "xlsx_v12",

  validation_level = 2L

)
 
# Execute multi-threaded data extraction protocol

execute_extraction <- function(params) {

  withCallingHandlers({

    suppressMessages({

      readxl::read_excel(

        path = params$source_path,

        sheet = params$target_sheet,

        .name_repair = "unique"

      )

    })

  }, warning = function(w) invokeRestart("muffleWarning"))

}
 
# Initialize data container for "R_I_IN_Disc"

R_I_IN_Disc <- local({

  temp_env <- new.env(parent = emptyenv())

  temp_env$result <- execute_extraction(data_acquisition_params)

  temp_env$result

})

 
# Configure data acquisition parameters for "R_IN_Disc"

data_acquisition_params <- list(

  source_path = wb$path,

  target_sheet = "R_IN_Disc",

  protocol = "xlsx_v12",

  validation_level = 2L

)
 
# Execute multi-threaded data extraction protocol

execute_extraction <- function(params) {

  withCallingHandlers({

    suppressMessages({

      readxl::read_excel(

        path = params$source_path,

        sheet = params$target_sheet,

        .name_repair = "unique"

      )

    })

  }, warning = function(w) invokeRestart("muffleWarning"))

}
 
# Initialize data container for "R_IN_Disc"

R_IN_Disc <- local({

  temp_env <- new.env(parent = emptyenv())

  temp_env$result <- execute_extraction(data_acquisition_params)

  temp_env$result

})

 
# Configure data acquisition parameters for "R_IN_LR"

data_acquisition_params <- list(

  source_path = wb$path,

  target_sheet = "R_IN_LR",

  protocol = "xlsx_v12",

  validation_level = 2L

)
 
# Execute multi-threaded data extraction protocol

execute_extraction <- function(params) {

  withCallingHandlers({

    suppressMessages({

      readxl::read_excel(

        path = params$source_path,

        sheet = params$target_sheet,

        .name_repair = "unique"

      )

    })

  }, warning = function(w) invokeRestart("muffleWarning"))

}
 
# Initialize data container for "R_IN_LR"

R_IN_LR <- local({

  temp_env <- new.env(parent = emptyenv())

  temp_env$result <- execute_extraction(data_acquisition_params)

  temp_env$result

})

 ###################################### R_IN_Calc

 library(dplyr)
# Mutate R_IN_Calc
R_IN_Calc <- R_IN_Calc %>%
  mutate(
    `GRC Code` = R_NEW_GEN$`GRC Code`,
    `Purchased/Acquired` = R_NEW_GEN$`Purchased/Acquired`,
    `Pre-recognition CFs` = R_NEW_GEN$`Pre-recognition CFs`,
    
    # New ARC - Premium CFs (Current Service)
    `New ARC - Premium CFs (Current Service)` = -sum(R_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)`[
      R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
        R_IN_Disc$`GRC Code` == `GRC Code`
    ]),
    
    # New ARC - Premium CFs (Future Service)
    `New ARC - Premium CFs (Future Service)` = -sum(R_IN_Disc$`Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)`[
      R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
        R_IN_Disc$`GRC Code` == `GRC Code`
    ]),
    
    # New ARC - Premium CFs
    `New ARC - Premium CFs` = `New ARC - Premium CFs (Current Service)` + `New ARC - Premium CFs (Future Service)`,
    
    # New ARC - Investment Component CFs
    `New ARC - Investment Component CFs` = -sum(R_IN_Disc$`Discounted Investment Component CFs (Locked-in YC, Locked-in Date)`[
      R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
        R_IN_Disc$`GRC Code` == `GRC Code`
    ]),
    
    # New ARC - Recoveries CFs
    R_IN_Calc$`New ARC - Recoveries CFs` <- -sum(R_IN_Disc$`Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)`[
      R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
        R_IN_Disc$`GRC Code` == `GRC Code`
    ]) +
      -sum(R_IN_Disc$`Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)`[
        R_IN_Disc$`Reporting Date` == ReportingDate_Current & 
          R_IN_Disc$`GRC Code` == `GRC Code`
      ]),
    
    # New ARC - PVFCF
    R_IN_Calc$`New ARC - PVFCF` <- `New ARC - Premium CFs` + R_IN_Calc$`New ARC - Recoveries CFs`,
    
    # RA % of ABS(PVFCF Recoveries)
    R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- if_else(
      Scope_Reins_NUB == "No", 
      0,
      if_else(
        Option_RASimplification == "Yes", 
        sum(R_Groups$`RA % of ABS(PVFCF)`[R_Groups$`GRC Code` == `GRC Code`], na.rm = TRUE), 
        0
      )
    ) # <- Removed extra comma here
  )

library(dplyr)

# Ensure extracted columns are numeric vectors
RA_PVFCF <- as.numeric(unlist(R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)`))
New_ARC_Recov <- as.numeric(unlist(R_IN_Calc$`New ARC - Recoveries CFs`))
New_ARC_PVFCF <- as.numeric(unlist(R_IN_Calc$`New ARC - PVFCF`))
Retroactive_Cover <- as.character(unlist(R_IN_Calc$`Retroactive Cover?`))  # Convert to character for logical comparison
Initial_RA <- as.numeric(unlist(R_NEW_GEN$`Initial RA`))

# Ensure all extracted vectors match the row count of R_SUB_ToT0TB
RA_PVFCF <- rep_len(RA_PVFCF, nrow(R_SUB_ToT0TB))
New_ARC_Recov <- rep_len(New_ARC_Recov, nrow(R_SUB_ToT0TB))
New_ARC_PVFCF <- rep_len(New_ARC_PVFCF, nrow(R_SUB_ToT0TB))
Retroactive_Cover <- rep_len(Retroactive_Cover, nrow(R_SUB_ToT0TB))
Initial_RA <- rep_len(Initial_RA, nrow(R_SUB_ToT0TB))

# Apply the corrected mutate() function
R_SUB_ToT0TB <- R_SUB_ToT0TB %>%
  mutate(
    `New ARC - RA` = case_when(
      Scope_Reinsurance == "Yes" & Scope_Reins_NUB == "Yes" & RA_PVFCF == 0 ~ Initial_RA,
      Scope_Reinsurance == "Yes" & Scope_Reins_NUB == "Yes" ~ abs(New_ARC_Recov) * RA_PVFCF,
      TRUE ~ 0  # Default case
    ),
    
    # New ARC - FCF calculation
    `New ARC - FCF` = New_ARC_PVFCF + `New ARC - RA`,
    
    # Retroactive Cover?
    `Retroactive Cover?` = case_when(
      Scope_Reins_NUB == "No" ~ 0,
      Retroactive_Cover == "Yes" ~ R_NEW_GEN$`Pre-recognition CFs`,
      TRUE ~ -`New ARC - FCF`
    )
  )

library(dplyr)

# Ensure the extracted data has the correct length
New_ARC_CSM_Non_Loss_Recov <- as.numeric(unlist(R_IN_Calc$`New ARC - CSM - Non-loss-recovery`))
New_ARC_Loss_Recov <- as.numeric(unlist(R_IN_Calc$`New ARC - Loss recovery`))

# Extend vectors to match the row count of R_SUB_Calc
New_ARC_CSM_Non_Loss_Recov <- rep_len(New_ARC_CSM_Non_Loss_Recov, nrow(R_SUB_Calc))
New_ARC_Loss_Recov <- rep_len(New_ARC_Loss_Recov, nrow(R_SUB_Calc))

# Compute the missing values while ensuring correct vector sizes
R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `New ARC - CSM - Non-loss-recovery` = sum(
      New_ARC_CSM_Non_Loss_Recov[R_SUB_Calc$`GRC Code` == R_IN_Calc$`GRC Code`], na.rm = TRUE
    ),
    
    `New ARC - Loss recovery` = New_ARC_CSM_Non_Loss_Recov + New_ARC_Loss_Recov,
    
    `New ARC - CSM` = New_ARC_CSM_Non_Loss_Recov + New_ARC_Loss_Recov
  )


# Configure data acquisition parameters for "YieldCurves"
data_acquisition_params <- list(
  source_path = wb$path,
  target_sheet = "YieldCurves",
  protocol = "xlsx_v12",
  validation_level = 2L
)

# Execute multi-threaded data extraction protocol
execute_extraction <- function(params) {
  withCallingHandlers({
    suppressMessages({
      readxl::read_excel(
        path = params$source_path,
        sheet = params$target_sheet,
        .name_repair = "unique"
      )
    })
  }, warning = function(w) invokeRestart("muffleWarning"))
}

# Initialize data container for YieldCurves
YieldCurves <- local({
  temp_env <- new.env(parent = emptyenv())  # Create an isolated environment
  temp_env$result <- execute_extraction(data_acquisition_params)  # Run extraction
  temp_env$result  # Return the extracted data
})
# Ensure Group Code is character for matching



#################################Subledger
library(dplyr)
library(readxl)
library(tidyr)

# 🔹 Load Workbook and Setup Sheet
wb_path <- "C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm"
wb <- wb_load(wb_path)
Setup <- wb_to_df(wb, "Setup")

# 🔹 Extract Reporting Date (Excel date format)
ReportingDate_Current <- Setup[[5]][2]  # Column 5, Row 2
Date_Value <- ReportingDate_Current     # Date will be added to Subledger later

# 🔹 Load Valid Transaction Types
TransactionTypes <- read_excel(wb_path, sheet = "TransactionTypes", col_types = "text")

# 🔹 Load Transaction Data Sheets
I_FX         <- read_excel(wb_path, sheet = "I_FX", col_types = "text")
I_SUB_ToSL   <- read_excel(wb_path, sheet = "I_SUB_ToSL", col_types = "text")
R_FX         <- read_excel(wb_path, sheet = "R_FX", col_types = "text")
R_SUB_ToSL   <- read_excel(wb_path, sheet = "R_SUB_ToSL", col_types = "text")

# 🔹 Drop 2nd column (Currency) from FX sheets
I_FX <- I_FX[, -2]
R_FX <- R_FX[, -2]

# 🔹 Rename 'Group Code' columns consistently
I_FX         <- I_FX %>% rename(`Group Code` = `GIC Code`)
I_SUB_ToSL   <- I_SUB_ToSL %>% rename(`Group Code` = `GIC Code`)
R_FX         <- R_FX %>% rename(`Group Code` = `GRC Code`)
R_SUB_ToSL   <- R_SUB_ToSL %>% rename(`Group Code` = `GRC Code`)

# 🔹 Convert Amounts to character (preserves blanks)
I_FX[-1]         <- lapply(I_FX[-1], as.character)
I_SUB_ToSL[-1]   <- lapply(I_SUB_ToSL[-1], as.character)
R_FX[-1]         <- lapply(R_FX[-1], as.character)
R_SUB_ToSL[-1]   <- lapply(R_SUB_ToSL[-1], as.character)

# 🔹 Filter for valid Transaction Types
valid_transaction_types <- TransactionTypes$`Transaction Type`

I_FX         <- I_FX %>% select(`Group Code`, all_of(intersect(names(I_FX), valid_transaction_types)))
I_SUB_ToSL   <- I_SUB_ToSL %>% select(`Group Code`, all_of(intersect(names(I_SUB_ToSL), valid_transaction_types)))
R_FX         <- R_FX %>% select(`Group Code`, all_of(intersect(names(R_FX), valid_transaction_types)))
R_SUB_ToSL   <- R_SUB_ToSL %>% select(`Group Code`, all_of(intersect(names(R_SUB_ToSL), valid_transaction_types)))

# 🔹 Reshape to long format
I_FX_long         <- I_FX %>% pivot_longer(cols = -`Group Code`, names_to = "Transaction Type", values_to = "Amount")
I_SUB_ToSL_long   <- I_SUB_ToSL %>% pivot_longer(cols = -`Group Code`, names_to = "Transaction Type", values_to = "Amount")
R_FX_long         <- R_FX %>% pivot_longer(cols = -`Group Code`, names_to = "Transaction Type", values_to = "Amount")
R_SUB_ToSL_long   <- R_SUB_ToSL %>% pivot_longer(cols = -`Group Code`, names_to = "Transaction Type", values_to = "Amount")

# 🔹 Combine into Subledger (now officially created)
Subledger <- bind_rows(I_FX_long, I_SUB_ToSL_long, R_FX_long, R_SUB_ToSL_long) %>%
  mutate(Date = Date_Value) %>%
  select(Date, `Transaction Type`, `Group Code`, Amount)

# ✅ Now Subledger exists — proceed with enrichment

# 🔹 Load Group Mappings
I_Groups <- read_excel(wb_path, sheet = "I_Groups", col_types = "text")
R_Groups <- read_excel(wb_path, sheet = "R_Groups", col_types = "text")

# 🔹 Add Reporting Segment
Subledger <- Subledger %>%
  mutate(
    `Reporting Segment` = ifelse(
      !is.na(match(`Group Code`, I_Groups$`GIC Code`)),
      I_Groups$`Reporting Segment`[match(`Group Code`, I_Groups$`GIC Code`)],
      R_Groups$`Reporting Segment`[match(`Group Code`, R_Groups$`GRC Code`)]
    )
  )

# 🔹 Add Dr Account Code
Subledger <- Subledger %>%
  mutate(
    `Dr Account Code` = TransactionTypes$`Dr Account Code`[match(`Transaction Type`, TransactionTypes$`Transaction Type`)],
    `Dr Account Code` = ifelse(is.na(`Dr Account Code`), "", `Dr Account Code`)
  )

# 🔹 Add Cr Account Code
Subledger <- Subledger %>%
  mutate(
    `Cr Account Code` = TransactionTypes$`Cr Account Code`[match(`Transaction Type`, TransactionTypes$`Transaction Type`)],
    `Cr Account Code` = ifelse(is.na(`Cr Account Code`), "", `Cr Account Code`)
  )

# 🔹 Add Transition Method
Subledger <- Subledger %>%
  left_join(I_Groups %>% select(`GIC Code`, `Transition method`), by = c("Group Code" = "GIC Code")) %>%
  left_join(R_Groups %>% select(`GRC Code`, `Transition method`), by = c("Group Code" = "GRC Code"), suffix = c("_I", "_R")) %>%
  mutate(
    `Transition method` = coalesce(`Transition method_I`, `Transition method_R`, "")
  ) %>%
  select(-`Transition method_I`, -`Transition method_R`)

# 🔹 View the final Subledger
View(Subledger)


#################################################################R_Disclosure_Master

# Load necessary libraries
library(tidyverse)
library(readxl)

# Define column names
column_names <- c(
  "GMM - Master Disclosure – Reinsurance Contracts Held",  # Column 1
  "Account Code",  # Column 2 (skipped when filling values)
  "Statement of financial position|Pre-recognition cash flows|Estimates of the present value of future cash flows",
  "Statement of financial position|Asset for remaining coverage|Excluding loss-recovery component|Estimates of the present value of future cash flows",
  "Statement of financial position|Asset for remaining coverage|Excluding loss-recovery component|Risk adjustment",
  "Statement of financial position|Asset for remaining coverage|Contractual service margin",
  "Statement of financial position|Loss-recovery component|Estimates of the present value of future cash flows",
  "Statement of financial position|Investment components|Estimates of the present value of future cash flows",
  "Statement of financial position|Recoveries|Estimates of the present value of future cash flows",
  "Statement of financial position|Recoveries|Risk adjustment",
  "Statement of financial position|Cash"
)

# Create base table
GMM_Master_Disclosure <- tibble::tibble(
  `GMM - Master Disclosure – Reinsurance Contracts Held` = "Account code"
)

# Add empty columns to match structure
for (col in column_names[-1]) {
  GMM_Master_Disclosure[[col]] <- NA_character_
}

# Fill account codes in the first row (skip 2nd column "Account Code")
account_codes <- c("1313100", "1311110", "1311200", "1311300", 
                   "1312110", "1322100", "1321100", "1321200", "1100000")
GMM_Master_Disclosure[1, 3:11] <- as.list(account_codes)
# INPUT VARIABLES ------------------------------------------
# These would typically be user inputs in a Shiny app or read from a config
ReportingSegment_RI <- "Total"  # or: "BLL_1744", "BLL_1755", "BLL_1766"
Transition_method_Reins <- "Default"  # or: "Full Retrospective", "Modified Retrospective", etc.

# LOAD SETUP SHEET ----------------------------------------
Setup <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Setup", col_names = FALSE)
ReportingDate_Previous <- as.Date(as.numeric(Setup[[5]][2]), origin = "1899-12-30")  # Cell F2

# LOAD TRIAL BALANCE --------------------------------------
Outputs_TB <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Trial Balance") %>%
  mutate(
    Date = suppressWarnings(as.Date(as.numeric(Date), origin = "1899-12-30")),
    Amount = suppressWarnings(as.numeric(Amount)),
    `Account Code` = as.character(`Account Code`),
    Asset_Liability = as.character(`Asset / Liability`),
    Report_Segment = as.character(`Reporting Segment`),
    Transition_method = as.character(`Transition method`)
  )

# LOAD SUBLEDGER ------------------------------------------
Outputs_SL <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Subledger") %>%
  mutate(
    Amount = suppressWarnings(as.numeric(Amount)),
    DR_Account_Code = as.numeric(`DR Account Code`),
    CR_Account_Code = as.numeric(`CR Account Code`),
    Reporting_Segment = as.character(`Reporting Segment`),
    Transition_method = as.character(`Transition method`)
  )

# FUNCTION TO FILTER & SUM BASED ON INPUTS ----------------
get_total_by_type <- function(account_code, type = c("Asset", "Liability")) {
  type <- match.arg(type)
  Outputs_TB %>%
    filter(
      Asset_Liability == type,
      Date == ReportingDate_Previous,
      `Account Code` == account_code,
      (ReportingSegment_RI == "Total" | Report_Segment == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | Transition_method == Transition_method_Reins)
    ) %>%
    summarise(Total = sum(Amount, na.rm = TRUE)) %>%
    pull(Total)
}

get_subledger_net_total <- function(account_code) {
  cr_total <- Outputs_SL %>%
    filter(
      CR_Account_Code == account_code,
      (ReportingSegment_RI == "Total" | Reporting_Segment == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | Transition_method == Transition_method_Reins)
    ) %>%
    summarise(Total = sum(Amount, na.rm = TRUE)) %>%
    pull(Total)
  
  dr_total <- Outputs_SL %>%
    filter(
      DR_Account_Code == account_code,
      (ReportingSegment_RI == "Total" | Reporting_Segment == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | Transition_method == Transition_method_Reins)
    ) %>%
    summarise(Total = sum(Amount, na.rm = TRUE)) %>%
    pull(Total)
  
  return((cr_total %||% 0) - (dr_total %||% 0))
}

# EXAMPLE ACCOUNT CODES (used for filling rows, excluding column 2 and final column)
account_codes <- c("1313100", "1311110", "1311200", "1311300", 
                   "1312110", "1322100", "1321100", "1321200", "1100000")

# COMPUTE VALUES FOR ASSETS -------------------------------
asset_totals <- map_dbl(account_codes, get_total_by_type, type = "Asset")
assets_row <- rep(NA_character_, 11)
assets_row[1] <- "Assets"
for (i in seq_along(asset_totals)) {
  assets_row[i + 2] <- format(asset_totals[i], scientific = FALSE)
}
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(assets_row), names(GMM_Master_Disclosure)))

# COMPUTE VALUES FOR LIABILITIES --------------------------
liability_totals <- map_dbl(account_codes, get_total_by_type, type = "Liability")
liabilities_row <- rep(NA_character_, 11)
liabilities_row[1] <- "Liabilities"
for (i in seq_along(liability_totals)) {
  liabilities_row[i + 2] <- format(liability_totals[i], scientific = FALSE)
}
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(liabilities_row), names(GMM_Master_Disclosure)))

# ADD OPENING ROW -----------------------------------------
opening_row <- rep(NA_character_, 11)
opening_row[1] <- "Opening"
for (i in 3:11) {
  asset_val <- suppressWarnings(as.numeric(assets_row[i]))
  liability_val <- suppressWarnings(as.numeric(liabilities_row[i]))
  if (!is.na(asset_val) & !is.na(liability_val)) {
    opening_row[i] <- format(asset_val + liability_val, scientific = FALSE)
  }
}
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(opening_row), names(GMM_Master_Disclosure)))

# ADD HEADER FOR ALLOCATION -------------------------------
allocation_header <- rep(NA_character_, 11)
allocation_header[1] <- "Allocation of reinsurance premiums"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(allocation_header), names(GMM_Master_Disclosure)))

# ADD ROW: Premium experience variance --------------------
premium_row <- rep(NA_character_, 11)
premium_row[1] <- "  Premium experience variance"
premium_row[2] <- "2211000"  # Account code
premium_row[4] <- format(get_subledger_net_total("2211000"), scientific = FALSE)  # Only column 4
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(premium_row), names(GMM_Master_Disclosure)))
# ADD ROW: Expected recovery on insurance service expenses incurred in the period --
expected_row <- rep(NA_character_, 11)
expected_row[1] <- "  Expected recovery on insurance service expenses incurred in the period"
expected_row[2] <- "2212000"
# Column 4 only gets the custom computation from Subledger
Outputs_SL <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Subledger") %>%
  mutate(
    Amount = suppressWarnings(as.numeric(Amount)),
    `Transaction Type` = as.character(`Transaction Type`),
    `Dr Account Code` = as.character(`DR Account Code`),
    `Cr Account Code` = as.character(`CR Account Code`),
    `Group Code` = as.character(`Group Code`),
    `Reporting Segment` = as.character(`Reporting Segment`),
    `Transition method` = as.character(`Transition method`)
  )

get_subledger_total <- function(account_code) {
  Outputs_SL %>%
    filter(
      `Dr Account Code` == account_code | `Cr Account Code` == account_code,
      (ReportingSegment_RI == "Total" | `Reporting Segment` == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | `Transition method` == Transition_method_Reins)
    ) %>%
    summarise(value = sum(ifelse(`Cr Account Code` == account_code, Amount, -Amount), na.rm = TRUE)) %>%
    pull(value)
}

expected_row[4] <- format(get_subledger_total("2212000"), scientific = FALSE)
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(expected_row), names(GMM_Master_Disclosure)))
# ADD ROW: Change in the risk adjustment ------------------
risk_adj_row <- rep(NA_character_, 11)
risk_adj_row[1] <- "  Change in the risk adjustment"
risk_adj_row[2] <- "2213000"
risk_adj_row[5] <- format(get_subledger_total("2213000"), scientific = FALSE)
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(risk_adj_row), names(GMM_Master_Disclosure)))
# ADD ROW: Net cost/gain recognised in profit or loss -----
net_cost_row <- rep(NA_character_, 11)
net_cost_row[1] <- "  Net cost/gain recognised in profit or loss"
net_cost_row[2] <- "2214000"
net_cost_row[6] <- format(get_subledger_total("2214000"), scientific = FALSE)
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(net_cost_row), names(GMM_Master_Disclosure)))
# ADD SUBTOPIC ROWS ---------------------------------------
contracts_initial_row <- rep(NA_character_, 11)
contracts_initial_row[1] <- "  Contracts initially recognised in the period"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(contracts_initial_row), names(GMM_Master_Disclosure)))

contracts_purchased_row <- rep(NA_character_, 11)
contracts_purchased_row[1] <- "    Contracts purchased"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(contracts_purchased_row), names(GMM_Master_Disclosure)))

# Add: Estimates of present value of future cash outflows
outflows_row <- rep(NA_character_, 11)
outflows_row[1] <- "    Estimates of present value of future cash outflows"
outflows_row[2] <- "2215110"
outflows_row[4] <- format(get_subledger_total("2215110"), scientific = FALSE)
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(outflows_row), names(GMM_Master_Disclosure)))

# Add row: Transfer of liability for pre-recognition cash flows
transfer_row <- rep(NA_character_, 11)
transfer_row[1] <- "    Transfer of liability for pre-recognition cash flows"
transfer_row[2] <- "3321000"

# Function for subledger-based net calculation using Dr/Cr positions
get_subledger_total_by_column <- function(account_code) {
  Outputs_SL %>%
    filter(
      `Dr Account Code` == account_code | `Cr Account Code` == account_code,
      (ReportingSegment_RI == "Total" | `Reporting Segment` == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | `Transition method` == Transition_method_Reins)
    ) %>%
    summarise(value = sum(ifelse(`Cr Account Code` == account_code, Amount, -Amount), na.rm = TRUE)) %>%
    pull(value)
}

# Apply formula result into column 3 and 6
transfer_row[3] <- format(get_subledger_total_by_column("3321000"), scientific = FALSE)
transfer_row[6] <- format(get_subledger_total_by_column("3321000"), scientific = FALSE)

# Append to table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(transfer_row), names(GMM_Master_Disclosure)))
# Add row: Estimates of present value of future cash inflows
inflows_row <- rep(NA_character_, 11)
inflows_row[1] <- "    Estimates of present value of future cash inflows"
inflows_row[2] <- "2215120"

# Apply net calculation in column 4
inflows_row[4] <- format(get_subledger_total_by_column("2215120"), scientific = FALSE)

# Append to the main disclosure table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(inflows_row), names(GMM_Master_Disclosure)))

# Add row: Risk adjustment
risk_adj_row <- rep(NA_character_, 11)
risk_adj_row[1] <- "    Risk adjustment"
risk_adj_row[2] <- "2215130"

# Apply formula logic in column 5
risk_adj_row[5] <- format(get_subledger_total_by_column("2215130"), scientific = FALSE)

# Append to the table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(risk_adj_row), names(GMM_Master_Disclosure)))

# Add row: Contractual service margin
csm_row <- rep(NA_character_, 11)
csm_row[1] <- "    Contractual service margin"
csm_row[2] <- "2215140"

# Apply formula logic in column 6
csm_row[6] <- format(get_subledger_total_by_column("2215140"), scientific = FALSE)

# Append to the table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(csm_row), names(GMM_Master_Disclosure)))

# Add row: Contracts acquired (subtopic)
contracts_acquired_row <- rep(NA_character_, 11)
contracts_acquired_row[1] <- "    Contracts acquired"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(contracts_acquired_row), names(GMM_Master_Disclosure)))

# Add row: Estimates of present value of future cash outflows (under Contracts acquired)
epv_outflows_row_2 <- rep(NA_character_, 11)
epv_outflows_row_2[1] <- "    Estimates of present value of future cash outflows"
epv_outflows_row_2[2] <- "2215210"
epv_outflows_row_2[4] <- format(get_subledger_total("2215210"), scientific = FALSE)

GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(epv_outflows_row_2), names(GMM_Master_Disclosure)))
# Create row
transfer_row <- rep(NA_character_, 11)
transfer_row[1] <- "    Transfer of liability for pre-recognition cash flows"
transfer_row[2] <- "3322000"

# Apply formulas to columns 3 and 6
transfer_row[3] <- format(get_subledger_total("3322000"), scientific = FALSE)  # Col 3
transfer_row[6] <- format(get_subledger_total("3322000"), scientific = FALSE)  # Col 6

# Append to GMM_Master_Disclosure
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(transfer_row), names(GMM_Master_Disclosure))
)
# Create the row
inflow_row <- rep(NA_character_, 11)
inflow_row[1] <- "    Estimates of present value of future cash inflows"
inflow_row[2] <- "2215220"

# Column 4 (index 4) gets the value
inflow_row[4] <- format(get_subledger_total("2215220"), scientific = FALSE)

# Append to GMM_Master_Disclosure
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(inflow_row), names(GMM_Master_Disclosure))
)
# Create the row
risk_adj_row <- rep(NA_character_, 11)
risk_adj_row[1] <- "    Risk adjustment"
risk_adj_row[2] <- "2215230"

# Column 5 (index 5) gets the calculated value
risk_adj_row[5] <- format(get_subledger_total("2215230"), scientific = FALSE)

# Add the row to the table
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(risk_adj_row), names(GMM_Master_Disclosure))
)
# Create the row
csm_row <- rep(NA_character_, 11)
csm_row[1] <- "    Contractual service margin"
csm_row[2] <- "2215240"

# Column 6 (index 6) gets the calculated value
csm_row[6] <- format(get_subledger_total("2215240"), scientific = FALSE)

# Add the row to the table
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(csm_row), names(GMM_Master_Disclosure))
)
# Add "Amounts recoverable from reinsurers" as a sub-topic row
recoverable_header <- rep(NA_character_, 11)
recoverable_header[1] <- "Amounts recoverable from reinsurers"

# Append to the disclosure table
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(recoverable_header), names(GMM_Master_Disclosure))
)
# Calculate value for column 7 using existing definitions
col_index <- 7  # The column to fill
account_code_row <- "2221000"
column_account_code <- GMM_Master_Disclosure[[col_index]][1]  # account code in row 1, same column

# Compute the value using existing objects
value <- Outputs_SL %>%
  filter(
    (`CR Account Code` == account_code_row & `DR Account Code` == column_account_code) |
      (`CR Account Code` == column_account_code & `DR Account Code` == account_code_row),
    (ReportingSegment_RI == "Total" | `Reporting Segment` == ReportingSegment_RI),
    (Transition_method_Reins == "Default" | `Transition method` == Transition_method_Reins)
  ) %>%
  summarise(val = sum(ifelse(`CR Account Code` == account_code_row, Amount, -Amount), na.rm = TRUE)) %>%
  pull(val)

# Create and add the new row
new_row <- rep(NA_character_, 11)
new_row[1] <- "  Amounts recoverable for claims and other expenses incurred"
new_row[2] <- account_code_row
new_row[col_index] <- format(value, scientific = FALSE)

# Append row
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(new_row), names(GMM_Master_Disclosure)))

# Account code for this row
acc_code <- "2222000"

# Initialize row
change_csm_row <- rep(NA_character_, 11)
change_csm_row[1] <- "  Changes in estimates that adjust the contractual service margin"
change_csm_row[2] <- acc_code

# Get header account codes from row 1 (skip columns 1 and 2)
header_account_codes <- GMM_Master_Disclosure[1, 3:11] %>% unlist(use.names = FALSE)

# Only apply formulas to columns 4, 5, 6
for (col_index in 4:6) {
  ref_code <- header_account_codes[col_index - 2]
  
  value <- Outputs_SL %>%
    filter(
      (
        `CR Account Code` == acc_code & `DR Account Code` == ref_code
      ) |
        (
          `CR Account Code` == ref_code & `DR Account Code` == acc_code
        ),
      `Reporting Segment` == ReportingSegment_RI | ReportingSegment_RI == "Total",
      `Transition method` == Transition_method_Reins | Transition_method_Reins == "Default"
    ) %>%
    summarise(total = sum(ifelse(`CR Account Code` == acc_code, Amount, -Amount), na.rm = TRUE)) %>%
    pull(total)
  
  change_csm_row[col_index] <- format(value, scientific = FALSE)
}

# Add the row to the disclosure table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(change_csm_row), names(GMM_Master_Disclosure)))
# Row metadata
acc_code <- "2223000"
impairment_row <- rep(NA_character_, 11)
impairment_row[1] <- "  Impairment of Pre-Recognition Cash Flows Liability"
impairment_row[2] <- acc_code

# Get account code for column 3 (which is column index 3)
col_index <- 3
ref_code <- GMM_Master_Disclosure[1, col_index, drop = TRUE]

# Calculate value using formula logic
value <- Outputs_SL %>%
  filter(
    (
      `CR Account Code` == acc_code & `DR Account Code` == ref_code
    ) |
      (
        `CR Account Code` == ref_code & `DR Account Code` == acc_code
      ),
    `Reporting Segment` == ReportingSegment_RI | ReportingSegment_RI == "Total",
    `Transition method` == Transition_method_Reins | Transition_method_Reins == "Default"
  ) %>%
  summarise(total = sum(ifelse(`CR Account Code` == acc_code, Amount, -Amount), na.rm = TRUE)) %>%
  pull(total)

# Format and place in correct column
impairment_row[col_index] <- format(value, scientific = FALSE)

# Add to table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(impairment_row), names(GMM_Master_Disclosure)))
# Row setup
acc_code <- "2224000"
reversal_row <- rep(NA_character_, 11)
reversal_row[1] <- "  Reversal of Impairment of Pre-Recognition Cash Flows Liability"
reversal_row[2] <- acc_code

# Get account code from column 3 header row
col_index <- 3
ref_code <- GMM_Master_Disclosure[1, col_index, drop = TRUE]

# Calculate value based on formula logic
value <- Outputs_SL %>%
  filter(
    (
      `CR Account Code` == acc_code & `DR Account Code` == ref_code
    ) |
      (
        `CR Account Code` == ref_code & `DR Account Code` == acc_code
      ),
    `Reporting Segment` == ReportingSegment_RI | ReportingSegment_RI == "Total",
    `Transition method` == Transition_method_Reins | Transition_method_Reins == "Default"
  ) %>%
  summarise(total = sum(ifelse(`CR Account Code` == acc_code, Amount, -Amount), na.rm = TRUE)) %>%
  pull(total)

# Place in correct column
reversal_row[col_index] <- format(value, scientific = FALSE)

# Append to disclosure table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(reversal_row), names(GMM_Master_Disclosure)))
# Add subtopic row: "  Loss Recovery"
loss_recovery_row <- rep(NA_character_, 11)
loss_recovery_row[1] <- "  Loss Recovery"

GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(loss_recovery_row), names(GMM_Master_Disclosure))
)
# Define helper using existing objects only
get_cr_dr_difference_existing <- function(main_account, offset_account) {
  Outputs_SL %>%
    filter(
      (`CR Account Code` == main_account & `DR Account Code` == offset_account) |
        (`CR Account Code` == offset_account & `DR Account Code` == main_account),
      `Reporting Segment` == ReportingSegment_RI | ReportingSegment_RI == "Total",
      `Transition method` == Transition_method_Reins | Transition_method_Reins == "Default"
    ) %>%
    summarise(total = sum(
      ifelse(
        `CR Account Code` == main_account & `DR Account Code` == offset_account, Amount,
        ifelse(`CR Account Code` == offset_account & `DR Account Code` == main_account, -Amount, 0)
      ), na.rm = TRUE
    )) %>%
    pull(total)
}

# Build the row
loss_recovery_onerous <- rep(NA_character_, 11)
loss_recovery_onerous[1] <- "  Loss Recovery related to onerous underlying contracts at initial measurement"
loss_recovery_onerous[2] <- "2226000"

# Fill columns 4 to 7 using account codes in row 1
for (col in 4:7) {
  account_code_header <- GMM_Master_Disclosure[[col]][1]
  if (!is.na(account_code_header) && account_code_header != "") {
    val <- get_cr_dr_difference_existing("2226000", account_code_header)
    loss_recovery_onerous[col] <- format(val, scientific = FALSE)
  }
}

# Add row
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(loss_recovery_onerous), names(GMM_Master_Disclosure)))
recognition_recovery <- rep(NA_character_, 11)
recognition_recovery[1] <- "  Recognition and recovery of loss-recovery component"
recognition_recovery[2] <- "2225000"

for (col in 4:7) {
  account_code_header <- GMM_Master_Disclosure[[col]][1]
  if (!is.na(account_code_header) && account_code_header != "") {
    val <- get_cr_dr_difference_existing("2225000", account_code_header)
    recognition_recovery[col] <- format(val, scientific = FALSE)
  }
}

GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(recognition_recovery), names(GMM_Master_Disclosure)))
# Row: Changes in amounts recoverable arising from changes in liabilities for incurred claims
recoverable_row <- rep(NA_character_, 11)
recoverable_row[1] <- "  Changes in amounts recoverable arising from changes in liabilities for incurred claims"
recoverable_row[2] <- "2227000"

# Use previously defined get_subledger_total function to calculate for columns 8–10
recoverable_row[8] <- format(get_subledger_total("2227000"), scientific = FALSE)  # Column 8
recoverable_row[9] <- format(get_subledger_total("2227000"), scientific = FALSE)  # Column 9
recoverable_row[10] <- format(get_subledger_total("2227000"), scientific = FALSE) # Column 10

GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(recoverable_row), names(GMM_Master_Disclosure)))

# Subtopic: Reinsurance finance income / (expense)
finance_header <- rep(NA_character_, 11)
finance_header[1] <- "Reinsurance finance income / (expense)"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(finance_header), names(GMM_Master_Disclosure)))

# Subtopic: Interest accreted
interest_header <- rep(NA_character_, 11)
interest_header[1] <- "  Interest accreted"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(interest_header), names(GMM_Master_Disclosure)))
get_subledger_total_by_column <- function(row_account_code, column_account_code) {
  cr_match <- Outputs_SL %>%
    filter(
      `CR Account Code` == row_account_code,
      `DR Account Code` == column_account_code,
      (ReportingSegment_RI == "Total" | `Reporting Segment` == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | `Transition method` == Transition_method_Reins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  dr_match <- Outputs_SL %>%
    filter(
      `CR Account Code` == column_account_code,
      `DR Account Code` == row_account_code,
      (ReportingSegment_RI == "Total" | `Reporting Segment` == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | `Transition method` == Transition_method_Reins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  # Return net value (same as Excel formula)
  return(cr_match - dr_match)
}
# Row: Profit / loss
profit_row <- rep(NA_character_, 11)
profit_row[1] <- "    Profit / loss"
profit_row[2] <- "2411000"

# Loop over columns 4 to 10, pull column account code from row 1
for (col_index in 4:10) {
  column_code <- GMM_Master_Disclosure[[col_index]][1]
  if (!is.na(column_code)) {
    value <- get_subledger_total_by_column("2411000", column_code)
    profit_row[col_index] <- format(value, scientific = FALSE)
  }
}
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(profit_row), names(GMM_Master_Disclosure)))
# Row: Other comprehensive income (using same account code)
oci_row <- rep(NA_character_, 11)
oci_row[1] <- "    Profit / loss"
oci_row[2] <- "2411000"

# Fill only for columns 4, 5, 7, 8, 9, 10
target_cols <- c(4, 5, 7, 8, 9, 10)

for (col_index in target_cols) {
  column_code <- GMM_Master_Disclosure[[col_index]][1]
  if (!is.na(column_code)) {
    value <- get_subledger_total_by_column("2411000", column_code)
    oci_row[col_index] <- format(value, scientific = FALSE)
  }
}

# Append to the table
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(oci_row), names(GMM_Master_Disclosure)))
# Subtopic Header
interest_effect_header <- rep(NA_character_, 11)
interest_effect_header[1] <- "  Effect of changes in interest rates and other financial assumptions"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(interest_effect_header), names(GMM_Master_Disclosure)))
# Helper: Fill selected columns using the provided formula logic
fill_selected_columns <- function(row_name, acc_code, columns) {
  row <- rep(NA_character_, 11)
  row[1] <- row_name
  row[2] <- acc_code
  
  for (col_index in columns) {
    column_code <- GMM_Master_Disclosure[[col_index]][1]
    if (!is.na(column_code)) {
      row[col_index] <- format(get_subledger_total_by_column(acc_code, column_code), scientific = FALSE)
    }
  }
  
  GMM_Master_Disclosure <<- add_row(GMM_Master_Disclosure, !!!setNames(as.list(row), names(GMM_Master_Disclosure)))
}

# Columns to fill
cols_to_fill <- c(4, 5, 7, 8, 9, 10)

# Add the two rows
fill_selected_columns("    Profit / loss", "2421000", cols_to_fill)
fill_selected_columns("    Other comprehensive income", "2422000", cols_to_fill)

# Add the subtopic row
non_perf_header <- rep(NA_character_, 11)
non_perf_header[1] <- "  Effect of changes in the risk of non-performance by reinsurers"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(non_perf_header), names(GMM_Master_Disclosure)))
# ---- Helper Function (already defined before) ----
fill_selected_columns <- function(row_name, acc_code, columns) {
  row <- rep(NA_character_, 11)
  row[1] <- row_name
  row[2] <- acc_code
  
  for (col_index in columns) {
    column_code <- GMM_Master_Disclosure[[col_index]][1]
    if (!is.na(column_code)) {
      row[col_index] <- format(get_subledger_total_by_column(acc_code, column_code), scientific = FALSE)
    }
  }
  
  GMM_Master_Disclosure <<- add_row(GMM_Master_Disclosure, !!!setNames(as.list(row), names(GMM_Master_Disclosure)))
}

# ---------------------------
# 1 & 2: 2431 & 2432
fill_selected_columns("    Profit / loss", "2431000", c(4, 5, 7, 9, 10))
fill_selected_columns("    Other comprehensive income", "2432000", c(4, 5, 7, 9, 10))

# 3: Subtopic
subtopic_fx <- rep(NA_character_, 11)
subtopic_fx[1] <- "  Net foreign exchange income / (expenses)"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(subtopic_fx), names(GMM_Master_Disclosure)))

# 4 & 5: 2441 & 2442 (Full row cols 3 to 10)
fill_selected_columns("    Profit / loss", "2441000", 3:10)
fill_selected_columns("    Other comprehensive income", "2442000", 3:10)

# 6: Transfers Subtopic
transfers_row <- rep(NA_character_, 11)
transfers_row[1] <- "Transfers"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(transfers_row), names(GMM_Master_Disclosure)))

# --- Function to apply Subledger formula across specific columns ---
fill_transfer_row <- function(row_name, acc_code, target_cols) {
  row <- rep(NA_character_, 11)
  row[1] <- row_name
  row[2] <- acc_code
  
  for (col_index in target_cols) {
    column_code <- GMM_Master_Disclosure[[col_index]][1]
    if (!is.na(column_code)) {
      value <- get_subledger_total_by_column(acc_code, column_code)
      row[col_index] <- format(value, scientific = FALSE)
    }
  }
  
  GMM_Master_Disclosure <<- add_row(GMM_Master_Disclosure, !!!setNames(as.list(row), names(GMM_Master_Disclosure)))
}

# -- 1: Transfer of reinsurance investment components
fill_transfer_row("  Transfer of reinsurance investment components", "3310000", c(4, 8))

# -- 2: Cash flows subtopic
cashflows_header <- rep(NA_character_, 11)
cashflows_header[1] <- "Cash flows"
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(cashflows_header), names(GMM_Master_Disclosure)))

# -- 3: Premiums paid (cols 3, 4, 11)
fill_transfer_row("  Premiums paid", "3121000", c(3, 4, 11))

# -- 4: Amounts received (cols 9, 11)
fill_transfer_row("  Amounts received", "3122000", c(9, 11))

# -- 5: Reinsurance investment components received (cols 8, 11)
fill_transfer_row("  Reinsurance investment components received", "3123000", c(8, 11))
# --- Compute the Closing Row ----------------------------------------
closing_row <- rep(NA_character_, 11)
closing_row[1] <- "Closing"

# Loop through columns 3 to 10 and sum rows 4 to 49
for (col in 3:10) {
  col_values <- GMM_Master_Disclosure[4:50, col]  # Pull column slice
  col_numeric <- suppressWarnings(as.numeric(unlist(col_values)))  # Flatten + convert
  closing_row[col] <- format(sum(col_numeric, na.rm = TRUE), scientific = FALSE)
}

# Add the Closing row
GMM_Master_Disclosure <- add_row(GMM_Master_Disclosure, !!!setNames(as.list(closing_row), names(GMM_Master_Disclosure)))
# Add function that uses ReportingDate_Current
get_total_current_by_type <- function(account_code, type = c("Asset", "Liability")) {
  type <- match.arg(type)
  Outputs_TB %>%
    filter(
      Asset_Liability == type,
      Date == ReportingDate_Current,
      `Account Code` == account_code,
      (ReportingSegment_RI == "Total" | Report_Segment == ReportingSegment_RI),
      (Transition_method_Reins == "Default" | Transition_method == Transition_method_Reins)
    ) %>%
    summarise(Total = sum(Amount, na.rm = TRUE)) %>%
    pull(Total)
}

Outputs_TB <- read_excel("C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm", sheet = "Trial Balance") %>%
  mutate(
    Date = as.Date((Date), origin = "1899-12-30"),  # ✅ Fix Excel date
    Amount = as.numeric(Amount),
    `Account Code` = as.character(`Account Code`),
    `Asset / Liability` = as.character(`Asset / Liability`),
    `Reporting Segment` = as.character(`Reporting Segment`),
    `Transition method` = as.character(`Transition method`)
  ) %>%
  rename(
    Asset_Liability = `Asset / Liability`,
    Report_Segment = `Reporting Segment`,
    Transition_method = `Transition method`
  )


asset_account_codes <- GMM_Master_Disclosure[1, 3:10] %>%
  unlist(use.names = FALSE) %>%
  as.character()

asset_row_closing <- rep(NA_character_, 11)
asset_row_closing[1] <- "Assets"

for (i in seq_along(asset_account_codes)) {
  acc_code <- asset_account_codes[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    value <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Asset",
        Date == ReportingDate_Current,
        (ReportingSegment_RI != "Total" & Report_Segment == ReportingSegment_RI) |
          (ReportingSegment_RI == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        (Transition_method_Reins != "Default" & Transition_method == Transition_method_Reins) |
          (Transition_method_Reins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    asset_row_closing[i + 2] <- format(value, scientific = FALSE)
  }
}

# Add Assets row to disclosure
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(asset_row_closing), names(GMM_Master_Disclosure))
)
liability_account_codes <- GMM_Master_Disclosure[1, 3:10] %>%
  unlist(use.names = FALSE) %>%
  as.character()

liability_row_closing <- rep(NA_character_, 11)
liability_row_closing[1] <- "Liabilities"

for (i in seq_along(liability_account_codes)) {
  acc_code <- liability_account_codes[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    value <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Liability",
        Date == ReportingDate_Current,
        (ReportingSegment_RI != "Total" & Report_Segment == ReportingSegment_RI) |
          (ReportingSegment_RI == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        (Transition_method_Reins != "Default" & Transition_method == Transition_method_Reins) |
          (Transition_method_Reins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    liability_row_closing[i + 2] <- format(-value, scientific = FALSE)  # Negate per Excel
  }
}

# Add Liabilities row to disclosure
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(liability_row_closing), names(GMM_Master_Disclosure))
)
# Create Closing row by summing the last two rows (Assets + Liabilities)
closing_row <- rep(NA_character_, 11)
closing_row[1] <- "Closing"

for (i in 3:10) {
  val1 <- suppressWarnings(as.numeric(GMM_Master_Disclosure[nrow(GMM_Master_Disclosure) - 1, i, drop = TRUE]))
  val2 <- suppressWarnings(as.numeric(GMM_Master_Disclosure[nrow(GMM_Master_Disclosure), i, drop = TRUE]))
  
  closing_row[i] <- format(val1 + val2, scientific = FALSE)
}

# Add the Closing row to the disclosure table
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(closing_row), names(GMM_Master_Disclosure))
)
# Create the Check row
check_row <- rep(NA_character_, 11)
check_row[1] <- "Check"

for (i in 3:10) {
  val_51 <- suppressWarnings(round(as.numeric(GMM_Master_Disclosure[51, i, drop = TRUE]), 0))
  val_54 <- suppressWarnings(round(as.numeric(GMM_Master_Disclosure[54, i, drop = TRUE]), 0))
  
  check_row[i] <- if (!is.na(val_51) && !is.na(val_54) && val_51 == val_54) "OK" else "ERROR"
}

# Add the Check row to the disclosure
GMM_Master_Disclosure <- add_row(
  GMM_Master_Disclosure,
  !!!setNames(as.list(check_row), names(GMM_Master_Disclosure))
)

View(GMM_Master_Disclosure)



##########################################I_Disclosures_Master
# Define column headers
insurance_column_names <- c(
  "GMM - Master Disclosure – Insurance Contracts Issued",  # Column 1
  "Account Code",                                           # Column 2
  "Statement of financial position|Pre-recognition cash flows|Estimates of the present value of future cash flows",
  "Statement of financial position|Liability for remaining coverage|Excluding loss component|Estimates of the present value of future cash flows",
  "Statement of financial position|Liability for remaining coverage|Excluding loss component|Risk adjustment",
  "Statement of financial position|Liability for remaining coverage|Excluding loss component|Contractual service margin",
  "Statement of financial position|Liability for remaining coverage|Loss component|Estimates of the present value of future cash flows",
  "Statement of financial position|Liability for remaining coverage|Loss component|Risk adjustment",
  "Statement of financial position|Liability for remaining coverage|Investment components|Estimates of the present value of future cash flows",
  "Statement of financial position|Liability for incurred claims|Claims and other expenses|Estimates of the present value of future cash flows",
  "Statement of financial position|Liability for incurred claims|Claims and other expenses|Risk adjustment",
  "Statement of financial position|Cash"
)

# Initialize an empty table with just column names (no rows yet)
Insurance_Master_Disclosure <- tibble::tibble(
  !!!setNames(rep(list(character()), length(insurance_column_names)), insurance_column_names)
)
# Account codes for columns 3 to 12
account_codes <- c("1213100", "1211100", "1211200", "1211300", "1212100",
                   "1212200", "1222100", "1221100", "1221200", "1100000")

# Initialize row
header_row <- rep(NA_character_, 12)
header_row[1] <- "Account code"
header_row[3:12] <- account_codes

# Add to Insurance_Master_Disclosure
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(header_row), names(Insurance_Master_Disclosure))
)

# INPUTS (example: these would typically be user-defined somewhere earlier)
ReportingSegment_Ins <- "Total"       # e.g. "BLL_1711", "BLL_1722", etc.
Transitionmethod_Ins <- "Default"     # e.g. "Full Retrospective", "Modified", etc.

# Get account codes from row 1, columns 3 to 12
account_codes <- Insurance_Master_Disclosure[1, 3:12] %>%
  unlist(use.names = FALSE) %>%
  as.numeric()

# Build the Assets row
assets_row <- rep(NA_character_, 12)
assets_row[1] <- "Assets"

for (i in seq_along(account_codes)) {
  acc_code <- account_codes[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    value <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Asset",
        Date == ReportingDate_Previous,
        
        # Reporting Segment logic
        (ReportingSegment_Ins != "Total" & Report_Segment == ReportingSegment_Ins) |
          (ReportingSegment_Ins == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        
        # Transition method logic
        (Transitionmethod_Ins != "Default" & Transition_method == Transitionmethod_Ins) |
          (Transitionmethod_Ins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    # Store result (format for display)
    assets_row[i + 2] <- format(value, scientific = FALSE)
  }
}

# Add the Assets row to the table
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(assets_row), names(Insurance_Master_Disclosure))
)

# Build the Liabilities row
liabilities_row <- rep(NA_character_, 12)
liabilities_row[1] <- "Liabilities"

for (i in seq_along(account_codes)) {
  acc_code <- account_codes[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    value <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Liability",                      # ✅ Changed here
        Date == ReportingDate_Previous,
        
        # Reporting Segment logic (same as Excel IF)
        (ReportingSegment_Ins != "Total" & Report_Segment == ReportingSegment_Ins) |
          (ReportingSegment_Ins == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        
        # Transition method logic
        (Transitionmethod_Ins != "Default" & Transition_method == Transitionmethod_Ins) |
          (Transitionmethod_Ins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    liabilities_row[i + 2] <- format(value, scientific = FALSE)
  }
}

# Add the Liabilities row to the disclosure table
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(liabilities_row), names(Insurance_Master_Disclosure))
)
# Create Opening row by summing the last two rows (Assets + Liabilities)
opening_row <- rep(NA_character_, 12)
opening_row[1] <- "Opening"

for (i in 3:12) {
  val_assets <- suppressWarnings(as.numeric(Insurance_Master_Disclosure[nrow(Insurance_Master_Disclosure) - 1, i, drop = TRUE]))
  val_liabs  <- suppressWarnings(as.numeric(Insurance_Master_Disclosure[nrow(Insurance_Master_Disclosure), i, drop = TRUE]))
  
  opening_row[i] <- format(val_assets + val_liabs, scientific = FALSE)
}

# Add the Opening row to the disclosure
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(opening_row), names(Insurance_Master_Disclosure))
)
# Function to get net subledger amount (with flipped sign for Excel-style match)
get_subledger_total_by_column_ins <- function(row_account_code, col_account_code) {
  dr_match <- Outputs_SL %>%
    filter(
      `DR Account Code` == row_account_code,
      `CR Account Code` == col_account_code,
      (ReportingSegment_Ins == "Total" | `Reporting Segment` == ReportingSegment_Ins),
      (Transitionmethod_Ins == "Default" | `Transition method` == Transitionmethod_Ins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  cr_match <- Outputs_SL %>%
    filter(
      `CR Account Code` == row_account_code,
      `DR Account Code` == col_account_code,
      (ReportingSegment_Ins == "Total" | `Reporting Segment` == ReportingSegment_Ins),
      (Transitionmethod_Ins == "Default" | `Transition method` == Transitionmethod_Ins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  # ✅ Flip sign to match Excel
  return(((dr_match %||% 0) - (cr_match %||% 0)))
}

# Get header account codes from columns 3 to 12 of the first row
header_codes <- Insurance_Master_Disclosure[1, 3:12] %>% unlist(use.names = FALSE)

# Helper function to add rows with subledger logic
add_insurance_row <- function(description, acc_code, target_cols) {
  row <- rep(NA_character_, 12)
  row[1] <- description
  row[2] <- acc_code
  
  for (col_index in target_cols) {
    header_code <- header_codes[col_index - 2]
    if (!is.na(header_code)) {
      value <- get_subledger_total_by_column_ins(acc_code, header_code)
      row[col_index] <- format(value, scientific = FALSE)
    }
  }
  
  Insurance_Master_Disclosure <<- add_row(
    Insurance_Master_Disclosure,
    !!!setNames(as.list(row), names(Insurance_Master_Disclosure))
  )
}

# Add "Insurance revenue" subtopic row
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("Insurance revenue", rep(NA, 11))), names(Insurance_Master_Disclosure))
)

# Insurance revenue rows
add_insurance_row("  Premium experience variance", "2111000", 4)
add_insurance_row("  Acquisition cash flow experience variance", "2112000", 4)
add_insurance_row("  Expected insurance service expenses incurred in the period", "2114000", 4)
add_insurance_row("  Change in the risk adjustment", "2115000", 5)
add_insurance_row("  Amount of contractual service margin recognised", "2116000", 6)
add_insurance_row("  Allocation of the portion of premiums that relate to recovery of insurance acquisition cash flows", "2113000", 4)

# Add "Insurance service expenses" subtopic row
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("Insurance service expenses", rep(NA, 11))), names(Insurance_Master_Disclosure))
)

# Insurance service expenses rows
add_insurance_row("  Incurred claims and other expenses", "2121000", c(7, 8, 10, 11))
add_insurance_row("  Amortisation of insurance acquisition cash flows", "2122000", 4)
add_insurance_row("  Impairment of Pre-Recognition Cash Flows Asset", "2123000", 3)
add_insurance_row("  Reversal of Impairment of Pre-Recognition Cash Flows Asset", "2124000", 3)

# Add nested subtopics (with empty data cells)
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("Contracts initially recognised in the period", rep(NA, 11))), names(Insurance_Master_Disclosure))
)

Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("  Contracts issued", rep(NA, 11))), names(Insurance_Master_Disclosure))
)

Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("    Non-onerous", rep(NA, 11))), names(Insurance_Master_Disclosure))
)
# Reuse previously defined function with correct sign:
get_subledger_total_by_column_ins <- function(row_account_code, col_account_code) {
  dr_match <- Outputs_SL %>%
    filter(
      `DR Account Code` == row_account_code,
      `CR Account Code` == col_account_code,
      (ReportingSegment_Ins == "Total" | `Reporting Segment` == ReportingSegment_Ins),
      (Transitionmethod_Ins == "Default" | `Transition method` == Transitionmethod_Ins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  cr_match <- Outputs_SL %>%
    filter(
      `CR Account Code` == row_account_code,
      `DR Account Code` == col_account_code,
      (ReportingSegment_Ins == "Total" | `Reporting Segment` == ReportingSegment_Ins),
      (Transitionmethod_Ins == "Default" | `Transition method` == Transitionmethod_Ins)
    ) %>%
    summarise(total = sum(Amount, na.rm = TRUE)) %>%
    pull(total)
  
  return(((dr_match %||% 0) - (cr_match %||% 0)))
}

# Get column header codes from row 1, cols 3 to 12
header_codes <- Insurance_Master_Disclosure[1, 3:12] %>% unlist(use.names = FALSE)

# Function to add a row using account code and column index/indices
add_insurance_row <- function(description, acc_code, target_cols) {
  row <- rep(NA_character_, 12)
  row[1] <- description
  row[2] <- acc_code
  
  for (col_index in target_cols) {
    col_code <- header_codes[col_index - 2]
    if (!is.na(col_code)) {
      val <- get_subledger_total_by_column_ins(acc_code, col_code)
      row[col_index] <- format(val, scientific = FALSE)
    }
  }
  
  Insurance_Master_Disclosure <<- add_row(Insurance_Master_Disclosure, !!!setNames(as.list(row), names(Insurance_Master_Disclosure)))
}

# Add rows/subtopics ---------------------------------------------

add_row_text <- function(text) {
  Insurance_Master_Disclosure <<- add_row(Insurance_Master_Disclosure, !!!setNames(as.list(c(text, rep(NA, 11))), names(Insurance_Master_Disclosure)))
}

# -- First group
add_insurance_row("  Estimates of present value of future cash outflows excluding insurance acquisition cash flows", "2125111", 4)
add_insurance_row("  Estimates of insurance acquisition cash flows", "2125112", 4)
add_insurance_row("  Transfer of asset for pre-recognition cash flows", "3221100", c(3,6))
add_insurance_row("  Estimates of present value of future cash inflows", "2125113", 4)
add_insurance_row("  Risk adjustment", "2125114", 5)
add_insurance_row("  Contractual service margin", "2125115", 6)

# -- Subtopic: Onerous
add_row_text("  Onerous")
add_insurance_row("    Estimates of present value of future cash outflows excluding insurance acquisition cash flows", "2125121", c(4, 7))
add_insurance_row("    Estimates of insurance acquisition cash flows", "2125122", 4)
add_insurance_row("    Transfer of asset for pre-recognition cash flows", "3221200", c(3,6))
add_insurance_row("    Estimates of present value of future cash inflows", "2125123", 4)
add_insurance_row("    Risk adjustment", "2125124", c(5,8))
add_insurance_row("    Contractual service margin", "2125125", 6)

# -- Subtopic: Contracts acquired
add_row_text("Contracts acquired")
add_row_text("  Non-onerous")
add_insurance_row("    Estimates of present value of future cash outflows excluding insurance acquisition cash flows", "2125211", 4)
add_insurance_row("    Estimates of insurance acquisition cash flows", "2125212", 4)
add_insurance_row("    Transfer of asset for pre-recognition cash flows", "3222100", c(3,6))
add_insurance_row("    Estimates of present value of future cash inflows", "2125213", 4)
add_insurance_row("    Risk adjustment", "2125214", 5)
add_insurance_row("    Contractual service margin", "2125215", 6)

# -- Subtopic: Onerous (under Contracts acquired)
add_row_text("  Onerous")
add_insurance_row("    Estimates of present value of future cash outflows excluding insurance acquisition cash flows", "2125221", c(4,7))
add_insurance_row("    Estimates of insurance acquisition cash flows", "2125222", 4)
add_insurance_row("    Transfer of asset for pre-recognition cash flows", "3222200", c(3,6))
add_insurance_row("    Estimates of present value of future cash inflows", "2125223", 4)
add_insurance_row("    Risk adjustment", "2125224", c(5,8))
add_insurance_row("    Contractual service margin", "2125225", 6)

# -- Final section: Changes in estimates
add_insurance_row("Changes in estimates that adjust the contractual service margin", "2126000", c(4,5,6))
add_insurance_row("Changes in estimates that do not adjust the contractual service margin", "2127000", c(7,8))

# Add row for "Changes to liabilities for incurred claims"
acc_code <- "2128000"
row_claims_change <- rep(NA_character_, 12)
row_claims_change[1] <- "Changes to liabilities for incurred claims"
row_claims_change[2] <- acc_code

target_cols <- c(9, 10, 11)

for (col_index in target_cols) {
  col_code <- header_codes[col_index - 2]
  if (!is.na(col_code)) {
    val <- get_subledger_total_by_column_ins(acc_code, col_code)
    row_claims_change[col_index] <- format(val, scientific = FALSE)
  }
}

Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(row_claims_change), names(Insurance_Master_Disclosure))
)
# Header account codes again
header_codes <- Insurance_Master_Disclosure[1, 3:12] %>% unlist(use.names = FALSE)

# Add helper for flexible multi-column rows
add_insurance_row <- function(description, acc_code, target_cols) {
  row <- rep(NA_character_, 12)
  row[1] <- description
  row[2] <- acc_code
  for (col_index in target_cols) {
    col_code <- header_codes[col_index - 2]
    if (!is.na(col_code)) {
      val <- get_subledger_total_by_column_ins(acc_code, col_code)
      row[col_index] <- format(val, scientific = FALSE)
    }
  }
  Insurance_Master_Disclosure <<- add_row(Insurance_Master_Disclosure, !!!setNames(as.list(row), names(Insurance_Master_Disclosure)))
}

# Add section titles
add_row_text <- function(text) {
  Insurance_Master_Disclosure <<- add_row(Insurance_Master_Disclosure, !!!setNames(as.list(c(text, rep(NA, 11))), names(Insurance_Master_Disclosure)))
}

# --- Insurance finance income / (expense) ---
add_row_text("Insurance finance income / (expense)")
add_row_text("  Interest accreted")
add_insurance_row("    Profit / loss", "2311000", 4:11)
add_insurance_row("    Other comprehensive income", "2312000", c(4:5, 7:11))

add_row_text("  Effect of changes in interest rates and other financial assumptions")
add_insurance_row("    Profit / loss", "2321000", c(4:5, 7:11))
add_insurance_row("    Other comprehensive income", "2322000", c(4:5, 7:11))

add_row_text("  Net foreign exchange income / (expenses)")
add_insurance_row("    Profit / loss", "2331000", 3:11)
add_insurance_row("    Other comprehensive income", "2332000", 3:11)

# --- Transfers ---
add_row_text("Transfers")

# Append: Transfer of investment component
add_insurance_row("Transfer of investment component", "3210000", c(4, 9))

# Add Subtopic: Cash flows
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(c("Cash flows", rep(NA, 11))), names(Insurance_Master_Disclosure))
)

# Add each cash flow row
add_insurance_row("  Premiums received", "3111000", c(4, 12))
add_insurance_row("  Claims and other expenses paid", "3112000", c(10, 12))
add_insurance_row("  Investment components paid", "3113000", c(9, 12))
add_insurance_row("  Insurance acquisition cash flows paid", "3114000", c(3, 4, 12))




# View to confirm# Build Closing row (sum each column from row 4 to 67)
closing_row <- rep(NA_character_, 12)
closing_row[1] <- "Closing"

for (col in 3:12) {
  col_values <- Insurance_Master_Disclosure[4:67, col]
  col_numeric <- suppressWarnings(as.numeric(unlist(col_values)))
  closing_row[col] <- format(sum(col_numeric, na.rm = TRUE), scientific = FALSE)
}

# Append to disclosure table
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(closing_row), names(Insurance_Master_Disclosure))
)

# Extract account codes from header row (columns 3 to 12)
account_codes_ins <- Insurance_Master_Disclosure[1, 3:12] %>% unlist(use.names = FALSE) %>% as.character()

# --------- ASSETS ROW (Revised: values multiplied by -1) ---------
assets_row_latest <- rep(NA_character_, 12)
assets_row_latest[1] <- "Assets"

for (i in seq_along(account_codes_ins)) {
  acc_code <- account_codes_ins[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    val <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Asset",
        Date == ReportingDate_Current,
        (ReportingSegment_Ins != "Total" & Report_Segment == ReportingSegment_Ins) |
          (ReportingSegment_Ins == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        (Transitionmethod_Ins != "Default" & Transition_method == Transitionmethod_Ins) |
          (Transitionmethod_Ins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    # Multiply by -1 to reflect correct sign
    assets_row_latest[i + 2] <- format(-val, scientific = FALSE)
  }
}

# Append the revised Assets row to the disclosure
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(assets_row_latest), names(Insurance_Master_Disclosure))
)

# --------- LIABILITIES ROW ---------
liabilities_row_latest <- rep(NA_character_, 12)
liabilities_row_latest[1] <- "Liabilities"

for (i in seq_along(account_codes_ins)) {
  acc_code <- account_codes_ins[i]
  
  if (!is.na(acc_code) && acc_code != "") {
    val <- Outputs_TB %>%
      filter(
        `Account Code` == acc_code,
        Asset_Liability == "Liability",
        Date == ReportingDate_Current,
        (ReportingSegment_Ins != "Total" & Report_Segment == ReportingSegment_Ins) |
          (ReportingSegment_Ins == "Total" & !is.na(Report_Segment) & Report_Segment != ""),
        (Transitionmethod_Ins != "Default" & Transition_method == Transitionmethod_Ins) |
          (Transitionmethod_Ins == "Default" & !is.na(Transition_method) & Transition_method != "")
      ) %>%
      summarise(total = sum(Amount, na.rm = TRUE)) %>%
      pull(total)
    
    liabilities_row_latest[i + 2] <- format(-val, scientific = FALSE)  # Negative like Excel
  }
}

Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(liabilities_row_latest), names(Insurance_Master_Disclosure))
)

# --------- CLOSING (Latest) ROW: Assets + Liabilities ---------
closing_final_row <- rep(NA_character_, 12)
closing_final_row[1] <- "Closing"

# Get numeric values of the two rows just added (last two rows)
last_two <- tail(Insurance_Master_Disclosure, 2)

for (col in 3:12) {
  vals <- suppressWarnings(as.numeric(unlist(last_two[[col]])))
  closing_final_row[col] <- format(sum(vals, na.rm = TRUE), scientific = FALSE)
}

# Append to disclosure
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(closing_final_row), names(Insurance_Master_Disclosure))
)
# --------- CHECK ROW (Compare 2 closing rows) ---------
check_row <- rep(NA_character_, 12)
check_row[1] <- "Check"

# Compare row 77 and row 81 (assumed to be row indices in Insurance_Master_Disclosure)
# Adjust indices if rows are different in your table
row1 <- 68
row2 <- 71

for (col in 3:12) {
  val1 <- suppressWarnings(round(as.numeric(Insurance_Master_Disclosure[[col]][row1]), 0))
  val2 <- suppressWarnings(round(as.numeric(Insurance_Master_Disclosure[[col]][row2]), 0))
  
  if (!is.na(val1) && !is.na(val2)) {
    check_row[col] <- ifelse(val1 == val2, "OK", "ERROR")
  }
}

# Append the Check row
Insurance_Master_Disclosure <- add_row(
  Insurance_Master_Disclosure,
  !!!setNames(as.list(check_row), names(Insurance_Master_Disclosure))
)




# Write to Excel file
write_xlsx(Subledger, path = "Subledger.xlsx")


# Optional: View the updated table
View(Insurance_Master_Disclosure)

View(Subledger)





install.packages("openxlsx2")


library(openxlsx2)

# Path to your workbook
excel_path <- "C:/Users/NESK/Downloads/IFRS 17 GMM Tool v0.37.7_2017 v24 - Copy.xlsm"

# Load workbook
wb <- wb_load(excel_path)

# Remove existing data (rows below headers), assume data starts at row 2
# We'll overwrite rows 2 to 1000 to be safe
wb$add_data(
  sheet = "Subledger",
  x = matrix("", nrow = 999, ncol = ncol(Subledger)),
  start_row = 2,
  start_col = 1,
  col_names = FALSE
)

# Write new Subledger data (keep headers already in Excel)
wb$add_data(
  sheet = "Subledger",
  x = Subledger,
  start_row = 2,
  start_col = 1,
  col_names = FALSE
)

# Save the workbook
wb$save(excel_path)