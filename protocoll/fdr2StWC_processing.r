# FDR/TDR measurements to Tree Water Content
# Data processing
# Edinburgh, 18/04/2024
# Lion R. Martius

dt <- read.csv(file = 'living_trees.csv')
summary(dt)
str(dt)
require(ggplot2)


# This exemplary dataset contains FDR (Teros12; 3 cm length) measurements
# from 3 Dicotyledonous Trees and 2 Monocotyledonous Palms from Amazónia (BR).
unique(dt$species)
# Trees: "Vouacapoua americana", "Licania octandra", "Manilkara bidentata" 
# Palms: "Astrocaryum vulgare"  "Oenocarpus distichus"

# Other variables:
# time: timestamp
dt$time <- as.POSIXct(strptime(dt$time, format = "%d/%m/%Y %H:%M")) # format 

  
# vwc:  volumetric water content as measured by shortened Teros12 sensors using 
#       the mineral-soil calibration (this is of no interest here)
# t:    temperature
# RAW:  RAW sensor output from sensor


# 1) calculate dielectric permittivity using the RAW sensor output

dt$ep <- (2.887 * 10^-9 * dt$RAW^3 - 2.080 
               * 10^-5 * dt$RAW^2 + 5.276 * 10^-2 * dt$RAW -43.39 )^2

dt$ep.sqrt <- sqrt(dt$ep)   # The calibration equation for woody tissue is based
                            # on the square root dielectric permittivity

# 2) calculate absolute StWC using the TTC

dt$StWC <- 0.2227 * dt$ep.sqrt - 0.396

# 3) Apply temperature corrections

mean(dt$t, na.rm = T) # mean T makes is a suitable reference point
                      # 25.3°C 
dt$t_diff <- as.numeric(dt$t) - mean(dt$t, na.rm = T)
                      # calculate t - difference from reference (mean)
t_effect <- -0.000974 # temperature effect coefficient

# Temperature correction - StWC.T
dt$StWC.T <- dt$StWC - dt$t_diff*t_effect  # this is the column for the temperature
                                           # corrected stem water content


# plot T correction over uncorrected, raw StWC; exemplary for 'V. americana' 
# and using a subset of the dataset
ggplot(data = dt[dt$species == 'Vouacapoua americana'&
                   dt$time < '2023-03-30 01:15:00',])+
  geom_line(mapping = aes(time,StWC))+
  geom_line(mapping = aes(time, StWC.T), col = 'red')


# 4a) Calculate stem water deficit relative to the max &
# 4b) relative water content (rwc)
# using the slope only (which is constant across species),
# which removes intercept variations 

# a)
dt$dep <- NA
# b)
dt$rwc <- NA

# Loop through each species
for (species in unique(dt$species)) {
  # Subset the data for the current species
  sub_dt <- dt[dt$species == species, ]
  
  # Find the maximum/minimum saturation value for the current species
  StWC_max <- max(sub_dt$StWC.T, na.rm = TRUE)
  StWC_min <- min(sub_dt$StWC.T, na.rm = TRUE)
  
  # Calculate water deficit/RWC for the current species
  sub_dt$dep <- sub_dt$StWC.T - StWC_max
  sub_dt$rwc <- (sub_dt$StWC.T - StWC_min)/(StWC_max - StWC_min)
  
  # Merge the calculated RWC values back into the main dataset
  dt[dt$species == species, "dep"] <- sub_dt$dep
  dt[dt$species == species, "rwc"] <- sub_dt$rwc
}

ggplot(data = dt[dt$species == 'Vouacapoua americana',])+
  geom_line(mapping = aes(time,dep))

ggplot(data = dt[dt$species == 'Vouacapoua americana',])+
  geom_line(mapping = aes(time,rwc))

