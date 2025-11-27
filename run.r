#### STEM WATER CONTENT (TEROS12) DATA PROCESSING  ######################

source("config.R")
source("functions.r")

# STEP 1: set the location of the original data to process and the files where we want the output to be stored

raw_folder_in <- paste0(DATA_PATH, "data_original/theta")
raw_file_out <- paste0(DATA_PATH, "data_raw/raw_stem_water_content_", Sys.Date(), ".csv")
processed_file_out <- paste0(DATA_PATH, "data_processed/processed_stem_water_content_",Sys.Date(),".csv")

# STEP 2: apply the functions to fetch the original data and process it
# set your filtered dates

raw.df <- fetchTeros12(folderIn = raw_folder_in,
                       fileOut = raw_file_out) %>%
arrange(timestamp) %>%
  mutate(date = as_date(timestamp)) %>%
  filter(date > "2025-01-01") %>%
  filter(date < "2027-01-01")

head(raw.df)
tail(raw.df)

# we need to translate from label to tree id, to do so we will use the following object: 
# labelToID.data, which comes from the metadata where we have the
# relationship between loggers and tree ID


labelToID.data <- read.csv(paste0(DATA_PATH, "data_original/meta/tux_meta.csv")) %>%
  filter(!is.na(logger_id)) %>%
  mutate(label = paste0(logger_id, "_", sensor_id)) %>%
  select(ID, species, label, treatment)

## process data

processed.list <- processTeros12(rawDataFile = raw_file_out,
                                 rawData = NULL,
                                 labelToIDFile = NULL,
                                 labelToID = labelToID.data,
                                 fileOut = processed_file_out)

# here we can see how it looks
tail(processed.list$processed_data)

summary(processed.list$processed_data)


#### DATA CLEANING ------------------------------------------------------------- ####

### out of range values
stwc <- read.csv(paste0(DATA_PATH,"data_processed/processed_stem_water_content_",Sys.Date(),".csv"))

stwc$v_stwc[stwc$v_stwc < 0] <- NA
stwc$v_stwc[stwc$v_stwc > 1] <- NA

stwc$raw_stwc[stwc$raw_stwc < 0] <- NA
stwc$raw_stwc[stwc$raw_stwc > 1] <- NA

stwc$temp_C[stwc$temp_C < 10] <- NA
stwc$temp_C[stwc$temp_C > 50] <- NA
head(stwc)
tail(stwc)

### TEMPERATURE CORRECTION ----------------------------------------------------- ####
# According to Martius et al. 2024 (https://academic.oup.com/treephys/article/44/8/tpae076/7702471)

# Apply temperature correction
ref_t <- 25  # reference temperature (°C)

t_effect <- -0.000974  # temperature effect coefficient (from above mentioned study)

stwc <- stwc %>%
  mutate(temp_diff = temp_C  - ref_t, # calculate t - difference from reference
         v_stwc_tcor = v_stwc  + (t_effect * temp_diff)  # Temperature correction - StWC.T
  ) %>%
  select(-temp_diff) %>%
  arrange(ID, timestamp) %>%
  filter(!is.na(ID))

summary(stwc)

#### SAVE FINAL DATASET -------------------------------------------------------- ####
## to project directory

write_csv(stwc, 
          paste0(DATA_PATH, "data_processed/temp_corrected/processed_stem_water_content_", 
                 as_date(min(stwc$timestamp)), "-", 
                 as_date(max(stwc$timestamp)), ".csv")
)


#### SUBDAILY DATA PLOTTING ---------------------------------------------------- ####

stwc$timestamp <- as.POSIXct(stwc$timestamp, format = "%Y-%m-%dT %H:%M:%S")
stwc$date <- as_date(stwc$timestamp)

for(ind in unique(stwc$ID)){
  
  ind_data <- stwc %>%
    filter(ID == ind) %>% 
    mutate(date = as_date(timestamp))
  
  # temp cor calibrated water content
  ind.plot <- plotTimeSeries(data = ind_data,
                             xVar = timestamp,
                             yVar = v_stwc_tcor,
                             xLab = "", 
                             yLab = "stem wc (m3/m3)", 
                             lineOrPoint = "line", 
                             colorVar = ID) + 
    scale_x_datetime(date_breaks = "1 month", date_labels = "%b")
 
  # Save the plot
  pdf(paste0(DATA_PATH,"plots/stem_wc_", ind, "_", str_replace(unique(ind_data$species), " ", "_"),".pdf"))
  print(ind.plot)
  dev.off()
}