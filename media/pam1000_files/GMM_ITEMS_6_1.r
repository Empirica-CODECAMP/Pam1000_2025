library(openxlsx2)
library(dplyr)
library(lubridate)
library(openxlsx)
## STEP 1. Loading the workbook
# Load the Excel workbook
wb <- wb_load("C:/Users/mamalelalat/Downloads/IFRS 17 GMM Tool v0.37.7_2017_v16.xlsm")
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

############################################################################inputs
Inputs_I_Groups <- wb_to_df(wb, sheet = "I_Groups", col_names = TRUE)
Inputs_I_NEW_CFs <- wb_to_df(wb, sheet = "I_NEW_CFs", col_names = TRUE)
Inputs_I_NEW_GEN <- wb_to_df(wb, sheet = "I_NEW_GEN", col_names = TRUE)
Inputs_I_IF_GEN <- wb_to_df(wb, sheet = "I_IF_GEN", col_names = TRUE)
Inputs_I_Equity <- wb_to_df(wb, sheet = "I_Equity", col_names = TRUE)
Inputs_I_IF_Patterns <- wb_to_df(wb, sheet = "I_IF_Patterns", col_names = TRUE)
Inputs_I_IF_FCFs <- wb_to_df(wb, sheet = "I_IF_FCFs", col_names = TRUE)
Inputs_ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
Inputs_ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
YieldCurves <- wb_to_df(wb, sheet = "YieldCurves", col_names = TRUE)
###########################################################Define column names

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
  "Spot_Rate_Linked_Remaining_Coverage_Previous_Reporting_Date_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Previous_Reporting_Date_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Remaining_Coverage_Current_Reporting_Date_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date_Delay", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date", 
  "Spot_Rate_Linked_Remaining_Coverage_Locked_in_Date_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Incurred_Claims_Previous_Reporting_Date_Delay", 
  "Spot_Rate_Linked_Incurred_Claims_Previous_Reporting_Date_min_Delay_Reporting_Period", 
  "Spot_Rate_Linked_Incurred_Claims_Current_Reporting_Date_Delay", 
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
I_IN_Disc <- data.frame(matrix(ncol = length(I_IN_Disc_cols), nrow = length(Inputs_I_NEW_CFs$`Reporting Date`)))
colnames(I_IN_Disc) <- I_IN_Disc_cols

I_IN_Calc <- data.frame(matrix(ncol = length(I_IN_Calc_cols), nrow = length(Inputs_I_NEW_GEN$`GIC Code`)))
colnames(I_IN_Calc) <- I_IN_Calc_cols

I_IN_ToSL <- data.frame(matrix(ncol = length(I_IN_ToSL_cols), nrow = length(I_IN_Calc$`GIC Code`)))
colnames(I_IN_ToSL) <- I_IN_ToSL_cols

I_IN_Pre_FX <- data.frame(matrix(ncol = length(I_IN_Pre_FX_cols), nrow = length(I_IN_Calc$`GIC Code`)))
colnames(I_IN_Pre_FX) <- I_IN_Pre_FX_cols

I_SUB_ToT1TB <- data.frame(matrix(ncol = length(I_SUB_ToT1TB_cols), nrow = length(Inputs_I_Groups$`GIC Code`)))
colnames(I_SUB_ToT1TB) <- I_SUB_ToT1TB_cols

I_SUB_ToT0TB <- data.frame(matrix(ncol = length(I_SUB_ToT0TB_cols), nrow = length(Inputs_I_Groups$`GIC Code`)))
colnames(I_SUB_ToT0TB) <- I_SUB_ToT0TB_cols

I_EQ_Calc <- data.frame(matrix(ncol = length(I_EQ_Calc_cols), nrow = length(Inputs_I_Groups$`GIC Code`)))
colnames(I_EQ_Calc) <- I_EQ_Calc_cols

I_SUB_Disc1 <- data.frame(matrix(ncol = length(I_SUB_Disc1_cols), nrow = length(Inputs_I_IF_FCFs$`GIC Code`)))
colnames(I_SUB_Disc1) <- I_SUB_Disc1_cols

I_SUB_Disc2 <- data.frame(matrix(ncol = length(I_SUB_Disc2_cols), nrow = length(Inputs_I_IF_Patterns$`Reporting Date`)))
colnames(I_SUB_Disc2) <- I_SUB_Disc2_cols

I_SUB_Calc <- data.frame(matrix(ncol = length(I_SUB_Calc_cols), nrow = length(Inputs_I_Groups$`GIC Code`)))
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
install.packages("dplyr")
library(dplyr)

 
I_IN_Disc$`Reporting Date` <- as.Date(NA)

# Loop through each index of I_IN_Disc
for(i in seq_along(I_IN_Disc$`Reporting Date`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Reporting Date`[i] <- as.Date(0)  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Reporting Date`[i] <- as.Date(Inputs_I_NEW_CFs$`Reporting Date`[i])
  }
}

for(i in seq_along(I_IN_Disc$`GIC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`GIC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`GIC Code`[i] <- Inputs_I_NEW_CFs$`GIC Code`[i]
  }
}


# Ensure Locked-in YC Date column exists and is initialized as NA
I_IN_Disc <- I_IN_Disc %>%
  mutate(`Locked-in YC Date` = case_when(
    `Scope_Ins_NUB` == "No" ~ as.Date(NA),  # Set to NA if Scope_Ins_NUB is "No"
    TRUE ~ as.Date(Inputs_I_Groups$`Locked-in YC Date`[match(`GIC Code`, Inputs_I_Groups$`GIC Code`)]))  # Match and assign Locked-in YC Date
  )

for(i in seq_along(I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Premium CFs (Unlinked)(Current Service)`[i]
  }
}


for(i in seq_along(I_IN_Disc$`Premium CFs (Unlinked)(Future Service)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Unlinked)(Future Service)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Premium CFs (Unlinked)(Future Service)`[i] <- Inputs_I_NEW_CFs$`Premium CFs (Unlinked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Service in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Acquisition Expense CFs (Unlinked)(Current Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Acquisition Expense CFs (Unlinked)(Future Service)`[i] <- Inputs_I_NEW_CFs$`Acquisition Expense CFs (Unlinked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Investment Component CFs (Unlinked)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Investment Component CFs (Unlinked)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Investment Component CFs (Unlinked)`[i] <- Inputs_I_NEW_CFs$`Investment Component CFs (Unlinked)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Claim and Other Expense CFs (Unlinked)(Incurred in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Disc$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`[i] <- Inputs_I_NEW_CFs$`Claim and Other Expense CFs (Unlinked)(Incurred in Future Reporting Periods)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Premium CFs (Linked)(Service in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Premium CFs (Linked)(Future Service)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Premium CFs (Linked)(Future Service)` <- 0
  } else {
    I_IN_Disc$`Premium CFs (Linked)(Future Service)`[i] <- Inputs_I_NEW_CFs$`Premium CFs (Linked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Acquisition Expense CFs (Linked)(Service in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)` <- 0
  } else {
    I_IN_Disc$`Acquisition Expense CFs (Linked)(Future Service)`[i] <- Inputs_I_NEW_CFs$`Acquisition Expense CFs (Linked)(Future Service)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Investment Component CFs (Linked)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Investment Component CFs (Linked)` <- 0
  } else {
    I_IN_Disc$`Investment Component CFs (Linked)`[i] <- Inputs_I_NEW_CFs$`Investment Component CFs (Linked)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)` <- 0
  } else {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`[i] <- Inputs_I_NEW_CFs$`Claim and Other Expense CFs (Linked)(Incurred in Current Reporting Period)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)` <- 0
  } else {
    I_IN_Disc$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`[i] <- Inputs_I_NEW_CFs$`Claim and Other Expense CFs (Linked)(Incurred in Future Reporting Periods)`[i]
  }
}

for(i in seq_along(I_IN_Disc$`Delay (in Years)`)) {
  if(Scope_Ins_NUB == 'No') {
    I_IN_Disc$`Delay (in Years)` <- 0
  } else {
    I_IN_Disc$`Delay (in Years)`[i] <- Inputs_I_NEW_CFs$`Delay (in Years)`[i]
  }
}


# Create Lookup_Key in I_IN_Disc
I_IN_Disc <- I_IN_Disc %>%
  mutate(
    Lookup_Key = paste(
      `Locked-in YC Date`,
      `Currency`,
      "Unlinked",
      ifelse(Option_GranularYC == "Yes", 
             paste("Remaining Coverage", GIC_Code, sep="_"), 
             ""),
      sep="_"
    )
  )



# Load necessary packages
library(dplyr)

# Populate the Spot Rate (Unlinked)(Locked-in Date, Delay) column
I_IN_Disc <- I_IN_Disc %>%
  rowwise() %>%  # This ensures row-wise operations
  mutate(
    # Print out the lookup key for debugging
    lookup_key = paste0(
      `Locked-in YC Date`, "_", Currency, "_Unlinked", 
      if_else(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GIC Code`), "")
    ),
    
    # Calculate delay in months
    delay_months = ceiling(trunc(`Delay (in Years)`, 2) * 12),
    
    # Check if delay_months matches a column in YieldCurves
    delay_col_match = if_else(as.character(delay_months) %in% colnames(YieldCurves), TRUE, FALSE),
    
    # Perform lookup based on the key and delay
    `Spot Rate (Unlinked)(Locked-in Date, Delay)` = case_when(
      Scope_Ins_NUB == "No" ~ 0,  # If Scope_Ins_NUB is "No", set to 0
      delay_col_match == TRUE ~ {
        # Find the corresponding value in YieldCurves based on the lookup key and delay
        lookup_result <- YieldCurves %>%
          filter(paste0(`Locked-in YC Date`, "_", Currency, "_Unlinked", 
                        if_else(Option_GranularYC == "Yes", paste0("_Remaining Coverage_", `GIC Code`), "")
          ) == lookup_key) %>%
          pull(as.character(delay_months))
        
        # If lookup result is empty or NA, return 0, otherwise return the lookup result
        ifelse(length(lookup_result) > 0 && !is.na(lookup_result), lookup_result, 0)
      },
      TRUE ~ 0  # If no match, return 0
    )
  ) %>%
  ungroup()  # Un-group after row-wise operations


   

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
I_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)` <- 
  ifelse(
    I_IN_Disc$Scope_Ins_NUB == "No", 
    0, 
    (I_IN_Disc$`Premium CFs (Unlinked)(Service in Current Reporting Period)` *
       ((1 + I_IN_Disc$`Spot Rate (Unlinked)(Locked-in Date, Delay)`)^(-I_IN_Disc$`Delay (in Years)`)) *
       (1 + I_IN_Disc$`Spot Rate (Unlinked)(Locked-in Date, min'[Delay, Reporting Date - Locked-in Date']`))^pmin(I_IN_Disc$`Delay (in Years)`, 
         round((I_IN_Disc$Reporting_Date - I_IN_Disc$`Locked-in YC Date`) / 365.25, 2))) +
    (I_IN_Disc$`Premium CFs (Linked)(Service in Current Reporting Period)` *
       ((1 + I_IN_Disc$`Spot Rate (Linked)(Locked-in Date, Delay)`)^(-I_IN_Disc$`Delay (in Years)`)) *
       (1 + I_IN_Disc$`Spot Rate (Linked)(Locked-in Date, min'[Delay, Reporting Date - Locked-in Date']`))^pmin(I_IN_Disc$`Delay (in Years)`, 
         round((I_IN_Disc$Reporting_Date - I_IN_Disc$`Locked-in YC Date`) / 365.25, 2))
  )
  )




##########################################I_IN_Calc

for(i in seq_along(I_IN_Calc$`GIC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`GIC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Calc$`GIC Code`[i] <- Inputs_I_NEW_GEN$`GIC Code`[i]
  }
}

for(i in seq_along(I_IN_Calc$`Issued/Acquired`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`Issued/Acquired` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Calc$`Issued/Acquired`[i] <- Inputs_I_NEW_GEN$`Issued/Acquired`[i]
  }
}

for(i in seq_along(I_IN_Calc$`Pre-recognition CFs`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No') {
    I_IN_Calc$`Pre-recognition CFs` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    I_IN_Calc$`Pre-recognition CFs`[i] <- Inputs_I_NEW_GEN$`Pre-recognition CFs`[i]
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
      sum(Inputs_I_Groups %>%
            filter(`GIC Code` == `GIC Code`) %>%
            pull(`RA % of ABS(PVFCF)`)),
      0
    )
  ))

# First join Inputs_I_NEW_GEN to I_IN_Calc based on the common key (e.g., GIC Code)
I_IN_Calc <- I_IN_Calc %>%
  left_join(Inputs_I_NEW_GEN %>% select(`GIC Code`, `Initial RA`), by = "GIC Code") %>%
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

Inputs_I_IF_GEN_unique <- Inputs_I_IF_GEN %>%
  distinct(`GIC Code`, `Opening LRC - Loss - PVFCF`, `Opening LRC - Loss - RA`)

# Perform the join and calculation
I_IN_Calc <- I_IN_Calc %>%
  left_join(
    Inputs_I_IF_GEN_unique, 
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
      select(`GIC Code`, `Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX`), # Select relevant columns
    by = "GIC Code" # Ensure this is the correct join column
  ) %>%
  mutate(
    # Replace NA values with 0 in the new column (if it's missing or NA)
    `Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX` = coalesce(
      `Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX`, 0
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
    `Transfer of Pre-recognition CFs (Issued, Non-onerous) - Actuals FX` = 
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
        # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
        I_EQ_Calc$`GIC Code`[i] <- (Inputs_I_Groups$`GIC Code`[i])
    }
    }



I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Reporting Segment` = ifelse(Scope_Insurance == "No", 0, 
                                    Inputs_I_Groups %>%
                                    filter(`GIC Code` == I_EQ_Calc$`GIC Code`) %>%
                                    pull(`Reporting Segment`)))



I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Opening Insurance Finance Reserve` = ifelse(Scope_Insurance == "No", 0,
                                                    Inputs_I_Equity %>%
                                                      filter(`GIC Code` == `GIC Code`) %>%
                                                      summarise(sum_value = sum(`Opening Insurance Finance Reserve`, na.rm = TRUE)) %>%
                                                      pull(sum_value)))



# Update the Income/(Expense) disclosed in OCI column
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
                                                    Inputs_I_Equity %>%
                                                      filter(`GIC Code` == `GIC Code`) %>%
                                                      summarise(sum_value = sum(`Opening Retained Earnings`, na.rm = TRUE)) %>%
                                                      pull(sum_value)))

I_EQ_Calc <- I_EQ_Calc %>%
  mutate(`Closing Retained Earnings` = `Opening Retained Earnings` + `Income/(Expense) disclosed in P&L`) 

################################################################I_SUB_Disc1
I_SUB_Disc1$`Reporting Date` <- Inputs_I_IF_FCFs$`Reporting Date`

I_SUB_Disc1$`GIC Code` <- Inputs_I_IF_FCFs$`GIC Code`

# Define the column name dynamically (equivalent to $C$1 in Excel)
C1_column <- "Locked-in YC Date"  # Replace with the actual column name

# Perform the lookup and populate the Locked-in YC Date column
I_SUB_Disc1 <- I_SUB_Disc1 %>%
  left_join(Inputs_I_Groups, by = "GIC Code") %>%  # Join using GIC Code
  mutate(
    `Locked-in YC Date` = coalesce(.data[[C1_column]], 0)  # Use the dynamic column value
  ) %>%
  select(-all_of(C1_column)) 


#######################################################I_SUB_Disc2
I_SUB_Disc2$`Reporting Date` <- Inputs_I_IF_Patterns$`Reporting Date`
I_SUB_Disc2$`GIC Code` <- Inputs_I_IF_Patterns$`GIC Code`

# Perform left join to populate 'Locked-in YC Date' from 'Inputs_I_Groups' into 'I_SUB_Disc2'
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  left_join(Inputs_I_Groups %>% select(`GIC Code`, `Locked-in YC Date`), by = "GIC Code") %>%
  mutate(`Locked-in YC Date` = coalesce(`Locked-in YC Date.x`, `Locked-in YC Date.y`)) %>%
  select(-`Locked-in YC Date.x`, -`Locked-in YC Date.y`)

# Dynamically find the column index for "Currency" in the Inputs_I_Groups data frame
currency_col_index <- which(colnames(Inputs_I_Groups) == "Currency")

# Perform the join using GIC Code and Currency column
I_SUB_Disc2 <- I_SUB_Disc2 %>%
  # Join I_SUB_Disc2 with Inputs_I_Groups on 'GIC Code'
  left_join(Inputs_I_Groups %>% select(`GIC Code`, `Currency`), by = "GIC Code") %>%
  # Populate 'Currency' in I_SUB_Disc2 with the values from Inputs_I_Groups
  mutate(Currency = coalesce(Currency.x, Currency.y)) %>%
  # Drop the extra columns that were created during the join
  select(-Currency.x, -Currency.y)

I_SUB_Disc2$`Coverage Units (Undiscounted)` <- Inputs_I_IF_Patterns$`Coverage Units (Undiscounted)`
I_SUB_Disc2$`Amortisation Pattern (Undiscounted)` <- Inputs_I_IF_Patterns$`Amortisation Pattern (Undiscounted)`
I_SUB_Disc2$`Reporting Period (0 = current)` <- Inputs_I_IF_Patterns$`Reporting Period (0 = current)`


# 1. Start by creating a helper column in Inputs_I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
Inputs_I_Groups <- Inputs_I_Groups %>%
  mutate(YC_key = case_when(
    Scope_LinkedCashflows == "No" ~ "Unlinked",
    TRUE ~ as.character(`YC to discount Coverage Units and Amortisation Pattern`)
  ))

# 2. Create a function to calculate the spot rate for each row in I_SUB_Disc2
calculate_spot_rate <- function(Locked_in_YC_Date, Currency, GIC_Code, Reporting_Date, Reporting_Period, Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC) {
  
  # Check the condition if Option_DiscountCUs and Option_DiscountAmortPattern are both "No"
  if (Option_DiscountCUs == "No" & Option_DiscountAmortPattern == "No") {
    return(0)
  }
  
  # Generate key for YieldCurves based on the logic
  scope_linked_value <- Inputs_I_Groups %>%
    filter(`GIC Code` == GIC_Code) %>%
    pull(YC_key)
  
  yc_key <- paste0(Locked_in_YC_Date, "_", Currency, "_", scope_linked_value)
  
  if (Option_GranularYC == "Yes") {
    yc_key <- paste0(yc_key, "_Remaining Coverage_", GIC_Code)
  }
  
  # Calculate time difference for MATCH equivalent
  time_diff_years <- as.numeric((as.Date(Reporting_Date) - as.Date(Locked_in_YC_Date)) / 365.25) + 
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



# 1. Prepare helper column in Inputs_I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
Inputs_I_Groups <- Inputs_I_Groups %>%
  mutate(YC_key = case_when(
    Scope_LinkedCashflows == "No" ~ "Unlinked",
    TRUE ~ as.character(`YC to discount Coverage Units and Amortisation Pattern`)
  ))

# 2. Function to calculate the Spot Rate based on the formula
calculate_spot_rate_locked_in <- function(Locked_in_YC_Date, Currency, GIC_Code, Reporting_Date, Option_DiscountCUs, Option_DiscountAmortPattern, Option_GranularYC) {
  
  # Check condition if Option_DiscountCUs and Option_DiscountAmortPattern are both "No"
  if (Option_DiscountCUs == "No" & Option_DiscountAmortPattern == "No") {
    return(0)
  }
  
  # Generate key for YieldCurves based on Locked-in YC Date, Currency, and Scope_LinkedCashflows condition
  scope_linked_value <- Inputs_I_Groups %>%
    filter(`GIC Code` == GIC_Code) %>%
    pull(YC_key)
  
  yc_key <- paste0(Locked_in_YC_Date, "_", Currency, "_", scope_linked_value)
  
  # Add extra components if Option_GranularYC is "Yes"
  if (Option_GranularYC == "Yes") {
    yc_key <- paste0(yc_key, "_Remaining Coverage_", GIC_Code)
  }
  
  # Calculate the time difference (years) between Reporting Date and Locked-in YC Date
  time_diff_years <- as.numeric((as.Date(Reporting_Date) - as.Date(Locked_in_YC_Date)) / 365.25)
  
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



# 1. Prepare helper column in Inputs_I_Groups for "YC to discount Coverage Units and Amortisation Pattern"
Inputs_I_Groups <- Inputs_I_Groups %>%
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
  scope_linked_value <- Inputs_I_Groups %>%
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

I_SUB_Calc$`GIC Code` <- Inputs_I_Groups$`GIC Code`

# Assuming B$1 corresponds to the column name you want to match
column_name <- "Currency"  # Replace with the actual column name from Inputs_I_Groups

# Populate Currency in I_SUB_Calc based on GIC Code
I_SUB_Calc <- I_SUB_Calc %>%
  mutate(Currency = Inputs_I_Groups[match(`GIC Code`, Inputs_I_Groups$`GIC Code`), match(column_name, names(Inputs_I_Groups))])

I_SUB_Calc$`Locked-in YC Date` <- Inputs_I_Groups$`Locked-in YC Date`


I_SUB_Calc <- I_SUB_Calc %>%
  mutate(`RA % of ABS(PVFCF Claims)` = ifelse(
    Option_RASimplification == "Yes",
    (Inputs_I_Groups$`RA % of ABS(PVFCF)`[Inputs_I_Groups$`GIC Code` == `GIC Code`]),
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
           Inputs_I_IF_GEN$`Actual less Expected Return on LRC IC`[match(`GIC Code`, Inputs_I_IF_GEN$`GIC Code`)]
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
             sum(Inputs_I_IF_GEN$`Premium Receipts (Past/Current Service)`[
               Inputs_I_IF_GEN$`Reporting Date` == ReportingDate_Current &
                 Inputs_I_IF_GEN$`GIC Code` == gic
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
             sum(Inputs_I_IF_GEN$`Acquisition Expense Payments (Past/Current Service)`[
               Inputs_I_IF_GEN$`Reporting Date` == ReportingDate_Current &
                 Inputs_I_IF_GEN$`GIC Code` == gic
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
  rowwise() %>%
  mutate(
    `Interest Accreted on Opening LRC - Profit - PVFCF - Actuals FX` = {
      # Extract the GIC code for the current row (A5 in Excel)
      gic_code <- .data$GIC Code  # Assuming 'GIC_Code' is the column that holds the GIC code in 'I_SUB_ToSL'
      
      # Perform the lookup in 'Workings_I_FX' using the GIC code and column index
      matching_value <- I_FX %>%
        filter(`GIC Code` == gic_code) %>% 
        pull(column_index)
      
      # Return the matched value (or NA if no match found)
      if (length(matching_value) == 0) {
        return(NA)  # If no match is found, return NA
      } else {
        return(matching_value)
      }
    }
  )





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
      gic_code <- .data$`GIC Code`
      
      # Calculate the sum of Discounted Coverage Units (Locked-in YC, t0)
      discounted_coverage_units <- I_SUB_Disc2 %>%
        filter(
          `Reporting Date` == ReportingDate_Current,
          `GIC Code` == gic_code,
          `Reporting Period (0 = current)` > 0
        ) %>%
        summarize(sums = sum(`Discounted Coverage Units (Locked-in YC, t0)`, na.rm = TRUE)) %>%
        pull(sums)
      
      # Check if the sum is 0
      if (discounted_coverage_units == 0) {
        return(0)  # Return 0 if the sum is 0
      } else {
        # Perform the full formula calculation
        closing_lrc_csm <- I_FX %>%
          filter(`GIC Code` == gic_code) %>%
          pull(`Closing LRC - CSM - Current FX`)
        
        # Calculate the numerator using the MID equivalent (reporting_period)
        numerator <- I_SUB_Disc2 %>%
          filter(
            `Reporting Date` == ReportingDate_Current,
            `GIC Code` == gic_code,
            `Reporting Period (0 = current)` == reporting_period
          ) %>%
          summarize(numerator_value = sum(`Discounted Coverage Units (Locked-in YC, t0)`, na.rm = TRUE)) %>%
          pull(numerator_value)
        
        # Calculate the denominator (similar to the original SUMIFS)
        denominator <- discounted_coverage_units
        
        # Perform the final calculation
        result <- closing_lrc_csm * (numerator / denominator)
        return(result)
      }
    }
  )








##############################################################################I_SUB_ToT1TB
I_SUB_ToT1TB$`GIC Code` <- Inputs_I_Groups$`GIC Code`
I_SUB_ToT1TB$`Portfolio` <- Inputs_I_Groups$`Portfolio`



# Assume D1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
D1 <- "LRC - Profit - PVFCF"  # You can set this based on your dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column <- grep(paste0("Closing ", D1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column), by = "GIC Code") %>%
  mutate(`LRC - Profit - PVFCF` = !!sym(closing_column))



# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
E1 <- "LRC - Loss - PVFCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", E1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Loss - PVFCF` = !!sym(closing_column_loss))


# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
F1 <- "LRC - Profit - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", F1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Profit - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
G1 <- "LRC - Loss - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", G1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Loss - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
H1 <- "LRC - CSM"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", H1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - CSM` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
I1 <- "LRC - PRCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", I1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - PRCF` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
J1 <- "LIC - PVFCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", J1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - PVFCF` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
K1 <- "LIC - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", K1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
L1 <- "LIC - IC"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Closing ", L1, " - Current FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - IC` = !!sym(closing_column_loss))

# Define the column range that you want to check (LRC - Profit - PVFCF to LIC - IC)
columns_to_check <- c("LRC - Profit - PVFCF", "LRC - Loss - PVFCF", 
                      "LRC - Profit - RA", "LRC - Loss - RA", 
                      "LRC - CSM", "LRC - PRCF", 
                      "LIC - PVFCF", "LIC - RA", "LIC - IC")

# Populate 'Asset / Liability' column
I_SUB_ToT1TB <- I_SUB_ToT1TB %>%
  mutate(
    `Asset / Liability` = ifelse(
      rowSums(I_SUB_ToT1TB[, columns_to_check], na.rm = TRUE) < 0, 
      "Asset", 
      "Liability"
    )
  )
####################################################################### I_SUB_ToT0TB

I_SUB_ToT0TB$`GIC Code` <- Inputs_I_Groups$`GIC Code`
I_SUB_ToT0TB$`Portfolio` <- Inputs_I_Groups$`Portfolio`


# Assume D1 is a dynamic variable representing the column name that matches
D1 <- "LRC - Profit - PVFCF"  # Set this based on your dynamic value

# Find the exact column in I_FX that matches "Opening X - Actuals FX"
closing_columns <- grep(paste0("Opening ", D1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Check if any matching columns were found
if(length(closing_columns) == 0) {
  stop("No matching column found.")
}

# Print the column names for verification
print(paste("Closing Column Names:", paste(closing_columns, collapse = ", ")))

# Select the first matching column
selected_column <- closing_columns[1]

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>%
              select(`GIC Code`, all_of(selected_column)), by = "GIC Code") %>%
  mutate(`LRC - Profit - PVFCF` = !!sym(selected_column))


# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
E1 <- "LRC - Loss - PVFCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", E1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Loss - PVFCF` = !!sym(closing_column_loss))


# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
F1 <- "LRC - Profit - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", F1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Profit - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
G1 <- "LRC - Loss - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", G1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - Loss - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
H1 <- "LRC - CSM"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", H1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - CSM` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
I1 <- "LRC - PRCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", I1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LRC - PRCF` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
J1 <- "LIC - PVFCF"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", J1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - PVFCF` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
K1 <- "LIC - RA"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", K1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - RA` = !!sym(closing_column_loss))

# Assume E1 is a dynamic variable representing the column name that matches "Closing X - Current FX"
L1 <- "LIC - IC"  # You can replace this with your actual dynamic value

# Find the exact column in Workings_I_FX that matches "Closing X - Current FX"
closing_column_loss <- grep(paste0("Opening ", L1, " - Actuals FX"), colnames(I_FX), value = TRUE)

# Perform the left join to bring in the matching data based on GIC Code
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  left_join(I_FX %>% 
              select(`GIC Code`, !!closing_column_loss), by = "GIC Code") %>%
  mutate(`LIC - IC` = !!sym(closing_column_loss))

# Define the column range that you want to check (LRC - Profit - PVFCF to LIC - IC)
columns_to_check <- c("LRC - Profit - PVFCF", "LRC - Loss - PVFCF", 
                      "LRC - Profit - RA", "LRC - Loss - RA", 
                      "LRC - CSM", "LRC - PRCF", 
                      "LIC - PVFCF", "LIC - RA", "LIC - IC")

# Populate 'Asset / Liability' column
I_SUB_ToT0TB <- I_SUB_ToT0TB %>%
  mutate(
    `Asset / Liability` = ifelse(
      rowSums(I_SUB_ToT0TB[, columns_to_check], na.rm = TRUE) < 0, 
      "Asset", 
      "Liability"
    )
  )




############################################################# RE_INSURANCE
Inputs_R_NEW_LR <- wb_to_df(wb, sheet = "R_NEW_LR", col_names = TRUE)
Inputs_R_Groups <- wb_to_df(wb, sheet = "R_Groups", col_names = TRUE)
Inputs_R_NEW_CFs <- wb_to_df(wb, sheet = "R_NEW_CFs", col_names = TRUE)
Inputs_R_NEW_GEN <- wb_to_df(wb, sheet = "R_NEW_GEN", col_names = TRUE)
Inputs_R_IF_GEN <- wb_to_df(wb, sheet = "R_IF_GEN", col_names = TRUE)
Inputs_R_Equity <- wb_to_df(wb, sheet = "R_Equity", col_names = TRUE)
Inputs_R_IF_Patterns <- wb_to_df(wb, sheet = "R_IF_Patterns", col_names = TRUE)
Inputs_R_IF_FCFs <- wb_to_df(wb, sheet = "R_IF_FCFs", col_names = TRUE)
Inputs_ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
Inputs_ExcgangeRates <- wb_to_df(wb, sheet = "ExchangeRates", col_names = TRUE)
YieldCurves <- wb_to_df(wb, sheet = "YieldCurves", col_names = TRUE)
Inputs_R_I_NEW_CFs <- wb_to_df(wb, sheet = "R_I_NEW_CFs", col_names = TRUE)
Inputs_R_IF_GEN_LR <- wb_to_df(wb, sheet = "R_IF_GEN_LR", col_names = TRUE)
Inputs_R_I_IF_FCFs <- wb_to_df(wb, sheet = "R_I_IF_FCFs", col_names = TRUE)
Inputs_R_I_Mapping <- wb_to_df(wb, sheet = "R_I_Mapping", col_names = TRUE)

##################################################define column names

R_EQ_Calc_cols <- c(
  "GRC Code",
  "Reporting Segment",
  "Opening Reinsurance Finance Reserve",
  "Income/(Expense) disclosed in OCI",
  "Closing Reinsurance Finance Reserve",
  "Opening Retained Earnings",
  "Income/(Expense) disclosed in P&L",
  "Closing Retained Earnings"
)

R_I_SUB_Disc1_cols <- c(
  "Reporting Date",
  "GIC Code",
  "GRC Code",
  "Locked-in YC Date",
  "Currency",
  "Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Delay (in Years)",
  "Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)",
  "Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date))",
  "Spot Rate (Unlinked)(Locked-in Date, (Reporting Date - Locked-in Date) + min[Delay, Reporting Period])",
  "Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)",
  "Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date))",
  "Spot Rate (Linked)(Locked-in Date, (Reporting Date - Locked-in Date) + min[Delay, Reporting Period])",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Next Reporting Period)(Locked-in YC, t0)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, t0)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in the Future)(Locked-in YC, t0)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, t1)"
)

R_SUB_Disc1_cols <- c(
  "Reporting Date",
  "GRC Code",
  "Locked-in YC Date",
  "Currency",
  "Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Past Service) - Prev FX",
  "Premium CFs (Unlinked)(Past Service) - Current FX",
  "Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX",
  "Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX",
  "Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Unlinked)(Future Service) - Prev FX",
  "Premium CFs (Unlinked)(Future Service) - Current FX",
  "Investment Component CFs (Unlinked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)",
  "Investment Component CFs (Unlinked)(Receivable in Future) - Prev FX",
  "Investment Component CFs (Unlinked)(Receivable in Future) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX",
  "Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Past Service) - Prev FX",
  "Premium CFs (Linked)(Past Service) - Current FX",
  "Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX",
  "Premium CFs (Linked)(Service in Next Reporting Period) - Current FX",
  "Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)",
  "Premium CFs (Linked)(Future Service) - Prev FX",
  "Premium CFs (Linked)(Future Service) - Current FX",
  "Investment Component CFs (Linked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)",
  "Investment Component CFs (Linked)(Receivable in Future) - Prev FX",
  "Investment Component CFs (Linked)(Receivable in Future) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)",
  "Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX",
  "Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX",
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
  "Spot Rate (Linked)(Remaining Coverage)(Previous Reporting Date, Delay)",
  "Spot Rate (Linked)(Remaining Coverage)(Previous Reporting Date, min[Delay, Reporting Period])",
  "Spot Rate (Linked)(Remaining Coverage)(Current Reporting Date, Delay)",
  "Spot Rate (Linked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date) + Delay)",
  "Spot Rate (Linked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date))",
  "Spot Rate (Linked)(Remaining Coverage)(Locked-in Date, (Reporting Date - Locked-in Date) + min[Delay, Reporting Period])",
  "Spot Rate (Linked)(Incurred Claims)(Previous Reporting Date, Delay)",
  "Spot Rate (Linked)(Incurred Claims)(Previous Reporting Date, min[Delay, Reporting Period])",
  "Spot Rate (Linked)(Incurred Claims)(Current Reporting Date, Delay)",
  "Discounted Premium CFs (Past Service)(Prev YC, Current FX, t0)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Prev YC, Current FX, t0)",
  "Discounted Premium CFs (Future Service)(Prev YC, Current FX, t0)",
  "Discounted Investment Component CFs (Receivable in Future)(Prev YC, Current FX, t0)",
  "Discounted Non-recoveries CFs (Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Previous NP Risk, Prev YC, Prev FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Previous NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in the Past)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Current NP Risk, Prev YC, Current FX, t0)",
  "Discounted Premium CFs (Past Service)(Current YC, t0) - Prev FX",
  "Discounted Premium CFs (Service in Next Reporting Period)(Current YC, t0) - Prev FX",
  "Discounted Premium CFs (Future Service)(Current YC, t0) - Prev FX",
  "Discounted Investment Component CFs (Receivable in Future)(Current YC, t0) - Prev FX",
  "Discounted Non-recoveries CFs (Current YC, t0) - Prev FX",
  "Discounted Premium CFs (Past Service)(Current YC, t0) - Current FX",
  "Discounted Premium CFs (Service in Next Reporting Period)(Current YC, t0) - Current FX",
  "Discounted Premium CFs (Future Service)(Current YC, t0) - Current FX",
  "Discounted Investment Component CFs (Receivable in Future)(Current YC, t0) - Current FX",
  "Discounted Non-recoveries CFs (Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Current NP Risk, Current YC, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Current NP Risk, Current YC, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in the Past)(Current NP Risk, Current YC, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Previous NP Risk, Current YC, t0) - Prev FX",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Previous NP Risk, Current YC, t0) - Prev FX",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Previous NP Risk, Current YC, t0) - Prev FX",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Previous NP Risk, Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Previous NP Risk, Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Previous NP Risk, Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Current NP Risk, Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Current NP Risk, Current YC, t0) - Current FX",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Current NP Risk, Current YC, t0) - Current FX",
  "Discounted Premium CFs (Past Service)(Locked-in YC, t0)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t0)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, t0)",
  "Discounted Investment Component CFs (Receivable in Future)(Locked-in YC, t0)",
  "Discounted Non-recoveries CFs (Locked-in YC, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Locked-in YC and NP Risk, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC and NP Risk, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in the Past)(Locked-in YC and NP Risk, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Locked-in YC and NP Risk, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC and NP Risk, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in the Past)(Locked-in YC and NP Risk, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Locked-in YC and NP Risk, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC and NP Risk, t0)",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Locked-in YC and NP Risk, t0)",
  "Discounted Premium CFs (Past Service)(Locked-in YC, t1)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Locked-in YC, t1)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, t1)",
  "Discounted Investment Component CFs (Receivable in Future)(Locked-in YC, t1)",
  "Discounted Non-recoveries CFs (Locked-in YC, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Locked-in YC and NP Risk, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC and NP Risk, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Locked-in YC and NP Risk, t1)",
  "Discounted Premium CFs (Past Service)(Prev YC, Current FX, t1)",
  "Discounted Premium CFs (Service in Next Reporting Period)(Prev YC, Current FX, t1)",
  "Discounted Premium CFs (Future Service)(Prev YC, Current FX, t1)",
  "Discounted Investment Component CFs (Receivable in Future)(Prev YC, Current FX, t1)",
  "Discounted Non-recoveries CFs (Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Prior Reporting Periods)(Current NP Risk, Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Current NP Risk, Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in the Past)(Current NP Risk, Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Next Reporting Period)(Current NP Risk, Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Current NP Risk, Prev YC, Current FX, t1)",
  "Discounted Recoveries CFs (On Claims Incurred in the Future)(Current NP Risk, Prev YC, Current FX, t1)"
)

R_SUB_Disc2_cols <- c(
  "Reporting Date",
  "GRC Code",
  "Locked-in YC Date",
  "Currency",
  "Coverage Units (Undiscounted)",
  "Reporting Period (0 = current)",
  "Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date) + # Reporting Periods * Reporting Period)",
  "Spot Rate (Locked-in Date, (Reporting Date - Locked-in Date))",
  "Discounted Coverage Units (Locked-in YC, t0)"
)

R_SUB_LR_cols <- c(
  "GRC Code",
  "GIC Code",
  "GIC Measurement model",
  "Portion of Group Cover by Reinsurance",
  "Ceding %",
  "Effective Recovery from GRC",
  "Non-onerous/Onerous (Opening)",
  "Non-onerous/Onerous (After Non FX change in FCF)",
  "GIC Currency",
  "GRC Currency",
  "Opening LRC - Loss - PVFCF",
  "New LRC - Loss - PVFCF",
  "LRC - Loss - PVFCF - Post Roll Forward",
  "Effect of Changes in Interest rates on LRC - Loss - PVFCF",
  "Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)",
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - Non FX",
  "Effect on LRC - Loss - PVFCF of Total Experience Variance (Future) - FX",
  "Effect on LRC - Loss - PVFCF of Changes in Interest Rates (2/2)",
  "Closing LRC - Loss - PVFCF",
  "Opening LRC - Loss - RA",
  "New LRC - Loss - RA",
  "LRC - Loss - RA - Post Roll Forward",
  "Effect of Changes in Interest rates on LRC - Loss - RA",
  "Effect on LRC - Loss - RA of Removal of Expected Claims and Other Expenses Incurred (Current)",
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - Non FX",
  "Effect on LRC - Loss - RA of Total Experience Variance (Future) - FX",
  "Effect on LRC - Loss - RA of Changes in Interest Rates (2/2)",
  "Closing LRC - Loss - RA",
  "Opening/New LRC - Loss",
  "Effect of Changes in Interest rates on LRC - Loss",
  "Effect on LRC - Loss - Removal of Expected Claims and Other Expenses Incurred (Current)",
  "Effect on LRC - Loss - Total Experience Variance (Future) - FX",
  "Effect on LRC - Loss - Changes in Interest Rates (2/2)",
  "Closing LRC - Loss",
  "Total Change in FCF (Future) Non FX",
  "Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX",
  "ARC - P&L pass through factor",
  "Expected Covered CFs (Future)(New)",
  "Expected Covered CFs (Future)(Opening)",
  "Expected Covered CFs (Future)(Closing)",
  "Change in covered FCFs (Future)",
  "Opening/New LRC - Loss adjusted for Effective Recovery from GRC",
  "Opening/New ARC - Loss Recovery Component - Sub-GRC",
  "Effect of Changes in Interest rates on Loss Recovery - Sub-GRC",
  "Effect on Loss Recovery - Removal of Expected Claims and Other Expenses Incurred (Current) - Sub-GRC",
  "Loss Recovered",
  "Effect on Loss Recovery Component - Change in interest rates",
  "Effect of Currency exchange rate differences",
  "Pre-Closing ARC - Loss Recovery Component - Sub-GRC",
  "GIC LC Allocation Close",
  "B119F Cap",
  "Closing ARC - Loss Recovery Component - Sub-GRC"
)

R_I_IN_Disc_cols <- c(
  "Reporting Date",
  "GIC Code",
  "GRC Code",
  "Locked-in YC Date",
  "Currency",
  "Treaty covered Claim and Other CFs (Unlinked)(Incurred in Current Reporting Period)",
  "Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)",
  "Treaty covered Claim and Other CFs (Linked)(Incurred in Current Reporting Period)",
  "Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)",
  "Delay (in Years)",
  "Spot Rate (Unlinked)(Locked-in Date, Delay)",
  "Spot Rate (Unlinked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Spot Rate (Linked)(Locked-in Date, Delay)",
  "Spot Rate (Linked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)",
  "Discounted Treaty covered Claim and Other CFs (Locked-in YC, Locked-in Date)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Current Reporting Period)(Locked-in YC, Reporting Date)",
  "Discounted Treaty covered Claim and Other CFs (Incurred in Future Reporting Periods)(Locked-in YC, Reporting Date)",
  "Discounted Treaty covered Claim and Other CFs (Locked-in YC, Reporting Date)"
)

R_IN_Disc_cols <- c(
  "Reporting Date",
  "GRC Code",
  "Locked-in YC Date",
  "Currency",
  "Premium CFs (Unlinked)(Service in Current Reporting Period)",
  "Premium CFs (Unlinked)(Future Service)",
  "Investment Component CFs (Unlinked)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)",
  "Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)",
  "Premium CFs (Linked)(Service in Current Reporting Period)",
  "Premium CFs (Linked)(Future Service)",
  "Investment Component CFs (Linked)",
  "Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)",
  "Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)",
  "Delay (in Years)",
  "Spot Rate (Unlinked)(Locked-in Date, Delay)",
  "Spot Rate (Unlinked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Spot Rate (Linked)(Locked-in Date, Delay)",
  "Spot Rate (Linked)(Locked-in Date, min[Delay, Reporting Date - Locked-in Date])",
  "Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)",
  "Discounted Investment Component CFs (Locked-in YC, Locked-in Date)",
  "Discounted Non-recoveries CFs (Locked-in YC, Locked-in Date)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)",
  "Discounted Recoveries CFs (Locked-in YC, Locked-in Date)",
  "Discounted Premium CFs (Current Service)(Locked-in YC, Reporting Date)",
  "Discounted Premium CFs (Future Service)(Locked-in YC, Reporting Date)",
  "Discounted Investment Component CFs (Locked-in YC, Reporting Date)",
  "Discounted Non-recoveries CFs (Locked-in YC, Reporting Date)",
  "Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC, Reporting Date)",
  "Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC, Reporting Date)",
  "Discounted Recoveries CFs (Locked-in YC, Reporting Date)"
)

R_IN_LR_cols <- c(
  "GRC Code",
  "GIC Code",
  "GIC Measurement model",
  "Ceding %",
  "Portion of GIC covered by Treaty",
  "New LRC - Loss - PVFCF",
  "New LRC - Loss - RA",
  "New LRC - Loss",
  "New ARC - Loss Recovery"
)

R_IN_Calc_cols <- c(
  "GRC Code",
  "Purchased/Acquired",
  "Pre-recognition CFs",
  "New ARC - Premium CFs (Current Service)",
  "New ARC - Premium CFs (Future Service)",
  "New ARC - Premium CFs",
  "New ARC - Investment Component CFs",
  "New ARC - Recoveries CFs (On Claims Incurred in Current Reporting Period)",
  "New ARC - Recoveries CFs (On Claims Incurred in Future Reporting Periods)",
  "New ARC - Recoveries CFs",
  "New ARC - Total Outflows",
  "New ARC - PVFCF",
  "RA % of ABS(PVFCF Recoveries)",
  "New ARC - RA",
  "New ARC - FCF",
  "Retroactive Cover?",
  "New ARC - CSM - Non-loss-recovery",
  "New ARC - Loss Recovery",
  "New ARC - CSM"
)

R_IN_Pre_FX_cols <- c(
  "GRC Code",
  "Transfer of Pre-recognition CFs (Purchased)",
  "Transfer of Pre-recognition CFs (Purchased)(2)",
  "New ARC - Premium CFs (Purchased)",
  "New ARC - Investment Component CFs (Purchased)",
  "New ARC - Recoveries CFs (Purchased)",
  "New ARC - RA (Purchased)",
  "New ARC - CSM - Non-Loss Recovery (Purchased)",
  "New ARC - Loss Recovery (Purchased)",
  "New ARC - CSM (Purchased)",
  "Transfer of Pre-recognition CFs (Acquired)",
  "Transfer of Pre-recognition CFs (Acquired)(2)",
  "New ARC - Premium CFs (Acquired)",
  "New ARC - Investment Component CFs (Acquired)",
  "New ARC - Recoveries CFs (Acquired)",
  "New ARC - RA (Acquired)",
  "New ARC - CSM - Non-Loss Recovery (Acquired)",
  "New ARC - Loss Recovery (Acquired)",
  "New ARC - CSM (Acquired)"
)

R_IN_ToSL_cols <- c(
  "GRC Code",
  "Transfer of Pre-recognition CFs (Purchased) - Actuals FX",
  "Transfer of Pre-recognition CFs (Purchased)(2) - Actuals FX",
  "New ARC - Premium CFs (Purchased) - Actuals FX",
  "New ARC - Investment Component CFs (Purchased) - Actuals FX",
  "New ARC - Recoveries CFs (Purchased) - Actuals FX",
  "New ARC - RA (Purchased) - Actuals FX",
  "New ARC - CSM - Non-Loss Recovery (Purchased) - Actuals FX",
  "New ARC - Loss Recovery (Purchased) - Actuals FX",
  "New ARC - PVFCF - Loss Recovery (Purchased) - Actuals FX",
  "New ARC - PVFCF - Non-Loss Recovery (Purchased) - Initial Loss Recovery - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired) - Actuals FX",
  "Transfer of Pre-recognition CFs (Acquired)(2) - Actuals FX",
  "New ARC - Premium CFs (Acquired) - Actuals FX",
  "New ARC - Investment Component CFs (Acquired) - Actuals FX",
  "New ARC - Recoveries CFs (Acquired) - Actuals FX",
  "New ARC - RA (Acquired) - Actuals FX",
  "New ARC - CSM - Non-Loss Recovery (Acquired) - Actuals FX",
  "New ARC - Loss Recovery (Acquired) - Actuals FX",
  "New ARC - PVFCF - Loss Recovery (Acquired) - Actuals FX",
  "New ARC - PVFCF - Non-Loss Recovery (Acquired) - Initial Loss Recovery - Actuals FX"
)

R_SUB_ToCSM_cols <- c("GRC Code",
                  "ARC - CSM Release - Reporting Period 1", "ARC - CSM Release - Reporting Period 2", 
                  "ARC - CSM Release - Reporting Period 3", "ARC - CSM Release - Reporting Period 4", 
                  "ARC - CSM Release - Reporting Period 5", "ARC - CSM Release - Reporting Period 6", 
                  "ARC - CSM Release - Reporting Period 7", "ARC - CSM Release - Reporting Period 8", 
                  "ARC - CSM Release - Reporting Period 9", "ARC - CSM Release - Reporting Period 10", 
                  "ARC - CSM Release - Reporting Period 11", "ARC - CSM Release - Reporting Period 12", 
                  "ARC - CSM Release - Reporting Period 13", "ARC - CSM Release - Reporting Period 14", 
                  "ARC - CSM Release - Reporting Period 15", "ARC - CSM Release - Reporting Period 16", 
                  "ARC - CSM Release - Reporting Period 17", "ARC - CSM Release - Reporting Period 18", 
                  "ARC - CSM Release - Reporting Period 19", "ARC - CSM Release - Reporting Period 20", 
                  "ARC - CSM Release - Reporting Period 21", "ARC - CSM Release - Reporting Period 22", 
                  "ARC - CSM Release - Reporting Period 23", "ARC - CSM Release - Reporting Period 24", 
                  "ARC - CSM Release - Reporting Period 25", "ARC - CSM Release - Reporting Period 26", 
                  "ARC - CSM Release - Reporting Period 27", "ARC - CSM Release - Reporting Period 28", 
                  "ARC - CSM Release - Reporting Period 29", "ARC - CSM Release - Reporting Period 30", 
                  "ARC - CSM Release - Reporting Period 31", "ARC - CSM Release - Reporting Period 32", 
                  "ARC - CSM Release - Reporting Period 33", "ARC - CSM Release - Reporting Period 34", 
                  "ARC - CSM Release - Reporting Period 35", "ARC - CSM Release - Reporting Period 36", 
                  "ARC - CSM Release - Reporting Period 37", "ARC - CSM Release - Reporting Period 38", 
                  "ARC - CSM Release - Reporting Period 39", "ARC - CSM Release - Reporting Period 40", 
                  "ARC - CSM Release - Reporting Period 41", "ARC - CSM Release - Reporting Period 42", 
                  "ARC - CSM Release - Reporting Period 43", "ARC - CSM Release - Reporting Period 44", 
                  "ARC - CSM Release - Reporting Period 45", "ARC - CSM Release - Reporting Period 46", 
                  "ARC - CSM Release - Reporting Period 47", "ARC - CSM Release - Reporting Period 48", 
                  "ARC - CSM Release - Reporting Period 49", "ARC - CSM Release - Reporting Period 50", 
                  "ARC - CSM Release - Reporting Period 51", "ARC - CSM Release - Reporting Period 52", 
                  "ARC - CSM Release - Reporting Period 53", "ARC - CSM Release - Reporting Period 54", 
                  "ARC - CSM Release - Reporting Period 55", "ARC - CSM Release - Reporting Period 56", 
                  "ARC - CSM Release - Reporting Period 57", "ARC - CSM Release - Reporting Period 58", 
                  "ARC - CSM Release - Reporting Period 59", "ARC - CSM Release - Reporting Period 60", 
                  "ARC - CSM Release - Reporting Period 61", "ARC - CSM Release - Reporting Period 62", 
                  "ARC - CSM Release - Reporting Period 63", "ARC - CSM Release - Reporting Period 64", 
                  "ARC - CSM Release - Reporting Period 65", "ARC - CSM Release - Reporting Period 66", 
                  "ARC - CSM Release - Reporting Period 67", "ARC - CSM Release - Reporting Period 68", 
                  "ARC - CSM Release - Reporting Period 69", "ARC - CSM Release - Reporting Period 70", 
                  "ARC - CSM Release - Reporting Period 71", "ARC - CSM Release - Reporting Period 72", 
                  "ARC - CSM Release - Reporting Period 73", "ARC - CSM Release - Reporting Period 74", 
                  "ARC - CSM Release - Reporting Period 75", "ARC - CSM Release - Reporting Period 76", 
                  "ARC - CSM Release - Reporting Period 77", "ARC - CSM Release - Reporting Period 78", 
                  "ARC - CSM Release - Reporting Period 79", "ARC - CSM Release - Reporting Period 80", 
                  "ARC - CSM Release - Reporting Period 81", "ARC - CSM Release - Reporting Period 82", 
                  "ARC - CSM Release - Reporting Period 83", "ARC - CSM Release - Reporting Period 84", 
                  "ARC - CSM Release - Reporting Period 85", "ARC - CSM Release - Reporting Period 86", 
                  "ARC - CSM Release - Reporting Period 87", "ARC - CSM Release - Reporting Period 88", 
                  "ARC - CSM Release - Reporting Period 89", "ARC - CSM Release - Reporting Period 90", 
                  "ARC - CSM Release - Reporting Period 91", "ARC - CSM Release - Reporting Period 92", 
                  "ARC - CSM Release - Reporting Period 93", "ARC - CSM Release - Reporting Period 94", 
                  "ARC - CSM Release - Reporting Period 95", "ARC - CSM Release - Reporting Period 96", 
                  "ARC - CSM Release - Reporting Period 97", "ARC - CSM Release - Reporting Period 98", 
                  "ARC - CSM Release - Reporting Period 99", "ARC - CSM Release - Reporting Period 100")

R_I_LR_cols <- c( 
    "GRC Code", 
    "GIC Code",
    "GIC Measurement Model",
    "Ceding %",
    "Portion of GIC Covered by Treaty",
    "New LRC - Loss - PVFCF",
    "New LRC - Loss - RA",
    "New LRC - Loss",
    "New ARC - Loss Recovery"
)
 
R_SUB_ToT1TB_cols <- c(
    "GRC Code", "Portfolio", "Asset / Liability",
    "ARC - PVFCF - Non-Loss Recovery", "ARC - RA",
    "ARC - CSM", "ARC - PVFCF - Loss Recovery",
    "ARC - PRCF", "ARIC - PVFCF", "ARIC - RA", "ARIC - IC"
)

R_SUB_ToTOTB_cols <- c(
    "GRC Code", "Portfolio", "Asset / Liability",
    "ARC - PVFCF - Non-Loss Recovery", "ARC - RA",
    "ARC - CSM", "ARC - PVFCF - Loss Recovery",
    "ARC - PRCF", "ARIC - PVFCF", "ARIC - RA", "ARIC - IC"
)

R_FX_cols <- c(
  "GRC Code", "Currency", "Opening ARC - PRCF - Actuals FX", 
  "Transfer of Pre-recognition CFs (Purchased) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired) - Actuals FX", 
  "Pre-recognition CF Receipts - Actuals FX", 
  "Impairment of PRCF Liability - Current FX", 
  "Reversal of Impairment of PRCF Liability - Current FX", 
  "Closing ARC - PRCF - Actuals FX", 
  "Closing ARC - PRCF - Current FX", 
  "Closing ARC - PRCF - Net foreign exchange income / (expenses)", 
  "Opening ARC - PVFCF - Non-Loss Recovery - Actuals FX", 
  "New ARC - Premium CFs (Purchased) - Actuals FX", 
  "New ARC - Investment Component CFs (Purchased) - Actuals FX", 
  "New ARC - Recoveries CFs (Purchased) - Actuals FX", 
  "New ARC - Premium CFs (Acquired) - Actuals FX", 
  "New ARC - Investment Component CFs (Acquired) - Actuals FX", 
  "New ARC - Recoveries CFs (Acquired) - Actuals FX", 
  "New ARC - PVFCF - Loss Recovery (Purchased) - Actuals FX", 
  "New ARC - PVFCF - Loss Recovery (Acquired) - Actuals FX", 
  "Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - Actuals FX", 
  "Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - OCI - Actuals FX", 
  "RI Premium Experience Variance (Past/Current) - Actuals FX", 
  "Effect on ARC - PVFCF of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Non-Loss Recovery - Actuals FX", 
  "Effect on ARC - PVFCF of Total Experience Variance (Future) - Non-Loss Recovery - Current FX", 
  "Effect on ARC - PVFCF of Change in Exchange rates - Non-Loss Recovery - Current FX", 
  "Effect on ARC - PVFCF of Change in NP Risk - Non-Loss Recovery - Current FX", 
  "Effect on ARC - PVFCF of Changes in Interest Rates - Non-Loss Recovery - Current FX", 
  "Effect on ARC - PVFCF - Non-Loss Recovery adjustment due to uncovered cash flows - Current FX", 
  "Premium Payments - Actuals FX", 
  "Transfer of Reinsurance Investment Components - Actuals FX", 
  "Closing ARC - PVFCF - Actuals FX", 
  "Closing ARC - PVFCF - Non-Loss Recovery - Current FX", 
  "Closing ARC - PVFCF - Non-Loss Recovery Net foreign exchange income / (expenses)", 
  "Opening ARC - RA - Actuals FX", 
  "New ARC - RA (Purchased) - Actuals FX", 
  "New ARC - RA (Acquired) - Actuals FX", 
  "Interest Accreted on ARC - RA - Actuals FX", 
  "Interest Accreted on ARC - RA - OCI - Actuals FX", 
  "Effect on ARC - RA of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Actuals FX", 
  "Effect on ARC - RA of Total Experience Variance (Future - Non FX) - Current FX", 
  "Effect on ARC - RA - Change in Exchange rates - Current FX", 
  "Effect on ARC - RA of Change in NP Risk - Current FX", 
  "Effect on ARC - RA of Changes in Interest Rates - Current FX", 
  "Closing ARC - RA - Actuals FX", 
  "Closing ARC - RA - Current FX", 
  "Closing ARC - RA - Net foreign exchange income / (expenses)", 
  "Opening ARC - CSM - Actuals FX", 
  "New ARC - CSM - Non-Loss Recovery (Purchased) - Actuals FX", 
  "New ARC - Loss Recovery (Purchased) - Actuals FX", 
  "New ARC - CSM - Non-Loss Recovery (Acquired) - Actuals FX", 
  "New ARC - Loss Recovery (Acquired) - Actuals FX", 
  "Interest Accreted on ARC - CSM - Actuals FX", 
  "Effect on ARC - CSM - Total Experience Variance (Future - Non FX) - Current FX", 
  "Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC - Current FX", 
  "Release in ARC - CSM - Actuals FX", 
  "Transfer of Pre-recognition CFs (Purchased)(2) - Actuals FX", 
  "Transfer of Pre-recognition CFs (Acquired)(2) - Actuals FX", 
  "Closing ARC - CSM - Actuals FX", 
  "Closing ARC - CSM - Current FX", 
  "Closing ARC - CSM - Net foreign exchange income / (expenses)", 
  "Opening ARC - PVFCF - Loss Recovery - Actuals FX", 
  "New PVFCF - Loss Recovery - Actuals FX", 
  "Interest Accreted on ARC - PVFCF - Loss Recovery - Actuals FX", 
  "Interest Accreted on ARC - PVFCF - Loss Recovery - OCI - Actuals FX", 
  "Effect on ARC - PVFCF - Loss Recovery - Release of Loss recovery - Actuals FX", 
  "Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period - Actuals FX", 
  "Effect on ARC - PVFCF - Loss Recovery adjustment due to uncovered cash flows - Current FX", 
  "Effect on ARC - PVFCF - Loss Recovery due to Changes in Interest Rates - Current FX", 
  "Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences - Current FX", 
  "Closing ARC - PVFCF - Loss Recovery - Actual FX", 
  "Closing ARC - PVFCF - Loss Recovery - Current FX", 
  "Closing ARC - Loss Recovery - Net foreign exchange income / (expenses)", 
  "Opening ARIC - PVFCF - Actuals FX", 
  "Interest Accreted on ARIC - PVFCF - Actuals FX", 
  "Interest Accreted on ARIC - PVFCF - OCI - Actuals FX", 
  "Effect on ARIC - PVFCF of Changes to Recoveries CFs (Past) - Current FX", 
  "Effect on ARIC - PVFCF of Change in Exchange Rates - Current FX", 
  "Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX", 
  "Effect on ARIC - PVFCF of Change in NP Risk - Current FX", 
  "Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX", 
  "Recoveries Receipts - Actuals FX", 
  "Closing ARIC - PVFCF - Actuals FX", 
  "Closing ARIC - PVFCF - Current FX", 
  "Closing ARIC - PVFCF - Net foreign exchange income / (expenses)", 
  "Opening ARIC - RA - Actuals FX", 
  "Interest Accreted on ARIC - RA - Actuals FX", 
  "Interest Accreted on ARIC - RA - OCI - Actuals FX", 
  "Effect on ARIC - RA of Changes to Recoveries CFs (Past) - Current FX", 
  "Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX", 
  "Effect on ARIC - RA of Change in NP Risk - Current FX", 
  "Effect on ARIC - RA of Change in Exchange Rates - Current FX", 
  "Effect on ARIC - RA of Changes in Interest Rates - Current FX", 
  "Closing ARIC - RA - Actuals FX", 
  "Closing ARIC - RA - Current FX", 
  "Closing ARIC - RA - Net foreign exchange income / (expenses)", 
  "Opening ARIC - IC - Actuals FX", 
  "Effect on ARIC - IC of Changes to IC CFs (Past) - Current FX", 
  "Transfer of Reinsurance Investment Components (2) - Actuals FX", 
  "Investment Component Receipts - Actuals FX", 
  "Closing ARIC - IC - Actuals FX", 
  "Closing ARIC - IC - Current FX", 
  "Closing ARIC - IC - Net foreign exchange income / (expenses)"
)

R_SUB_Calc_cols <- c(
  "GRC Code", "Currency", "Locked-in YC Date", "RA % of ABS(PVFCF Recoveries)", 
  "Opening ARC - PVFCF (Non-recoveries)", "Opening ARC - PVFCF (Non-recoveries) (Locked-in YC)", 
  "Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (Prev YC)", 
  "Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)", 
  "Effect on ARC - PVFCF (Non-recoveries) of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening ARC - PVFCF (Non-recoveries)", 
  "New ARC - PVFCF (Non-recoveries)", "New ARC - PVFCF (Non-recoveries) - Post Roll Forward", 
  "Interest Accreted on New ARC - PVFCF (Non-recoveries)", "ARC - PVFCF (Non-recoveries) - Post Roll Forward", 
  "Interest Accreted on ARC - PVFCF (Non-recoveries)", "Interest Accreted on ARC - PVFCF (Non-recoveries) (Locked-in YC)", 
  "Expected Premium (Past/Current)(Opening)", "Expected Premium (Past/Current)(New)", 
  "Premium Payments (Past/Current)", "Expected Premium (Past/Current)(Closing)", 
  "RI Premium Experience Variance (Past/Current)", 
  "ARC - PVFCF (Non-recoveries) - Post Premium Experience Variances (Past/Current)", 
  "Expected Non-recoveries CFs (Future)(Opening)", "Expected Non-recoveries CFs (Future)(New)", 
  "Non-recoveries Receipts/Payments/Transfers (Future)", "Expected Non-recoveries CFs (Future)(Closing)", 
  "Effect on ARC - PVFCF (Non-recoveries) of Non-recoveries CFs Experience Variance (Future - Non FX)", 
  "ARC - PVFCF (Non-recoveries) - Post Non-recoveries CFs (Non FX) Experience Variance (Future)", 
  "Premium Payments", "Transfer of Reinsurance Investment Components", 
  "ARC - PVFCF (Non-recoveries) - Post Payments/Receipts/Transfers", 
  "Closing ARC - PVFCF (Non-recoveries) - Prev FX", "Closing ARC - PVFCF (Non-recoveries) - Current FX", 
  "Effect on ARC - PVFCF (Non-recoveries) of Changes in Interest Rates (2/2)", 
  "Effect on ARC - PVFCF (Non-recoveries) of Changes in Interest Rates", 
  "Effect on ARC - PVFCF (Non-recoveries) of Non-recoveries CFs Experience Variance (Future - FX)", 
  "Opening ARC - PVFCF (Recoveries)", "Opening ARC - PVFCF (Recoveries) (Locked-in YC)", 
  "Opening ARC - PVFCF (Recoveries) - Post Roll Forward (Prev YC)", 
  "Opening ARC - PVFCF (Recoveries) - Post Roll Forward (LIYC)", 
  "Effect on ARC - PVFCF (Recoveries) of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening ARC - PVFCF (Recoveries)", 
  "Interest Accreted on Opening ARC - PVFCF (Recoveries) (Locked-in YC)", 
  "New ARC - PVFCF (Recoveries)", "New ARC - PVFCF (Recoveries) - Post Roll Forward", 
  "Interest Accreted on New ARC - PVFCF (Recoveries)", "ARC - PVFCF (Recoveries) - Post Roll Forward", 
  "Interest Accreted on ARC - PVFCF (Recoveries)", "Interest Accreted on ARC - PVFCF (Recoveries) (Locked-in YC)", 
  "Expected Recoveries CFs (Current)(Opening)", "Expected Recoveries CFs (Current)(New)", 
  "Effect on ARC - PVFCF (Recoveries) of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current)", 
  "ARC - PVFCF (Recoveries) - Post Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current)", 
  "Expected Recoveries CFs (Future)(Opening)", "Expected Recoveries CFs (Future)()(New)", 
  "Expected Recoveries CFs (Future)()(Closing)", 
  "Effect on ARC - PVFCF (Recoveries) of Recoveries CFs Experience Variance (Future - Non FX)", 
  "ARC - PVFCF (Recoveries) - Post Recoveries CFs Non FX Experience Variances (Future)", 
  "Closing ARC - PVFCF (Recoveries)(Previous NP Risk, Current YC, Prev FX)", 
  "Closing ARC - PVFCF (Recoveries)(Previous NP Risk, Current YC, Current FX)", 
  "Closing ARC - PVFCF (Recoveries)(Current NP Risk, Current YC, Current FX)", 
  "Effect on ARC - PVFCF (Recoveries) of Changes in Interest Rates (2/2)", 
  "Effect on ARC - PVFCF (Recoveries) of Changes in Interest Rates", 
  "Effect on ARC - PVFCF (Recoveries) of Recoveries CFs Experience Variance (Future - FX)", 
  "Effect on ARC - PVFCF (Recoveries) of Recoveries CFs Experience Variance (Future - FX and Non FX)", 
  "Effect on ARC - PVFCF (Recoveries) of Change in NP Risk", 
  "Opening ARC - PVFCF", "Interest Accreted on Opening ARC - PVFCF", 
  "Interest Accreted on Opening ARC - PVFCF (Locked-in YC)", 
  "Effect on ARC - PVFCF of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current)", 
  "Effect on ARC - PVFCF of Total Experience Variance (Future - Non FX)", 
  "Effect on ARC - PVFCF of Total Experience Variance (Future - FX)", 
  "Effect on ARC - PVFCF of Total Experience Variance (Future - FX and Non FX)", 
  "Effect on ARC - PVFCF of Change in Exchange rates", "Effect on ARC - PVFCF of Change in NP Risk", 
  "Effect on ARC - PVFCF of Changes in Interest Rates", "Closing ARC - PVFCF", 
  "Opening ARC - RA", "Effect on ARC - RA of Changes in Interest Rates (1/2)", 
  "Interest Accreted on Opening ARC - RA", "Interest Accreted on Opening ARC - RA (Locked-in YC)", 
  "New ARC - RA", "Interest Accreted on New ARC - RA", "Interest Accreted on ARC - RA", 
  "Interest Accreted on ARC - RA (Locked-in YC)", "ARC - RA - Post Roll Forward", 
  "Closing ARC - RA", "Effect on ARC - RA of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current)", 
  "ARC - RA - Post Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current)", 
  "Effect on ARC - RA of Total Experience Variance (Future - Non FX)", 
  "Effect on ARC - RA - Change in Exchange rates", "Effect on ARC - RA of Change in NP Risk", 
  "Effect on ARC - RA of Changes in Interest Rates (2/2)", "Effect on ARC - RA of Changes in Interest Rates", 
  "Opening ARC - CSM", "Opening ARC - CSM - Post Roll Forward", 
  "New ARC - CSM - Non-loss-recovery", "New ARC - Loss recovery", 
  "New ARC CSM", "New ARC - CSM - Post Roll Forward", "ARC - CSM - Post Roll Forward", 
  "Interest Accreted on ARC - CSM", "Total Change in FCF (Future - Non FX)", 
  "Effect on ARC - CSM - Experience Variance (Future - Non FX)",
  "Effect on ARC - CSM - Total Experience Variance (Future - Non FX)",
   "ARC - CSM - Post Total Experience Variance (Future)",
                      "Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC",
                      "ARC - CSM - Post Reversal of Cash flows not affecting the GRC",
                      "Retroactive Cover?",
                      "Release in ARC - CSM",
                      "Closing ARC - CSM",
                      "Opening ARC - PVFCF - Loss Recovery",
                      "New PVFCF - Loss Recovery",
                      "Interest Accreted on ARC - PVFCF - Loss Recovery",
                      "Interest Accreted on ARC - PVFCF - Loss Recovery (Locked-in YC)",
                      "Effect on ARC - PVFCF - Loss Recovery - Release of Loss recovery",
                      "Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period",
                      "Effect on ARC - PVFCF - Loss Recovery due to Changes in Interest Rates",
                      "Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences",
                      "Effect on ARC - PVFCF - Loss Recovery adjustment due to uncovered cash flows",
                      "Closing ARC - PVFCF - Loss Recovery",
                      "Opening ARC - PVFCF - Non-Loss Recovery",
                      "Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery",
                      "Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery (Locked-in YC)",
                      "Effect on ARC - PVFCF of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Non-Loss Recovery",
                      "Effect on ARC - PVFCF of Total Experience Variance (Future) - Non-Loss Recovery",
                      "Effect on ARC - PVFCF of Change in Exchange rates - Non-Loss Recovery",
                      "Effect on ARC - PVFCF of Change in NP Risk - Non-Loss Recovery",
                      "Effect on ARC - PVFCF of Changes in Interest Rates - Non-Loss Recovery",
                      "Effect on ARC - PVFCF - Non-Loss Recovery adjustment due to uncovered cash flows",
                      "Closing ARC - PVFCF - Non-Loss Recovery",
                      "Opening ARIC - PVFCF",
                      "Opening ARIC - PVFCF (Locked-in YC)",
                      "ARIC - PVFCF - Post Roll Forward",
                      "ARIC - PVFCF - Post Roll Forward (Locked-in YC)",
                      "Interest Accreted on ARIC - PVFCF",
                      "Interest Accreted on ARIC - PVFCF (Locked-in YC)",
                      "Recoveries Receipts (Past)",
                      "Effect on ARIC - PVFCF of Changes to Recoveries CFs (Past)",
                      "ARIC - PVFCF - Post Changes to Recoveries CFs (Past)",
                      "Recoveries Receipts (On Claims Incurred in Current Reporting Period)",
                      "Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current)",
                      "ARIC - PVFCF - Post Addition of Recoveries on New Claims and Other Expenses Incurred (Current)",
                      "Effect on ARIC - PVFCF of move from LIYC",
                      "ARIC - PVFCF - Post Changes in interest rates",
                      "Effect on ARIC - PVFCF of Change in Exchange Rates",
                      "ARIC - PVFCF - Post Changes to Recoveries CFs (Past) - Current FX",
                      "Effect on ARIC - PVFCF of Change in NP Risk",
                      "ARIC - PVFCF - Post Change in NP Risk",
                      "Effect on ARIC - PVFCF of Changes in Interest Rates",
                      "Closing ARIC - PVFCF",
                      "Recoveries Receipts",
                      "Opening ARIC - RA",
                      "Closing ARIC - RA",
                      "Interest Accreted on ARIC - RA",
                      "Interest Accreted on ARIC - RA (Locked-in YC)",
                      "Effect on ARIC - RA of Changes to Recoveries CFs (Past)",
                      "Effect on ARIC - RA of Change in NP Risk",
                      "Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current)",
                      "Effect on ARIC - RA of Change in Exchange Rates",
                      "Effect on ARIC - RA of Changes in Interest Rates",
                      "Opening ARIC - IC",
                      "Investment Component Receipts",
                      "Closing ARIC - IC",
                      "Effect on ARIC - IC of Changes to IC CFs (Past)",
                      "Opening ARC - PRCF",
                      "Pre-recognition CF Receipts",
                      "Impairment of PRCF Liability",
                      "Reversal of Impairment of PRCF Liability",
                      "Transfer of Pre-recognition CFs",
                      "Closing ARC - PRCF"
)

R_SUB_ToSL_cols <- c(
"GRC Code", 
"Interest Accreted on ARIC - PVFCF - Actuals FX",
"Interest Accreted on ARIC - PVFCF - OCI - Actuals FX",
"Effect on ARIC - PVFCF of Changes to Recoveries CFs (Past) - Current FX",
"Effect on ARIC - PVFCF of Change in Exchange Rates - Current FX",
"Effect on ARIC - PVFCF of Change in NP Risk - Current FX",
"Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX",
"Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX",
"Recoveries Receipts - Actuals FX",
"Recoveries Receipts (2) - Actuals FX",
"Interest Accreted on ARIC - RA - Actuals FX",
"Interest Accreted on ARIC - RA - OCI - Actuals FX",
"Effect on ARIC - RA of Changes to Recoveries CFs (Past) - Current FX",
"Effect on ARIC - RA of Change in NP Risk - Current FX",
"Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX",
"Effect on ARIC - RA of Change in Exchange Rates - Current FX",
"Effect on ARIC - RA of Changes in Interest Rates - Current FX",
"Effect on ARIC - IC of Changes to IC CFs (Past) - Current FX",
"Investment Component Receipts - Actuals FX",
"Investment Component Receipts (2) - Actuals FX",
"Pre-recognition CF Receipts - Actuals FX",
"Pre-recognition CF Receipts (2) - Actuals FX",
"Impairment of PRCF Liability - Current FX",
"Reversal of Impairment of PRCF Liability - Current FX",
"Closing ARC - PRCF - Net foreign exchange income / (expenses)",
"Closing ARC - PVFCF - Non-Loss Recovery Net foreign exchange income / (expenses)",
"Closing ARC - RA - Net foreign exchange income / (expenses)",
"Closing ARC - CSM - Net foreign exchange income / (expenses)",
"Closing ARC - Loss Recovery - Net foreign exchange income / (expenses)",
"Closing ARIC - PVFCF - Net foreign exchange income / (expenses)",
"Closing ARIC - RA - Net foreign exchange income / (expenses)",
"Closing ARIC - IC - Net foreign exchange income / (expenses)",
"Effect on ARC - PVFCF - Non-Loss Recovery adjustment due to uncovered cash flows - Current FX"
)
#####################################################################Create data drames

R_EQ_Calc <- data.frame(matrix(ncol = length(R_EQ_Calc_cols), nrow = length(Inputs_R_Groups$`GRC Code`)))
colnames(R_EQ_Calc) <- R_EQ_Calc_cols

R_I_SUB_Disc1 <- data.frame(matrix(ncol = length(R_I_SUB_Disc1_cols), nrow = length(Inputs_I_IF_FCFs$`Reporting Date)))
colnames(R_I_SUB_Disc1) <- R_I_SUB_Disc1_cols

R_SUB_Disc1 <- data.frame(matrix(ncol = length(R_SUB_Disc1_cols), nrow = length(Inputs_R_IF_FCFs$`Reporting Date`)))
colnames(R_SUB_Disc1) <- R_SUB_Disc1_cols

R_SUB_Calc <- data.frame(matrix(ncol = length(R_SUB_Calc_cols), nrow = length(Inputs_R_Groups$`GRC Code`)))
colnames(R_SUB_Calc) <- R_SUB_Calc_cols

R_FX <- data.frame(matrix(ncol = length(R_FX_cols), nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_FX) <- R_FX_cols

R_SUB_ToSL <- data.frame(matrix(ncol = length(R_SUB_ToSL_cols), nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_SUB_ToSL) <- R_SUB_ToSL_cols

R_SUB_ToTOTB <- data.frame(matrix(ncol = length(R_SUB_ToTOTB_cols), nrow = length(Inputs_R_Groups$`GRC Code`)))
colnames(R_SUB_ToTOTB) <- R_SUB_ToTOTB_cols

R_SUB_ToT1TB <- data.frame(matrix(ncol = length(R_SUB_ToT1TB_cols), nrow = length(Inputs_R_Groups$`GRC Code`)))
colnames(R_SUB_ToTITB) <- R_SUB_ToT1TB_cols

R_SUB_LR <- data.frame(matrix(ncol = length(R_SUB_LR_cols), nrow = length(Inputs_R_I_Mapping$`GRC Code`)))
colnames(R_SUB_LR) <- R_SUB_LR_cols

R_SUB_ToCSM <- data.frame(matrix(ncol = length(R_SUB_ToCSM_cols), nrow = length(R_SUB_Calc$`GRC Code`)))
colnames(R_SUB_ToCSM) <- R_SUB_ToCSM_cols

R_SUB_Disc2 <- data.frame(matrix(ncol = length(R_SUB_Disc2_cols), nrow = length(Inputs_R_IF_Patterns$`Reporting Date`)))
colnames(R_SUB_Disc2) <- R_SUB_Disc2_cols

R_I_IN_Disc <- data.frame(matrix(ncol = length(R_I_IN_Disc_cols), nrow = length(Inputs_R_IF_Patterns$`Reporting Date`)))
colnames(R_I_IN_Disc) <- R_I_IN_Disc_cols

R_IN_Disc <- data.frame(matrix(ncol = length(R_IN_Disc_cols), nrow = length(Inputs_R_NEW_CFs$`Reporting Date`)))
colnames(R_IN_Disc) <- R_IN_Disc_cols

R_IN_LR <- data.frame(matrix(ncol = length(R_IN_LR_cols), nrow = length(Inputs_R_I_Mapping$`GRC Code`)))
colnames(R_IN_LR) <- R_IN_LR_cols

R_IN_Calc <- data.frame(matrix(ncol = length(R_IN_Calc_cols), nrow = length(Inputs_R_NEW_GEN$`GRC Code`)))
colnames(R_IN_Calc) <- R_IN_Calc_cols

R_IN_Pre_FX <- data.frame(matrix(ncol = length(R_IN_Pre_FX_cols), nrow = length(R_IN_Calc$`GRC Code`)))
colnames(R_IN_Pre_FX) <- R_IN_Pre_FX_cols

R_IN_ToSL <- data.frame(matrix(ncol = length(R_IN_ToSL_cols), nrow = length(R_IN_Calc$`GRC Code`)))
colnames(R_IN_ToSL) <- R_IN_ToSL_cols

##############################################R_SUB_LR
I_SUB_Calc <- wb_to_df(wb, sheet= "I_SUB_Calc", rows= 1:4, cols= 1:231, col_names = TRUE)
I_IN_Disc <- wb_to_df(wb, sheet= "I_IN_Disc", rows= 1:1801, cols= 1:41, col_names = TRUE)
I_SUB_Disc1 <- wb_to_df(wb, sheet= "I_SUB_Disc1", rows= 1:1801, cols= 1:182, col_names = TRUE)
for(i in seq_along(R_SUB_LR$`GRC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No' & Scope_R_IF_GEN_LR == "No") {I_SUB_Disc1
    R_SUB_LR$`GRC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    R_SUB_LR$`GRC Code`[i] <- Inputs_R_I_Mapping$`GRC Code`[i]
  }
}

for(i in seq_along(R_SUB_LR$`GIC Code`)) {
  # Check the value of Scope_Ins_NUB and assign accordingly
  if(Scope_Ins_NUB == 'No' & Scope_R_IF_GEN_LR == "No") {
    R_SUB_LR$`GIC Code` <- 0  # or you can use NA
  } else {
    # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
    R_SUB_LR$`GIC Code`[i] <- Inputs_R_I_Mapping$`GIC Code`[i]
  }
}

R_SUB_LR$`GIC Measurement model` <- Inputs_R_I_Mapping$`GIC Measurement model`
R_SUB_LR$`Portion of Group Cover by Reinsurance` <- Inputs_R_I_Mapping$`Portion of Group Cover by Reinsurance`

    # Loop through each index of I_IN_Disc
    for(i in seq_along(R_SUB_LR$`Ceding %`)) {
    # Check the value of Scope_Ins_NUB and assign accordingly
    if(Scope_Ins_NUB == 'No' & Scope_R_IF_GEN_LR == "No") {
        R_SUB_LR$`Ceding %`[i] <- (0)  # or you can use NA
    } else {
        # Ensure you are accessing the correct row in Inputs_I_NEW_CFs
        R_SUB_LR$`Ceding %`[i] <- (Inputs_R_Groups$`Ceding %`[i])
    }
    }
R_SUB_LR$`Effective Recovery from GRC` <- 
  ifelse(is.na(R_SUB_LR$`Portion of Group Cover by Reinsurance`) | 
           is.na(R_SUB_LR$`Ceding %`), 
         0, 
         R_SUB_LR$`Portion of Group Cover by Reinsurance` * R_SUB_LR$`Ceding %`)
if(Scope_Reinsurance == 'Yes' & Scope_Reins_NUB == 'Yes' ) {
  R_SUB_LR$`GIC Currency` <- Inputs_R_I_Mapping$`Currency`
  }

if(Scope_Reinsurance == 'Yes' & Scope_Reins_NUB == 'Yes' ) {
  R_SUB_LR$`GRC Currency` <- Inputs_R_I_Mapping$`Currency`
  }

R_SUB_LR <- R_SUB_LR %>%
  rowwise() %>%  # Ensure row-by-row operation
  mutate(
    `Opening LRC - Loss - PVFCF` = ifelse(
      # Condition 1: If both Scope_Insurance and Scope_R_IF_GEN_LR are "No"
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No", 
      0,  # Return 0
      
      ifelse(
        # Condition 2: If GIC Measurement model is not "GMM"
        `GIC Measurement model` != "GMM",
        
        # VLOOKUP equivalent using concatenated GRC Code and GIC Code from Inputs_R_IF_GEN_LR
        Inputs_R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[
          match(paste0(`GRC Code`, `GIC Code`), paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`))
        ],
        
        # If GIC Measurement model is "GMM", look up GIC Code in I_SUB_Calc
        I_SUB_Calc$`Opening LRC - Loss - PVFCF`[
          match(`GIC Code`, I_SUB_Calc$`GIC Code`)
        ]
      )
    )
  ) %>%
  ungroup()  # Ungroup after rowwise operation
   

R_SUB_LR <- R_SUB_LR %>%
  rowwise() %>%  # Ensure row-by-row operations
  mutate(
    `New LRC - Loss - PVFCF` = ifelse(
      # Condition 1: Scope_Insurance == "No" and Scope_R_IF_GEN_LR == "No"
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No", 
      0,
      
      ifelse(
        # Condition 2: Scope_Reins_NUB == "No"
        Scope_Reins_NUB == "No", 
        0,
        
        ifelse(
          # Condition 3: GIC Measurement model != "GMM"
          `GIC Measurement model` != "GMM",
          
          # VLOOKUP equivalent for GRC Code & GIC Code concatenation from Inputs_R_IF_GEN_LR
          Inputs_R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[
            which(
              paste0(`GRC Code`, `GIC Code`) == paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`)
            )
          ][1],  # Taking the first match
          
          # VLOOKUP equivalent for GIC Code from Workings_I_SUB_Calc
          I_SUB_Calc$`New LRC - Loss - PVFCF`[
            which(`GIC Code` == I_SUB_Calc$`GIC Code`)
          ][1]  # Taking the first match
        )
      )
    )
  ) %>% 
  ungroup()  # Ungroup after row-wise operations

R_SUB_LR <- R_SUB_LR %>%
  rowwise() %>%  # Ensure row-wise operation
  mutate(
    `LRC - Loss - PVFCF - Post Roll Forward` = ifelse(
      # Condition 1: Check if both Scope_Insurance and Scope_R_IF_GEN_LR are "No"
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No", 
      0,  # Return 0
      
      ifelse(
        # Condition 2: Check if GIC Measurement model is not "GMM"
        `GIC Measurement model` != "GMM",
        
        # Perform VLOOKUP using concatenated GRC Code and GIC Code in Inputs_R_IF_GEN_LR
        Inputs_R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[
          match(paste0(`GRC Code`, `GIC Code`), paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`))
        ],
        
        # If GIC Measurement model is "GMM", perform VLOOKUP using GIC Code in I_SUB_Calc
        I_SUB_Calc$`LRC - Loss - PVFCF - Post Roll Forward`[
          match(`GIC Code`, I_SUB_Calc$`GIC Code`)
        ]
      )
    )
  ) %>%
  ungroup()  # Ungroup after rowwise operation

R_SUB_LR$`Effect of Changes in Interest rates on LRC - Loss - PVFCF` <- 
  R_SUB_LR$`LRC - Loss - PVFCF - Post Roll Forward` - 
  R_SUB_LR$`New LRC - Loss - PVFCF` - 
  R_SUB_LR$`Opening LRC - Loss - PVFCF`





R_SUB_LR <- R_SUB_LR %>%
  mutate(
    lookup_value = paste0(`GRC Code`, `GIC Code`),  # Concatenating GRC Code and GIC Code for lookup

    # Apply conditions using case_when
    `Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)` = case_when(
      
      # Condition 1: When both Scope_Insurance and Scope_R_IF_GEN_LR are "No"
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No" ~ 0,

      # Condition 2: When GIC Measurement model is not "GMM", look up in Inputs_R_IF_GEN_LR based on concatenated GRC Code and GIC Code
      `GIC Measurement model` != "GMM" ~ {
        match_index <- match(lookup_value, paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`))
        
        # Return matched value or 0 if no match
        ifelse(!is.na(match_index), 
               Inputs_R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[match_index], 
               0)
      },
      
      # Condition 3: If GIC Measurement model is "GMM", look up based on GIC Code in I_SUB_Calc
      `GIC Measurement model` == "GMM" ~ {
        match_index <- match(`GIC Code`, I_SUB_Calc$`GIC Code`)
        
        # Return matched value or 0 if no match
        ifelse(!is.na(match_index), 
               I_SUB_Calc$`Effect on LRC - Loss - PVFCF of Removal of Expected Claims and Other Expenses Incurred (Current)`[match_index], 
               0)
      },
      
      # Default: Set to NA if no conditions match
      TRUE ~ NA_real_
    )
  )

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
            `GIC Measurement model` != "GMM", 
            { 
              # Match based on lookup_value (concatenated GRC and GIC codes)
              match_index <- match(lookup_value, paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`))
              ifelse(!is.na(match_index), Inputs_R_IF_GEN_LR[[col_name]][match_index], 0)
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

      # Condition 2: When GIC Measurement model is not "GMM", look up in Inputs_R_IF_GEN_LR based on concatenated GRC Code and GIC Code
      `GIC Measurement model` != "GMM" ~ {
        match_index <- match(lookup_value, paste0(Inputs_R_IF_GEN_LR$`GRC Sub-code`, Inputs_R_IF_GEN_LR$`GIC Code`))
        
        # Return matched value or 0 if no match
        ifelse(!is.na(match_index), 
               Inputs_R_IF_GEN_LR$`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`[match_index], 
               0)
      },
      
      # Condition 3: If GIC Measurement model is "GMM", look up based on GIC Code in I_SUB_Calc
      `GIC Measurement model` == "GMM" ~ {
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
      `GIC Measurement model` == "PAA" ~ 1,  # Equivalent to 100%
      !is.na(`Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX`) & 
      !is.na(`Total Change in FCF (Future) Non FX`) & 
      `Total Change in FCF (Future) Non FX` != 0 ~ 
        `Effect on LRC - Loss - FCF of Total Experience Variance (Future) - Non FX` / `Total Change in FCF (Future) Non FX`,
      TRUE ~ 0  # Default case if none of the above conditions are met
    )
  )

######################################################################R_SUB_CALC
R_SUB_Calc$`GRC Code` <- Inputs_R_Groups$`GRC Code`
R_SUB_Calc$`Locked-in YC Date` <- Inputs_R_Groups$`Locked-in YC Date`
R_SUB_Disc1 <- wb_to_df(wb, sheet= "R_SUB_Disc1", rows= 1:1801, cols= 1:9, col_names = TRUE)

thomo <- Inputs_R_Groups %>%
  select(`GRC Code`, `Currency`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and Inputs_R_Groups
indices <- match(R_SUB_Calc$`GRC Code`, thomo$`GRC Code`)
R_SUB_Calc$`Currency` <- thomo$`Currency`[indices]


# Check the Option_RASimplification value
if(Option_RASimplification == "Yes") {
  # Populate 'RA % of ABS(PVFCF Recoveries)' in R_SUB_Calc
  R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- sapply(R_SUB_Calc$`GRC Code`, function(code) {
    # Filter rows in Inputs_R_Groups that match the current GRC Code
    matched_rows <- Inputs_R_Groups[Inputs_R_Groups$`GRC Code` == code, ]
    
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

# Create indices using match to match GRC Code between R_IN_Disc and Inputs_R_Groups
indices <- match(R_SUB_Calc$`GRC Code`, thomo$`GRC Code`)

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Calc$`New ARC - PVFCF (Non-recoveries)` <- thomo$`Discounted Non-recoveries CFs (Locked-in YC, Locked-in Date)`

R_SUB_Calc$`Interest Accreted on New ARC - PVFCF (Non-recoveries)` <- 0  # Placeholder, replace with actual calculation

# Populate 'ARC - PVFCF (Non-recoveries) - Post Roll Forward'
R_SUB_Calc$`ARC - PVFCF (Non-recoveries) - Post Roll Forward` <- 
  R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries) - Post Roll Forward (LIYC)` + 
  R_SUB_Calc$`New ARC - PVFCF (Non-recoveries) - Post Roll Forward`

# Populate 'Interest Accreted on ARC - PVFCF (Non-recoveries)'
R_SUB_Calc$`Interest Accreted on ARC - PVFCF (Non-recoveries)` <- 
  R_SUB_Calc$`Interest Accreted on Opening ARC - PVFCF (Non-recoveries)` + 
  R_SUB_Calc$`Interest Accreted on New ARC - PVFCF (Non-recoveries)`

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
  mutate(`Premium Payments (Past/Current)` = sum(Inputs_R_IF_GEN$`Premium Payments (Past/Current Service)`[
    Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current & 
    Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
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

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Interest Accreted on Opening ARC - RA (Locked-in YC)` <- ifelse(
  Option_DisaggregateChangeInRA == "No" | 
  R_SUB_Calc$`Opening ARC - PVFCF (Recoveries)` == 0,
  0,
  R_SUB_Calc$`Interest Accreted on Opening ARC - PVFCF (Recoveries) (Locked-in YC)` * 
    R_SUB_Calc$`Opening ARC - RA` / 
    R_SUB_Calc$`Opening ARC - PVFCF (Recoveries)`
)

# Assuming R_SUB_Calc is your dataframe
# Inputs_R_NEW_GEN and Workings_R_IN_Calc are other dataframes

# Find the index of the column based on header name in Workings_R_IN_Calc
header_index <- match("New ARC - RA", colnames(R_IN_Calc))

# Create the New ARC - RA column in R_SUB_Calc
R_SUB_Calc$`New ARC - RA` <- ifelse(
  is.na(match(R_SUB_Calc$`GRC Code`, Inputs_R_NEW_GEN$`GRC Code`, 0)),
  0,
  R_IN_Calc[match(R_SUB_Calc$`GRC Code`, R_IN_Calc$`GRC Code`, nomatch = NA), header_index]
)

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Interest Accreted on New ARC - RA` <- ifelse(
  Option_DisaggregateChangeInRA == "No" | 
  R_SUB_Calc$`New ARC - PVFCF (Recoveries)` == 0,
  0,
  R_SUB_Calc$`Interest Accreted on New ARC - PVFCF (Recoveries)` * 
    R_SUB_Calc$`New ARC - RA` / 
    R_SUB_Calc$`New ARC - PVFCF (Recoveries)`
)

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Interest Accreted on ARC - RA` <- 
  R_SUB_Calc$`Interest Accreted on Opening ARC - RA` + 
  R_SUB_Calc$`Interest Accreted on New ARC - RA`

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`Interest Accreted on ARC - RA (Locked-in YC)` <- 
  R_SUB_Calc$`Interest Accreted on Opening ARC - RA (Locked-in YC)` + 
  R_SUB_Calc$`Interest Accreted on New ARC - RA`

# Assuming R_SUB_Calc is your dataframe
R_SUB_Calc$`ARC - RA - Post Roll Forward` <- 
  R_SUB_Calc$`Opening ARC - RA` + 
  R_SUB_Calc$`New ARC - RA` + 
  R_SUB_Calc$`Effect on ARC - RA of Changes in Interest Rates (1/2)` + 
  R_SUB_Calc$`Interest Accreted on ARC - RA`

# Assuming R_SUB_Calc is your dataframe and Inputs_R_IF_GEN is another dataframe
R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Closing ARC - RA` = {if_else(
      `RA % of ABS(PVFCF Recoveries)` == 0,
      sum(Inputs_R_IF_GEN$`Closing ARC - RA`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current & 
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ], na.rm = TRUE),  # Use na.rm to handle any NA values
      abs(`Closing ARC - PVFCF (Recoveries)(Current NP Risk, Current YC, Current FX)`) * 
      `RA % of ABS(PVFCF Recoveries)`
    )}
  ) %>%
  ungroup()  # Ungroup after row-wise operation

R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - RA of Change in NP Risk` = if_else(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0,
      0,
      `Effect on ARIC - PVFCF of Change in Exchange Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    )
  )

R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Effect on ARIC - RA of Change in Exchange Rates` = if_else(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0,
      0,
      `Effect on ARIC - PVFCF of Change in Exchange Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    ),
    `Effect on ARIC - RA of Changes in Interest Rates` = if_else(
      Option_DisaggregateChangeInRA == "No" | `Closing ARIC - PVFCF` == 0,
      0,
      `Effect on ARIC - PVFCF of Changes in Interest Rates` * `Closing ARIC - RA` / `Closing ARIC - PVFCF`
    )
  )

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current)` = if_else(
      Option_RASimplification == "Yes",
      if_else(
        `Closing ARIC - PVFCF` == 0,
        0,
        abs(`Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current)` - 
            `Recoveries Receipts (On Claims Incurred in Current Reporting Period)`) * 
        `Closing ARIC - RA` / abs(`Closing ARIC - PVFCF`)
      ),
      # Vectorized SUMIFS logic
      sum(
        Inputs_R_IF_GEN$`Closing ARIC - RA (Recoveries on New Claims and Other Expenses Incurred)`[
          Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
          Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
        ],
        na.rm = TRUE
      )
    )
  ) %>%
  ungroup()

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARIC - IC` = sum(
      Inputs_R_IF_GEN$`Opening ARIC - IC`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Investment Component Receipts` = -sum(
      Inputs_R_IF_GEN$`Investment Component Receipts`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Closing ARIC - IC` = sum(
      Inputs_R_IF_GEN$`Closing ARIC - IC`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARC - PRCF` = sum(
      Inputs_R_IF_GEN$`Opening ARC - PRCF`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Pre-recognition CF Receipts` = sum(
      Inputs_R_IF_GEN$`Pre-recognition CF Receipts`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Impairment of PRCF Liability` = sum(
      Inputs_R_IF_GEN$`Impairment of PRCF Liability`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `Reversal of Impairment of PRCF Liability` = sum(
      Inputs_R_IF_GEN$`Reversal of Impairment of PRCF Liability`[
        Inputs_R_IF_GEN$`Reporting Date` == ReportingDate_Current &
        Inputs_R_IF_GEN$`GRC Code` == `GRC Code`
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

R_SUB_Disc2$`Reporting Date` <- as.Date(Inputs_R_IF_Patterns$`Reporting Date`)
R_SUB_Disc2$`GRC Code` <- (Inputs_R_IF_Patterns$`GRC Code`)



thomo <- Inputs_R_Groups %>%
  select(`GRC Code`, `Locked-in YC Date`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and Inputs_R_Groups
indices <- match(R_SUB_Disc2$`GRC Code`, thomo$`GRC Code`)

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Disc2$`Locked-in YC Date` <- thomo$`Locked-in YC Date`[indices]

thomo <- Inputs_R_Groups %>%
  select(`GRC Code`, `Currency`) %>%
  group_by(`GRC Code`) 

# Create indices using match to match GRC Code between R_IN_Disc and Inputs_R_Groups
indices <- match(R_SUB_Disc2$`GRC Code`, thomo$`GRC Code`)

# Assign the Currency values to R_IN_Disc based on the matched indices
R_SUB_Disc2$`Currency` <- thomo$`Currency`[indices]

R_SUB_Disc2$`Coverage Units (Undiscounted)` <- Inputs_R_IF_Patterns$`Coverage Unit (Undiscounted)`
R_SUB_Disc2$`Reporting Period (0 = current)` <- Inputs_R_IF_Patterns$`Reporting Period (0 = current)`

#############################################################R_SUB_Calc
R_SUB_Calc$`GRC Code` <- Inputs_R_Groups$`GRC Code`
R_SUB_Calc$`Currency` <- Inputs_R_Groups$`Currency`[match(R_SUB_Calc$`GRC Code`, Inputs_R_Groups$`GRC Code`)]
R_SUB_Calc$`Locked-in YC Date` <- Inputs_R_Groups$`Locked-in YC Date`
R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- ifelse(
  Option_RASimplification == "Yes",
  sapply(R_SUB_Calc$GRC_Code, function(grc) {
    sum(Inputs_R_Groups$`RA % of ABS(PVFCF)`[Inputs_R_Groups$GRC_Code == grc], na.rm = TRUE)
  }),
  0
)


R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries)` <- sapply(
  R_SUB_Calc$GRC_Code, function(grc) {
    # Filter rows matching ReportingDate_Previous and GRC_Code
    matching_rows <- R_SUB_Disc1[
      R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous & 
      R_SUB_Disc1$`GRC Code` == grc, 
      "Discounted Non-recoveries CFs (Prev YC, Current FX, t0)"
    ]
    
    # Calculate the negative sum of matched rows
    -sum(matching_rows, na.rm = TRUE)
  }
)

# Populate the Release in ARC - CSM column
R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Release in ARC - CSM` = -`ARC - CSM - Post Reversal of Cash flows not affecting the GRC` * 
      if_else(
        `Retroactive Cover?` == "Yes" |
          sum(
            R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
              R_SUB_Disc2$`Reporting Date` == ReportingDate_Current & 
              R_SUB_Disc2$`GRC Code` == GRC Code
            ]
          ) == 0,
        1,
        sum(
          R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
            R_SUB_Disc2$`Reporting Date` == ReportingDate_Current & 
            R_SUB_Disc2$`GRC Code` == GRC Code &
            R_SUB_Disc2$`Reporting Period (0 = current)` == 0
          ]
        ) /
        sum(
          R_SUB_Disc2$`Discounted Coverage Units (Locked-in YC, t0)`[
            R_SUB_Disc2$`Reporting Date` == ReportingDate_Current & 
            R_SUB_Disc2$`GRC Code` == GRC Code
          ]
        )
      )
  ) %>%
  ungroup()


R_SUB_Calc$`RA % of ABS(PVFCF Recoveries)` <- Inputs_R_Groups$`RA % of ABS(PVFCF)`
  
# Calculate 'Opening ARC - PVFCF (Non-recoveries)' in Base R
R_SUB_Calc$`Opening ARC - PVFCF (Non-recoveries)` <- sapply(
  R_SUB_Calc$`GRC Code`,
  function(code) {
    -sum(
      R_SUB_Disc1$`Discounted Non-recoveries CFs (Prev YC, Current FX, t0)`[
        R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
        R_SUB_Disc1$`GRC Code` == code
      ],
      na.rm = TRUE
    )
  }
)

R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARIC - PVFCF` = sum(
      R_SUB_Disc1$`Discounted Recoveries CFs (On Claims Incurred in the Past)(Current NP Risk, Prev YC, Current FX, t0)`[
        R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
       R_SUB_Disc1$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

  R_SUB_Calc <- R_SUB_Calc %>%
  rowwise() %>%
  mutate(
    `Opening ARIC - PVFCF (Locked-in YC)` = -sum(
      R_SUB_Disc1$`Discounted Recoveries CFs (On Claims Incurred in the Past)(Locked-in YC and NP Risk, t0)`[
        R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
        R_SUB_Disc1$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `ARIC - PVFCF - Post Roll Forward` = -sum(
      R_SUB_Disc1$`Discounted Recoveries CFs (On Claims Incurred in the Past)(Current NP Risk, Prev YC, Current FX, t1)`[
        R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
        R_SUB_Disc1$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    ),
    `ARIC - PVFCF - Post Roll Forward (Locked-in YC)` = -sum(
      R_SUB_Disc1$`Discounted Recoveries CFs (On Claims Incurred in the Past)(Locked-in YC and NP Risk, t1)`[
        R_SUB_Disc1$`Reporting Date` == ReportingDate_Previous &
        R_SUB_Disc1$`GRC Code` == `GRC Code`
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

  R_SUB_Calc <- R_SUB_Calc %>%
  mutate(
    `Interest Accreted on ARIC - PVFCF` = `ARIC - PVFCF - Post Roll Forward` - `Opening ARIC - PVFCF`
  )

  ###################################################### R_EQ_Calc
  R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `GRC Code` = if_else(
      Scope_Reinsurance == "No", 
      0, 
      Inputs_R_Groups[match(`GRC Code`, Inputs_R_Groups$`GRC Code`), `GRC Code`]
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Reporting Segment` = if_else(
      Scope_Reinsurance == "No",
      0,
      Inputs_R_Groups$`Reporting Segment`[match(`GRC Code`, Inputs_R_Groups$`GRC Code`)]
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Opening Reinsurance Finance Reserve` = if_else(
      Scope_Reinsurance == "No",
      0,
      sum(Table65$`Opening Reinsurance Finance Reserve`[Table65$`GRC Code` == `GRC Code`], na.rm = TRUE)
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Income/(Expense) disclosed in OCI` = sum(
      Table36$`Opening Reinsurance Finance Reserve`[match(`GRC Code`, Table36$`GRC Code`)]:Table36$`Income/(Expense) disclosed in OCI`[match(`GRC Code`, Table36$`GRC Code`)], 
      na.rm = TRUE
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Closing Reinsurance Finance Reserve` = if_else(
      Scope_Reinsurance == "No",
      0,
      sum(
        Outputs_SL$Amount[Outputs_SL$`Group Code` == `GRC Code` & Outputs_SL$`CR Account Code` %in% c(
          R_Disclosures_Master$G44, R_Disclosures_Master$G47, R_Disclosures_Master$G50, R_Disclosures_Master$G53
        )],
        na.rm = TRUE
      )
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Opening Retained Earnings` = if_else(
      Scope_Reinsurance == "No",
      0,
      sum(Table65$`Opening Retained Earnings`[Table65$`GRC Code` == `GRC Code`], na.rm = TRUE)
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Income/(Expense) disclosed in P&L` = sum(
      Table36$`Opening Retained Earnings`[match(`GRC Code`, Table36$`GRC Code`)]:Table36$`Income/(Expense) disclosed in P&L`[match(`GRC Code`, Table36$`GRC Code`)], 
      na.rm = TRUE
    )
  )

R_EQ_Calc <- R_EQ_Calc %>%
  mutate(
    `Closing Retained Earnings` = if_else(
      Scope_Reinsurance == "No",
      0,
      sum(
        (R_SUB_ToT1TB$`ARC - PVFCF - Non-Loss Recovery` + 
         R_SUB_ToT1TB$`ARC - RA` + 
         R_SUB_ToT1TB$`ARC - CSM` + 
         R_SUB_ToT1TB$`ARC - PVFCF - Loss Recovery` + 
         R_SUB_ToT1TB$`ARC - PRCF` + 
         R_SUB_ToT1TB$`ARIC - PVFCF` + 
         R_SUB_ToT1TB$`ARIC - RA` + 
         R_SUB_ToT1TB$`ARIC - IC`)[R_SUB_ToT1TB$`GRC Code` == `GRC Code`],
        na.rm = TRUE
      ) -
      sum(
        (R_SUB_ToT0TB$`ARC - PVFCF - Non-Loss Recovery` + 
         R_SUB_ToT0TB$`ARC - RA` + 
         R_SUB_ToT0TB$`ARC - CSM` + 
         R_SUB_ToT0TB$`ARC - PVFCF - Loss Recovery` + 
         R_SUB_ToT0TB$`ARC - PRCF` + 
         R_SUB_ToT0TB$`ARIC - PVFCF` + 
         R_SUB_ToT0TB$`ARIC - RA` + 
         R_SUB_ToT0TB$`ARIC - IC`)[R_SUB_ToT0TB$`GRC Code` == `GRC Code`],
        na.rm = TRUE
      )
    )
  )

################################################ R_I_SUB_Disc1

library(dplyr)

R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  mutate(
    `Reporting Date` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["Reporting Date"]]
    ),
    `GIC Code` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["GIC Code"]]
    ),
    `GRC Code` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["GRC Code"]]
    ),
    `Locked-in YC Date` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["Locked-in YC Date"]]
    ),
    Currency = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_R_I_Mapping$Currency[match(
        `GIC Code`, 
        Inputs_R_I_Mapping$`GIC Code`
      )]
    ),
    `Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["Treaty covered Claim and Other CFs (Unlinked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)"]]
    ),
    `Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      Inputs_I_IF_FCFs_RI[["Treaty covered Claim and Other CFs (Unlinked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)"]]
    ),
    `Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      ifelse(
        Scope_LinkedCashflows == "No",
        0,
        Inputs_I_IF_FCFs_RI[["Treaty covered Claim and Other CFs (Linked)(Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)"]]
      )
    ),
    `Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = ifelse(
      Scope_Insurance == "No" & Scope_R_IF_GEN_LR == "No",
      0,
      ifelse(
        Scope_LinkedCashflows == "No",
        0,
        Inputs_I_IF_FCFs_RI[["Treaty covered Claim and Other CFs (Linked)(Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)"]]
      )
    )
  )

  R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  mutate(
    Discounted_CF_Next_Period = 
      Treaty_covered_CF_Unlinked_Next_Period * 
      ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
         Delay_in_Years + (Reporting_Date - Locked_in_YC_Date) / 365.25)) *
      ((1 + Spot_Rate_Unlinked_Locked_in_Date)^(
         (Reporting_Date - Locked_in_YC_Date) / 365.25)) +
      Treaty_covered_CF_Linked_Next_Period * 
      ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
         Delay_in_Years + (Reporting_Date - Locked_in_YC_Date) / 365.25)) *
      ((1 + Spot_Rate_Linked_Locked_in_Date)^(
         (Reporting_Date - Locked_in_YC_Date) / 365.25))
  )

R_I_SUB_Disc1 <- R_I_SUB_Disc1 %>%
  mutate(
    Discounted_CF_Future_Periods = 
      Treaty_covered_CF_Unlinked_Future_Periods * 
      ((1 + Spot_Rate_Unlinked_Locked_in_Delay)^-(
         Delay_in_Years + (Reporting_Date - Locked_in_YC_Date) / 365.25)) *
      ((1 + Spot_Rate_Unlinked_Locked_in_Date)^(
         (Reporting_Date - Locked_in_YC_Date) / 365.25)) +
      Treaty_covered_CF_Linked_Future_Periods * 
      ((1 + Spot_Rate_Linked_Locked_in_Delay)^-(
         Delay_in_Years + (Reporting_Date - Locked_in_YC_Date) / 365.25)) *
      ((1 + Spot_Rate_Linked_Locked_in_Date)^(
         (Reporting_Date - Locked_in_YC_Date) / 365.25))
  )

################################################ R_SUB_DISC1

library(dplyr)

# Join `R_SUB_Disc1` with necessary inputs
R_SUB_Disc1 <- R_SUB_Disc1 %>%
  # Populate `Reporting Date` and `GRC Code` directly
  mutate(
    `Reporting Date` = Inputs_R_IF_FCFs$`Reporting Date`,
    `GRC Code` = Inputs_R_IF_FCFs$`GRC Code`
  ) %>%
  # Join with `Inputs_R_Groups` to get the `Currency` and `Locked-in YC Date`
  left_join(
    Inputs_R_Groups %>%
      select(`GRC Code`, `Currency`, `Locked-in YC Date`),
    by = "GRC Code"
  ) %>%
  # Populate other columns based on conditions
  mutate(
    `Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)` = 
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)`),
    
    `Premium CFs (Unlinked)(Past Service) - Prev FX` =
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Prev FX`),
    
    `Premium CFs (Unlinked)(Past Service) - Current FX` = Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Past Service) - Current FX`,
    
    `Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)` = 
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)`),
    
    `Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX` =
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Prev FX`),
    
    `Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX` = 
      Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Service in Next Reporting Period) - Current FX`,
    
    `Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)` = 
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)`)
  )

library(dplyr)

# Extend the existing logic
R_SUB_Disc1 <- R_SUB_Disc1 %>%
  # Additional columns for Premium CFs
  mutate(
    `Premium CFs (Unlinked)(Future Service) - Prev FX` = 
      if_else(Scope_LockedInAssumptions == "No",
              `Premium CFs (Unlinked)(Future Service) - Current FX`,
              Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Prev FX`),
    
    `Premium CFs (Unlinked)(Future Service) - Current FX` = 
      Inputs_R_IF_FCFs$`Premium CFs (Unlinked)(Future Service) - Current FX`,
    
    # Investment Component CFs
    `Investment Component CFs (Unlinked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)` = 
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`,
              Inputs_R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)`),
    
    `Investment Component CFs (Unlinked)(Receivable in Future) - Prev FX` = 
      if_else(Scope_LockedInAssumptions == "No",
              Inputs_R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`,
              Inputs_R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Prev FX`),
    
    `Investment Component CFs (Unlinked)(Receivable in Future) - Current FX` = 
      Inputs_R_IF_FCFs$`Investment Component CFs (Unlinked)(Receivable in Future) - Current FX`,
    
    # Recoveries CFs
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX`
  )

library(dplyr)

# Extend the data frame with additional columns
R_SUB_Disc1 <- R_SUB_Disc1 %>%
  mutate(
    # Recoveries CFs (Unlinked) for Previous NP Risk
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX`,
    
    # Recoveries CFs (Unlinked) for Current NP Risk
    `Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Prior Reporting Periods)(Current NP Risk) - Current FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Current Reporting Period)(Current NP Risk) - Current FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Next Reporting Period)(Current NP Risk) - Current FX`,
    
    `Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX` = 
      Inputs_R_IF_FCFs$`Recoveries CFs (Unlinked)(On Claims Incurred in Future Reporting Periods)(Current NP Risk) - Current FX`,
    
    # Premium CFs (Linked) with conditional logic
    `Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)` = 
      if_else(
        Scope_LinkedCashflows == "No", 
        0, 
        if_else(
          Scope_LockedInAssumptions == "No", 
          `Premium CFs (Linked)(Past Service) - Current FX`, 
          Inputs_R_IF_FCFs$`Premium CFs (Linked)(Past Service)(Locked-in Financial Assumptions)(Current Discretion)`
        )
      )
  )

# Assuming the relevant columns and variables (`Scope_LinkedCashflows`, `Scope_LockedInAssumptions`, etc.)
# are available in your data frame named `Inputs_R_IF_FCFs`.

Inputs_R_IF_FCFs <- Inputs_R_IF_FCFs %>%
  mutate(
    `Premium CFs (Linked)(Past Service) - Prev FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Premium CFs (Linked)(Past Service) - Current FX`, 
        `Premium CFs (Linked)(Past Service) - Prev FX`
      )
    ),
    `Premium CFs (Linked)(Past Service) - Current FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      `Premium CFs (Linked)(Past Service) - Current FX`
    ),
    `Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`, 
        `Premium CFs (Linked)(Service in Next Reporting Period)(Locked-in Financial Assumptions)(Current Discretion)`
      )
    ),
    `Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`, 
        `Premium CFs (Linked)(Service in Next Reporting Period) - Prev FX`
      )
    ),
    `Premium CFs (Linked)(Service in Next Reporting Period) - Current FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      `Premium CFs (Linked)(Service in Next Reporting Period) - Current FX`
    ),
    `Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Premium CFs (Linked)(Future Service) - Current FX`, 
        `Premium CFs (Linked)(Future Service)(Locked-in Financial Assumptions)(Current Discretion)`
      )
    ),
    `Premium CFs (Linked)(Future Service) - Prev FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Premium CFs (Linked)(Future Service) - Current FX`, 
        `Premium CFs (Linked)(Future Service) - Prev FX`
      )
    ),
    `Premium CFs (Linked)(Future Service) - Current FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      `Premium CFs (Linked)(Future Service) - Current FX`
    ),
    `Investment Component CFs (Linked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Investment Component CFs (Linked)(Receivable in Future) - Current FX`, 
        `Investment Component CFs (Linked)(Receivable in Future)(Locked-in Financial Assumptions)(Current Discretion)`
      )
    ),
    `Investment Component CFs (Linked)(Receivable in Future) - Prev FX` = if_else(
      Scope_LinkedCashflows == "No", 
      0, 
      if_else(
        Scope_LockedInAssumptions == "No", 
        `Investment Component CFs (Linked)(Receivable in Future) - Current FX`, 
        `Investment Component CFs (Linked)(Receivable in Future) - Prev FX`
      )
    )
  )
library(dplyr)

R_SUB_Disc1 <- R_SUB_Disc1 %>%
  mutate(
    `Investment Component CFs (Linked)(Receivable in Future) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Investment Component CFs (Linked)(Receivable in Future) - Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Current Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Locked-in Financial Assumptions and NP Risk)(Current Discretion)`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Prev FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Prior Reporting Periods)(Previous NP Risk) - Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Next Reporting Period)(Previous NP Risk)- Current FX`),
    
    `Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX` = 
      ifelse(Scope_LinkedCashflows == "No", 0, 
             Inputs_R_IF_FCFs$`Recoveries CFs (Linked)(On Claims Incurred in Future Reporting Periods)(Previous NP Risk) - Current FX`)
  )

###################################R_SUB_ToSL

# Perform the lookup
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - Actuals FX`),
        NA_real_
      )
  )


# Perform the lookup for multiple columns
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - OCI - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on Opening ARC - PVFCF - Non-Loss Recovery - OCI - Actuals FX`),
        NA_real_
      ),
    `RI Premium Experience Variance (Past/Current) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`RI Premium Experience Variance (Past/Current) - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Non-Loss Recovery - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Non-Loss Recovery - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF of Total Experience Variance (Future) - Non-Loss Recovery - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF of Total Experience Variance (Future) - Non-Loss Recovery - Current FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF of Change in Exchange rates - Non-Loss Recovery - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF of Change in Exchange rates - Non-Loss Recovery - Current FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF of Change in NP Risk - Non-Loss Recovery - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF of Change in NP Risk - Non-Loss Recovery - Current FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF of Changes in Interest Rates - Non-Loss Recovery - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF of Changes in Interest Rates - Non-Loss Recovery - Current FX`),
        NA_real_
      ),
    `Premium Payments - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Premium Payments - Actuals FX`),
        NA_real_
      )
  )

# Assuming you have 'R_SUB_Disc1' and 'Workings_R_FX' data frames
library(dplyr)

# Perform the lookup for multiple columns
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Transfer of Reinsurance Investment Components (2) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Transfer of Reinsurance Investment Components (2) - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARC - RA - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARC - RA - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARC - RA - OCI - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARC - RA - OCI - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - RA of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - RA of Removal of Recoveries on Expected Claims and Other Expenses Incurred (Current) - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - RA of Total Experience Variance (Future - Non FX) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - RA of Total Experience Variance (Future - Non FX) - Current FX`),
        NA_real_
      ),
    `Effect on ARC - RA - Change in Exchange rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - RA - Change in Exchange rates - Current FX`),
        NA_real_
      ),
    `Effect on ARC - RA of Change in NP Risk - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - RA of Change in NP Risk - Current FX`),
        NA_real_
      ),
    `Effect on ARC - RA of Changes in Interest Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - RA of Changes in Interest Rates - Current FX`),
        NA_real_
      )
  )

# Assuming you have 'R_SUB_Disc1' and 'R_FX' data frames
library(dplyr)

# Perform the lookup for multiple columns
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Interest Accreted on ARC - CSM - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARC - CSM - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - CSM - Total Experience Variance (Future - Non FX) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - CSM - Total Experience Variance (Future - Non FX) - Current FX`),
        NA_real_
      ),
    `Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - CSM - Reversal of Loss Component due to changes not affecting the GRC - Current FX`),
        NA_real_
      ),
    `Release in ARC - CSM - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Release in ARC - CSM - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARC - PVFCF - Loss Recovery - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARC - PVFCF - Loss Recovery - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARC - PVFCF - Loss Recovery - OCI - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARC - PVFCF - Loss Recovery - OCI - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF - Loss Recovery - Release of Loss recovery - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery - Release of Loss recovery - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period - Actuals FX`),
        NA_real_
      )
  )

# Assuming you have 'R_SUB_Disc1' and 'Workings_R_FX' data frames
library(dplyr)

# Perform the lookup for multiple columns
R_SUB_ToSL <- R_SUB_ToSL %>%
  rowwise() %>%
  mutate(
    `Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery - Losses recovered during the period - Actuals FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF - Loss Recovery adjustment due to uncovered cash flows - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery adjustment due to uncovered cash flows - Current FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF - Loss Recovery due to Changes in Interest Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery due to Changes in Interest Rates - Current FX`),
        NA_real_
      ),
    `Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARC - PVFCF - Loss Recovery due to currency exchange differences - Current FX`),
        NA_real_
      ),
    `Interest Accreted on ARIC - PVFCF - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARIC - PVFCF - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARIC - PVFCF - OCI - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARIC - PVFCF - OCI - Actuals FX`),
        NA_real_
      ),
    `Effect on ARIC - PVFCF of Changes to Recoveries CFs (Past) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - PVFCF of Changes to Recoveries CFs (Past) - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - PVFCF of Change in Exchange Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - PVFCF of Change in Exchange Rates - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - PVFCF of Change in NP Risk - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - PVFCF of Change in NP Risk - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - PVFCF of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - PVFCF of Changes in Interest Rates - Current FX`),
        NA_real_
      ),
    `Recoveries Receipts - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Recoveries Receipts - Actuals FX`),
        NA_real_
      ),
    `Recoveries Receipts (2) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Recoveries Receipts (2) - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARIC - RA - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARIC - RA - Actuals FX`),
        NA_real_
      ),
    `Interest Accreted on ARIC - RA - OCI - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Interest Accreted on ARIC - RA - OCI - Actuals FX`),
        NA_real_
      ),
    `Effect on ARIC - RA of Changes to Recoveries CFs (Past) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - RA of Changes to Recoveries CFs (Past) - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - RA of Change in NP Risk - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - RA of Change in NP Risk - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - RA of Recoveries on New Claims and Other Expenses Incurred (Current) - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - RA of Change in Exchange Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - RA of Change in Exchange Rates - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - RA of Changes in Interest Rates - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - RA of Changes in Interest Rates - Current FX`),
        NA_real_
      ),
    `Effect on ARIC - IC of Changes to IC CFs (Past) - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Effect on ARIC - IC of Changes to IC CFs (Past) - Current FX`),
        NA_real_
      ),
    `Investment Component Receipts - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Investment Component Receipts - Actuals FX`),
        NA_real_
      ),
    `Investment Component Receipts (2) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Investment Component Receipts (2) - Actuals FX`),
        NA_real_
      ),
    `Pre-recognition CF Receipts - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Pre-recognition CF Receipts - Actuals FX`),
        NA_real_
      ),
    `Pre-recognition CF Receipts (2) - Actuals FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Pre-recognition CF Receipts (2) - Actuals FX`),
        NA_real_
      ),
    `Impairment of PRCF Liability - Current FX` = 
      ifelse(
        !is.na(`GRC Code`), 
        R_FX %>%
          filter(`GRC Code` == !!GRC_Code) %>%
          pull(`Impairment of PRCF Liability - Current FX`),
        NA_real_
      )
  )
###################################### R_SUB_ToT0TB
library(dplyr)

# Assuming R_SUB_ToT0TB and Workings_R_FX are already loaded

R_SUB_ToT0TB <- R_SUB_ToT0TB %>%
  rowwise() %>%
  mutate(
    # GRC Code and Portfolio (can be directly referenced or computed)
    GRC_Code = `GRC Code`, 
    Portfolio = `Portfolio`,
    
    # Asset / Liability Calculation
    `Asset / Liability` = ifelse(
      sum(
        R_SUB_ToT0TB$`ARC - PVFCF - Non-Loss Recovery` : R_SUB_ToT0TB$`ARIC - IC` != "",
        na.rm = TRUE
      ) >= 0, "Asset", "Liability"
    ),
    
    # VLOOKUP equivalent for each column in R_FX
    `ARC - PVFCF - Non-Loss Recovery` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & D$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - RA` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & E$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - CSM` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & F$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - PVFCF - Loss Recovery` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & G$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - PRCF` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & H$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - PVFCF` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & I$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - RA` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & J$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - IC` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Opening " & K$1 & " - Actuals FX", names(R_FX), 0)),
      NA_real_
    )
  ) %>%
  ungroup()
 ##################################################### R_SUB_ToT1TB

 library(dplyr)

# Assuming R_SUB_ToT1TB and R_FX are already loaded

R_SUB_ToT1TB <- R_SUB_ToT1TB %>%
  rowwise() %>%
  mutate(
    # GRC Code and Portfolio
    GRC Code = `GRC Code`, 
    Portfolio = `Portfolio`,
    
    # Asset / Liability Calculation
    `Asset / Liability` = ifelse(
      sum(
        R_SUB_ToT1TB$`ARC - PVFCF - Non-Loss Recovery` :R_SUB_ToT1TB$`ARIC - IC` != "",
        na.rm = TRUE
      ) >= 0, "Asset", "Liability"
    ),
    
    # VLOOKUP equivalent for each column in R_FX
    `ARC - PVFCF - Non-Loss Recovery` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & D$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - RA` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & E$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - CSM` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & F$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - PVFCF - Loss Recovery` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & G$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARC - PRCF` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & H$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - PVFCF` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & I$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - RA` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & J$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    ),
    
    `ARIC - IC` = ifelse(
      !is.na(GRC_Code),
      R_FX %>%
        filter(`GRC Code` == GRC_Code) %>%
        pull(MATCH("Closing " & K$1 & " - Current FX", names(R_FX), 0)),
      NA_real_
    )
  ) %>%
  ungroup()
 ###################################################### R_IN_ToSL


R_IN_ToSL <- R_IN_ToSL %>%
  rowwise() %>%
  mutate(
    # GRC Code is directly copied
    GRC_Code = `GRC Code`, 
    
    # Transfer of Pre-recognition CFs (Purchased) - Actuals FX
    `Transfer of Pre-recognition CFs (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(B$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(B$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # Transfer of Pre-recognition CFs (Purchased)(2) - Actuals FX
    `Transfer of Pre-recognition CFs (Purchased)(2) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(C$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(C$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Premium CFs (Purchased) - Actuals FX
    `New ARC - Premium CFs (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(D$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(D$1, colnames(R_FX)), FALSE)
      ),
      0
    ),
    
    # New ARC - Investment Component CFs (Purchased) - Actuals FX
    `New ARC - Investment Component CFs (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(E$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(E$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Recoveries CFs (Purchased) - Actuals FX
    `New ARC - Recoveries CFs (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(F$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(F$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - RA (Purchased) - Actuals FX
    `New ARC - RA (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(G$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(G$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - CSM - Non-Loss Recovery (Purchased) - Actuals FX
    `New ARC - CSM - Non-Loss Recovery (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(H$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(H$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Loss Recovery (Purchased) - Actuals FX
    `New ARC - Loss Recovery (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(I$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(I$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - PVFCF - Loss Recovery (Purchased) - Actuals FX
    `New ARC - PVFCF - Loss Recovery (Purchased) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(J$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(J$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - PVFCF - Non-Loss Recovery (Purchased) - Initial Loss Recovery - Actuals FX
    `New ARC - PVFCF - Non-Loss Recovery (Purchased) - Initial Loss Recovery - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(K$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(K$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # Transfer of Pre-recognition CFs (Acquired) - Actuals FX
    `Transfer of Pre-recognition CFs (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(L$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(L$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # Transfer of Pre-recognition CFs (Acquired)(2) - Actuals FX
    `Transfer of Pre-recognition CFs (Acquired)(2) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(M$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(M$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Premium CFs (Acquired) - Actuals FX
    `New ARC - Premium CFs (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(N$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(N$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Investment Component CFs (Acquired) - Actuals FX
    `New ARC - Investment Component CFs (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(O$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(O$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Recoveries CFs (Acquired) - Actuals FX
    `New ARC - Recoveries CFs (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(P$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(P$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - RA (Acquired) - Actuals FX
    `New ARC - RA (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(Q$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(Q$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - CSM - Non-Loss Recovery (Acquired) - Actuals FX
    `New ARC - CSM - Non-Loss Recovery (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(R$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(R$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - Loss Recovery (Acquired) - Actuals FX
    `New ARC - Loss Recovery (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(S$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(S$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - PVFCF - Loss Recovery (Acquired) - Actuals FX
    `New ARC - PVFCF - Loss Recovery (Acquired) - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(T$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(T$1, colnames(R_FX)), FALSE)
      ), 
      0
    ),
    
    # New ARC - PVFCF - Non-Loss Recovery (Acquired) - Initial Loss Recovery - Actuals FX
    `New ARC - PVFCF - Non-Loss Recovery (Acquired) - Initial Loss Recovery - Actuals FX` = ifelse(
      !is.na(GRC_Code),
      ifelse(
        is.na(VLOOKUP(GRC_Code, R_FX, match(U$1, colnames(R_FX)), FALSE)), 0,
        VLOOKUP(GRC_Code, R_FX, match(U$1, colnames(R_FX)), FALSE)
      ), 
      0
    )
  ) %>%
  ungroup()
 
 ##################################### R_IN_Pre_FX

 R_IN_Pre_FX <- R_IN_Pre_FX %>%
  mutate(
    # GRC Code column remains unchanged, as it's already populated

    # Transfer of Pre-recognition CFs (Purchased)
    `Transfer of Pre-recognition CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `Pre-recognition CFs`, 0)
    ),

    # Transfer of Pre-recognition CFs (Purchased)(2)
    `Transfer of Pre-recognition CFs (Purchased)(2)` = `Transfer of Pre-recognition CFs (Purchased)`,  # Same as the previous column

    # New ARC - Premium CFs (Purchased)
    `New ARC - Premium CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - Premium CFs`, 0)
    ),

    # New ARC - Investment Component CFs (Purchased)
    `New ARC - Investment Component CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - Investment Component CFs`, 0)
    ),

    # New ARC - Recoveries CFs (Purchased)
    `New ARC - Recoveries CFs (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - Recoveries CFs`, 0)
    ),

    # New ARC - RA (Purchased)
    `New ARC - RA (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - RA`, 0)
    ),

    # New ARC - CSM - Non-Loss Recovery (Purchased)
    `New ARC - CSM - Non-Loss Recovery (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - CSM - Non-loss-recovery`, 0)
    ),

    # New ARC - Loss Recovery (Purchased)
    `New ARC - Loss Recovery (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - Loss Recovery`, 0)
    ),

    # New ARC - CSM (Purchased)
    `New ARC - CSM (Purchased)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Purchased", `New ARC - CSM`, 0)
    ),

    # Transfer of Pre-recognition CFs (Acquired)
    `Transfer of Pre-recognition CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `Pre-recognition CFs`, 0)
    ),

    # Transfer of Pre-recognition CFs (Acquired)(2)
    `Transfer of Pre-recognition CFs (Acquired)(2)` = `Transfer of Pre-recognition CFs (Acquired)`,  # Same as the previous column

    # New ARC - Premium CFs (Acquired)
    `New ARC - Premium CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - Premium CFs`, 0)
    ),

    # New ARC - Investment Component CFs (Acquired)
    `New ARC - Investment Component CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - Investment Component CFs`, 0)
    ),

    # New ARC - Recoveries CFs (Acquired)
    `New ARC - Recoveries CFs (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - Recoveries CFs`, 0)
    ),

    # New ARC - RA (Acquired)
    `New ARC - RA (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - RA`, 0)
    ),

    # New ARC - CSM - Non-Loss Recovery (Acquired)
    `New ARC - CSM - Non-Loss Recovery (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - CSM - Non-loss-recovery`, 0)
    ),

    # New ARC - Loss Recovery (Acquired)
    `New ARC - Loss Recovery (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - Loss Recovery`, 0)
    ),

    # New ARC - CSM (Acquired)
    `New ARC - CSM (Acquired)` = ifelse(
      Scope_Reins_NUB == "No", 0,
      ifelse(Purchased_Acquired == "Acquired", `New ARC - CSM`, 0)
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

R_IN_Calc <- R_IN_Calc %>%
  mutate(
    `GRC Code` = Inputs_R_NEW_GEN$`GRC Code`,
    `Purchased/Acquired` = Inputs_R_NEW_GEN$`Purchased/Acquired`,
    `Pre-recognition CFs` = Inputs_R_NEW_GEN$`Pre-recognition CFs`,
    
    # New ARC - Premium CFs (Current Service)
    `New ARC - Premium CFs (Current Service)` = -sum(R_IN_Disc$`Discounted Premium CFs (Current Service)(Locked-in YC, Locked-in Date)`[R_IN_Disc$`Reporting Date` == ReportingDate_Current & R_IN_Disc$`GRC Code` == `GRC Code`]),
    
    # New ARC - Premium CFs (Future Service)
    `New ARC - Premium CFs (Future Service)` = -sum(R_IN_Disc$`Discounted Premium CFs (Future Service)(Locked-in YC, Locked-in Date)`[R_IN_Disc$`Reporting Date` == ReportingDate_Current & R_IN_Disc$`GRC Code` == `GRC Code`]),
    
    # New ARC - Premium CFs
    `New ARC - Premium CFs` = `New ARC - Premium CFs (Current Service)` + `New ARC - Premium CFs (Future Service)`,
    
    # New ARC - Investment Component CFs
    `New ARC - Investment Component CFs` = -sum(R_IN_Disc$`Discounted Investment Component CFs (Locked-in YC, Locked-in Date)`[R_IN_Disc$`Reporting Date` == ReportingDate_Current & R_IN_Disc$`GRC Code` == `GRC Code`]),
    
    # New ARC - Recoveries CFs (On Claims Incurred in Current Reporting Period)
    `New ARC - Recoveries CFs (On Claims Incurred in Current Reporting Period)` = -sum(R_IN_Disc$`Discounted Recoveries CFs (On Claims Incurred in Current Reporting Period)(Locked-in YC, Locked-in Date)`[R_IN_Disc$`Reporting Date` == ReportingDate_Current & R_IN_Disc$`GRC Code` == `GRC Code`]),
    
    # New ARC - Recoveries CFs (On Claims Incurred in Future Reporting Periods)
    `New ARC - Recoveries CFs (On Claims Incurred in Future Reporting Periods)` = -sum(R_IN_Disc$`Discounted Recoveries CFs (On Claims Incurred in Future Reporting Periods)(Locked-in YC, Locked-in Date)`[R_IN_Disc$`Reporting Date` == ReportingDate_Current & R_IN_Disc$`GRC Code` == `GRC Code`]),
    
    # New ARC - Recoveries CFs
    `New ARC - Recoveries CFs` = `New ARC - Recoveries CFs (On Claims Incurred in Current Reporting Period)` + `New ARC - Recoveries CFs (On Claims Incurred in Future Reporting Periods)`,
    
    # New ARC - Total Outflows
    `New ARC - Total Outflows` = `New ARC - Premium CFs` + `New ARC - Total Outflows`,
    
    # New ARC - PVFCF
    `New ARC - PVFCF` = `New ARC - Premium CFs` + `New ARC - Recoveries CFs`,
    
    # RA % of ABS(PVFCF Recoveries)
    `RA % of ABS(PVFCF Recoveries)` = if_else(Scope_Reins_NUB == "No", 0,
                                               if_else(Option_RASimplification == "Yes", 
                                                       sum(Inputs_R_Groups$`RA % of ABS(PVFCF)`[Inputs_R_Groups$`GRC Code` == `GRC Code`]), 
                                                       0),
                                               0),
    
    # New ARC - RA
    `New ARC - RA` = if_else(Scope_Reinsurance == "Yes" & Scope_Reins_NUB == "Yes",
                             if_else([@[RA % of ABS(PVFCF Recoveries)]] == 0, 
                                     Inputs_R_NEW_GEN$`Initial RA`,
                                     abs(`New ARC - Recoveries CFs`) * [@[RA % of ABS(PVFCF Recoveries)]]), 
                             0),
    
    # New ARC - FCF
    `New ARC - FCF` = `New ARC - PVFCF` + `New ARC - RA`,
    
    # Retroactive Cover?
    `Retroactive Cover?` = if_else(Scope_Reins_NUB == "No", 0,
                                   if_else([@[Retroactive Cover?]] == "Yes", 
                                           `Pre-recognition CFs`, -`New ARC - FCF`)),
    
    # New ARC - CSM - Non-loss-recovery
    `New ARC - CSM - Non-loss-recovery` = sum(Workings_R_IN_LR$`New ARC - Loss Recovery`[Workings_R_IN_LR$`GRC Code` == `GRC Code`]),
    
    # New ARC - Loss Recovery
    `New ARC - Loss Recovery` = `New ARC - CSM - Non-loss-recovery` + `New ARC - Loss Recovery`,
    
    # New ARC - CSM
    `New ARC - CSM` = `New ARC - CSM - Non-loss-recovery` + `New ARC - Loss Recovery`
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
 
# Initialize data container for "YieldCurves"
YieldCurves <- local({
  temp_env <- new.env(parent = emptyenv())
  temp_env$result <- execute_extraction(data_acquisition_params)
  temp_env$result
})