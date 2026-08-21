README 

Stem Water Content Database.
Explanation of abbreviations for data contribution

1) meta
META DATA

unique_id:    a unique identifier that describes each unique tree individual sampled. IMPORTANT: the theta and meta data will be merged by this unique key
species:      the full species name (e.g. Astrocaryum vulgare) 
logger_id:    indicate the identifier for the datalogger used if available.
sensor_id:    indicate the identifier for the sensor (or port) of each logger if available
sensor_type:  technology used (e.g. FDR or TDR)
sensor_model: sensor model (e.g. Teros12 or GS3)
sensor_length:length in mm of sensor needles/waveguides (e.g. 30)
instal_height:height of installation as categorical (e.g. dbh, half_tree, crown)
dbh_cm:       stem diameter at breast height in cm (e.g. 35)
wd:	      wood density (g/cm3)
tree_height:  height of tree in m
canopy height:mean canopy height of forest in m
treatment:    experimental treatment applied (e.g. drought experiment); leave empty if not applicable.
plant_group:  angiosperm or gymnosperm
cotyledon:    monocotyledon or dicotyledon	
lat:          latitude of fieldsite Decimal Degrees (-1.792306)
long:         longitude of fieldsite Decimal Degrees (-51.434028)
elev:         elevation above sea level (m)
veg_type:     description of vegetation (e.g. tropical lowland forest)
location:     code for site name (e.g. cax_amz) for Caxiuana Amazonia
country_code: 3 digit code of country (e.g. BRA = Brazil)
msm_prd_start:start of measurement period (e.g. 01/05/2023; dd/mm/yyyy)
msm_prd_end:  end of measurement period (e.g. 01/05/2024; dd/mm/yyyy)	
author_fn:    first name(s) of author (e.g. Mary)
author_ln:    last name of author (e.g. Stuart)
author_email: e-mail of author
doi:          DOI of relevant publication
notes:	      additional information about the tree or site (e.g. tree diseased)

2) theta
STEM WATER CONTENT FIELD MEASUREMENT

unique_id:    a unique identifier that describes each unique tree individual sampled. IMPORTANT: the theta and meta dataset will be merged by this unique key
	      if there are different options to merge these datasets (such as a combination of logger and sensor ID), please indicate!
tmstmp:       timestamp (e.g. 01/09/2023 00:00:00)
tmstmp_fmt:   description of timestamp format (e.g. dd/mm/yyyy HH:MM:SS)
tmz:          timezone
ep:           epsilon (dielectric permittivity); main measurement for stem water content
raw_v:	      raw voltage output by sensor (if dielectric permittivity was not measured directly - fill in raw measurement and add the transformation equation in 'notes')
wc_clb:       if already available due to custom calibration, indicate the stem water content (in m3/m3) here.
temperature_sensor_C: if sensor measured temperature, fill in the temperature in Celsius here.	
logger_id:    indicate the identifier for the datalogger used if available
sensor_id:    indicate the identifier for the sensor (or port) of each logger if available.
notes:        additional information about the sensor or set-up 


3) met 
METEOROLOGICAL DATA

tmstmp:       timestamp
tmstmp_fmt:   description of timestamp format (e.g. dd/mm/yyyy HH:MM:SS)
tmz:          timezone
precip:       precipitation [mm]
rh:	      relative humidity [%]
vpd:          vapour pressure deficit [kPa]
tmp_C:        air temperature at field site [degree C]
soil_wc:      soil water content at field site [m3/m3]
soil_wp:      soil water potential [kPa]
notes:        additional information about met data or unusual weather/climatic events (e.g. El Nino 2023/24)



