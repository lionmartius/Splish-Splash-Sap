# theta_format_coversion
# this script helps to convert the saved stwc files into the correct theta format for SteW
setwd(getwd())
field_loc <- "PPF"

met <- read_excel("SteW_templates/met.xlsx")
meta <- read_excel("SteW_templates/meta.xlsx")
theta <- read_excel("SteW_templates/theta.xlsx")

# Use the processed data already loaded in the workspace.
if (!exists("stwc")) {
    stop("Load the processed data into an object called 'stwc' before running this script")
}

required_stwc_columns <- c("timestamp", "ID", "teros12_sensor", "v_stwc", "temp_C")
missing_stwc_columns <- setdiff(required_stwc_columns, names(stwc))
if (length(missing_stwc_columns) > 0) {
    stop("stwc is missing required columns: ", paste(missing_stwc_columns, collapse = ", "))
}

# Resize the template to the number of measurements without changing its columns.
theta <- theta[seq_len(nrow(stwc)), , drop = FALSE]

theta$unique_id <- stwc$ID
theta$tmstmp <- stwc$timestamp
theta$tmstmp_fmt <- "%Y-%m-%dT%H:%M:%OSZ"
theta$tmz <- "UTC-03:00"
theta$ep <- NA
theta$raw_v <- NA
theta$wc_clb <- stwc$v_stwc
theta$temperature_sensor_C <- stwc$temp_C
theta$logger_id <- stwc$teros12_sensor
theta$sensor_id <- stwc$teros12_sensor
theta$notes <- NA

theta_output <- file.path(
    "SteW_folder_out/",
    paste0(field_loc, "/", field_loc, "_theta.csv")
)
write_csv(theta, theta_output)

stopifnot(identical(names(theta), names(read_excel("SteW_templates/theta.xlsx"))))
print(paste0("saving theta data in ", theta_output))

str(meta)
