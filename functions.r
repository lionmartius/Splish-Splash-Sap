# Functions for processing stem water content data from ZL6 Loggers (Labcell)
# Authors: Pablo Sanchez-Martinez & Lion R. Martius


source("config.r")

### TEROS 12 ------------------------------------------------------------------- ####

### Read Teros 12 stem water cotent data ####

fetchTeros12 <- function(folderIn = NULL,
                         fileOut = NULL){
  

  if(is.null(folderIn)){
    stop("specify folderIn path where the input data is located")
  }
  
  # function to read individual excel files and change from wide to long format
  readWcXlsx <- function(file){
    
    # extract logger metadata and name (serial number) from file
    
    metadataLogger <- as.data.frame(t(read_excel(file, sheet = "Metadata", col_names = F)))
    colnames(metadataLogger) <- metadataLogger[2, ]
    metadataLogger <- metadataLogger[3, ]
    loggerName <- metadataLogger[, "Serial Number"]
    
    # identify sheets with data
    processed_data_sheets <- which(str_detect(excel_sheets(file), "Processed"))
    
    # retrieve data for each of the sheets with data
    
    all_sheets_long.df <- data.frame("timestamp" = character(), 
                                     "label" = character(),
                                     "raw_stwc" = numeric(),
                                     "temp_C" = numeric(),
                                     "bulk_EC" = numeric())
    
    for(dataSheet in processed_data_sheets){
      
      # extract column names from file
      Names <- as.data.frame(read_excel(file, sheet = dataSheet, col_names = F))[1:3, -1]
      
      colNames <- c("timestamp")
      for(i in 1:length(Names)){
        colName <- paste0(Names[1, i], ".", Names[3, i])
        
        colNames <- c(colNames, colName)
      } 
      
      colNames <- str_replace_all(colNames, " ", "_")
      colNames <- str_remove(colNames, "°")
      colNames <- str_replace_all(colNames, "³", "3")
      
      # Wide data
      
      wide.df <- as.data.frame(
        read_excel(file, 
                   skip = 3 , col_names = colNames, sheet = dataSheet)
      ) %>%
        select(timestamp, contains(paste0("Port_", 1:6)))
      
      long.df <- data.frame("timestamp" = character(), 
                            "label" = character(),
                            "raw_stwc" = numeric(),
                            "temp_C" = numeric(),
                            "bulk_EC" = numeric())
      
      # Identify ports with WC data
      
      ports <- unlist(Names[1, ])
      ports <- unique(str_replace_all(ports[which(ports %in% paste0("Port ", 1:6))], " ", "_"))
      
      # Long data
      
      for(port in ports){
        
        if(paste0(port, ".m3/m3_Water_Content") %in% names(wide.df)){  # to make sure sensor has been colecting data
          ind_long.df <- data.frame(
            "timestamp" = wide.df[, "timestamp"],
            "label" = paste0(loggerName, "_", port),
            "raw_stwc" = wide.df[, paste0(port, ".m3/m3_Water_Content")],
            "temp_C" = ifelse(paste0(port, ".C_Soil_Temperature") %in% names(wide.df), 
                                          wide.df[, paste0(port, ".C_Soil_Temperature")], 
                                          NA),  # to avoid problems with basic loggers (which don't measure temperature or bulk density)
            "bulk_EC" = ifelse(paste0(port, ".mS/cm_Bulk_EC") %in% names(wide.df), 
                                     wide.df[, paste0(port, ".mS/cm_Bulk_EC")], 
                                     NA)  # same as with temperature
          )
          
          long.df <- rbind(long.df,
                           ind_long.df)
        } else{
          warning(paste0("no data for sensor ", paste0(loggerName, "_", port)))
        }
        

        
      }
      
      all_sheets_long.df <- rbind(all_sheets_long.df, long.df)
      
    }
    return(all_sheets_long.df)
  }
  
  file.list <- list.files(folderIn, 
                          pattern = ".xlsx", 
                          full.names = T)
  
  raw_data.list <- lapply(file.list, 
                          readWcXlsx)
  
  raw_data.df <- do.call(rbind, raw_data.list)
  
  if(!is.null(fileOut)){
    write_csv(raw_data.df, fileOut)
    print(paste0("saving raw data in ", fileOut))
  }
  
  return(raw_data.df)
}


processTeros12 <- function(rawDataFile = NULL,
                              rawData = NULL,
                              labelToIDFile = NULL,
                              labelToID = labelToID.data,
                              fileOut = NULL,
                              offset = -0.08189, # TTCM (Martius et al. 2024)
                              multiplier = 1.83658){ # TTCM (Martius et al. 2024)
  require(readr)
  require(stringr)
  require(lubridate)
  
  # Read raw data

  if(is.null(rawData) && is.null(rawDataFile)){
    stop("Specify rawData object or rawDataFile path")
  }  
    
  if(is.null(rawData) && !is.null(rawDataFile)){
    rawData <- read_csv(rawDataFile) 
    print(paste0("reading raw data from ", rawDataFile))
  }
  
  # process data

  labelToID <- labelToID %>%
    filter(label %in% unique(rawData$label))
  
  processedData <- merge(rawData, 
                         labelToID, 
                           by = "label", 
                           all.x = T) %>%
    mutate(date = as_date(as_datetime(timestamp)),
           v_stwc = offset + (raw_stwc * multiplier)) %>%
    select(timestamp, date, ID, treatment, species, teros12_sensor = label, everything())
  
  rslts <- list("processing_table" = labelToID,
                "processed_data" = processedData)
  
  if(!is.null(fileOut)){
    write_csv(processedData, fileOut)
    print(paste0("saving processed data in ", fileOut))
  }
  
  return(rslts)
}


### PLOTTING

### Plot time series (points or lines) ####

plotTimeSeries <- function(data, xVar, yVar , colorVar, xLab = "x", yLab = "y", lineOrPoint = "line"){
  
  arg <- match.call()
  
  plot <- ggplot(data, aes(x = eval(arg$xVar), y = eval(arg$yVar), color = eval(arg$colorVar)))
  
  if(lineOrPoint == "line"){
    plot <- plot + 
      geom_line() + 
      theme_minimal() +
      theme(legend.title = element_blank(), legend.position = "bottom") +
      xlab(xLab) + ylab(yLab)
  }
  
  if(lineOrPoint == "point"){
    plot <- plot +
      geom_point(alpha = 0.1) + 
      geom_smooth(method = "gam") + 
      theme_minimal() +
      theme(legend.title = element_blank(), legend.position = "bottom") +
      xlab(xLab) + ylab(yLab)
  }
  
  return(plot)
}
