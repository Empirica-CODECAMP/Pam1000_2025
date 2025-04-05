# Accept command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Parse arguments (Run_Nr, PrevRun_Nr, NBRun_Nr)
Run_Nr <- as.integer(args[1])
PrevRun_Nr <- as.integer(args[2])
NBRun_Nr <- as.integer(args[3])

# Simulate model processing
cat("Running the model with the following parameters:\n")
cat(paste("Run_Nr:", Run_Nr, "PrevRun_Nr:", PrevRun_Nr, "NBRun_Nr:", NBRun_Nr, "\n"))

# Simulate successful processing
cat("Model run completed successfully!\n")
