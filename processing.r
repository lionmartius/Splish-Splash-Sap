#### STEM WATER CONTENT (TEROS12) DATA PROCESSING  ######################


source("config.R")
source("functions.r")

# STEP 1: set the location of the original data to process and the files where we want the output to be stored

raw_folder_in <- paste0(DATA_PATH, "data_original")
raw_file_out <- paste0(DATA_PATH, "data_raw/raw_stem_water_content_", Sys.Date(), ".csv")
processed_file_out <- paste0(DATA_PATH, "data_processed/processed_stem_water_content_",Sys.Date(),".csv")

# STEP 2: apply the functions to fetch the original data and process it
# set your filtered dates

raw.df <- fetchTeros12(folderIn = raw_folder_in,
                       fileOut = raw_file_out) %>%
arrange(timestamp) %>%
  mutate(date = as_date(timestamp)) %>%
  filter(date > "2023-01-01") %>%
  filter(date < "2025-01-01")

head(raw.df)
tail(raw.df)

# we need to translate from label to tree id, to do so we will use the following object: 
# labelToID.data, which comes from the metadata where we have the
# relationship between loggers and tree ID


labelToID.data <- read.csv(paste0(DATA_PATH, "data_original/meta/cax_meta.csv")) %>%
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

stwc$calibrated_water_content_m3.m3[stwc$calibrated_water_content_m3.m3 < 0] <- NA
stwc$calibrated_water_content_m3.m3[stwc$calibrated_water_content_m3.m3 > 1] <- NA

stwc$water_content_m3.m3[stwc$water_content_m3.m3 < 0] <- NA
stwc$water_content_m3.m3[stwc$water_content_m3.m3 > 1] <- NA

stwc$stem_temperature_C[stwc$stem_temperature_C < 10] <- NA
stwc$stem_temperature_C[stwc$stem_temperature_C > 50] <- NA

head(stwc)
tail(stwc)

### TEMPERATURE CORRECTION ----------------------------------------------------- ####
# According to Martius et al. 2024 (https://academic.oup.com/treephys/article/44/8/tpae076/7702471)

# Apply temperature correction
mean_t <- mean(stwc$soil_temperature_C, na.rm = T)  # mean T is a suitable reference point

t_effect <- -0.000974  # temperature effect coefficient (from above mentioned study)

stwc <- stwc %>%
  mutate(temp_diff = soil_temperature_C  - mean_t, # calculate t - difference from reference (mean)
         temp_cor_calibrated_water_content_m3.m3 = calibrated_water_content_m3.m3 - (t_effect * temp_diff)  # Temperature correction - StWC.T
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
                             yVar = temp_cor_calibrated_water_content_m3.m3,
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


#### DAILY DATA PLOTTING ------------------------------------------------------- ####

daily_stwc <- read_csv("data_processed/stem_water_content/complete_datasets/daily_processed_stem_water_content_2023-05-02-2024-07-25.csv")

for(ind in unique(daily_stwc$ID)){
  
  
  # ind <- "Control_211"
  ind_data <- daily_stwc %>%
    filter(ID == ind)
  # filter(date == "2023-11-12")
  
  # raw water content
  ind.plot <- plotTimeSeries(data = ind_data,
                             xVar = date,
                             yVar = water_content_m3.m3,
                             xLab = "", 
                             yLab = "stem wc (m3/m3)", 
                             lineOrPoint = "line", 
                             colorVar = ID)
  
  # gap filled and calibrated water content
  gf_ind.plot <- plotTimeSeries(data = ind_data,
                                xVar = date,
                                yVar = gf_clean_calibrated_water_content_m3.m3,
                                xLab = "", 
                                yLab = "gf cl stem wc (m3/m3)", 
                                lineOrPoint = "line", 
                                colorVar = ID)
  
  # temperature corrected gap filled and calibrated water content
  tc_ind.plot <- plotTimeSeries(data = ind_data,
                                xVar = date,
                                yVar = tempCor_gf_clean_calibrated_water_content_m3.m3,
                                xLab = "", 
                                yLab = "tc gf cl stem wc (m3/m3)", 
                                lineOrPoint = "line", 
                                colorVar = ID)
  
  # Save the plot
  pdf(paste0("outputs/data_plots/stem_water_content/daily/stem_wc_", ind, "_", str_replace(unique(ind_data$species), " ", "_"),".pdf"))
  p <- ggarrange(ind.plot,
                 gf_ind.plot,
                 tc_ind.plot, ncol = 1, legend = "bottom", common.legend = T)
  plot(p)
  dev.off()
}
