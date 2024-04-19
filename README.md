<div style="overflow:auto;">
  <img align="right" width="115" height="90" src="https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/6081be2c-e8bf-4756-b820-9c7f3f54054a">
  
  # Monitoring stem water content in&nbsp; trees across tropical forest ecosystems and other biomes
  </div>

  ### Protocol for field installation and data processing using FDR/TDR sensors




Trees and whole forest ecosystems are becoming increasingly exposed to droughts under climate change. Accurate capture of vegetation water content will substantially advance how we quantify drought stress and related mortality risk in trees. In our latest publication, we established a first generic relationship between stem water content and dielectric permittivity in woody tissue, using electromagnetic sensors. This protocol is designed to facilitate the installation of electromagnetic sensors for monitoring tree water content at high temporal resolution. Here, you will be able to find a detailed description of the installtion procedure (a list of DOs and DON'Ts), a list of the right tools needed for installation & scripts (R-language) for data processing. Within our study, we used modified Teros12 (Meter Group, Pullman, WA, USA) sensors, with shortened waveguides (3 cm) to assure that the signal is dominated by sapwood water content, as uncertainties remain on the physiological functionality of the heartwood. Please adjust the protocol if other sensor types or waveguid lenghts are chosen, accordingly.

## Tools and Preparation
We advise to shorten waveguides before going into the field. Sensor needle cutting should be done under high precision. Differences in needle lenghts affect the intercept of the sensor readings. We cut all our Teros12 sensors to 3 cm sensor length. You will need the following tools:
- FDR/TDR sensor
- Environmental/radiation shield
- Datalogger and relevant power supply
- Drill
- Drill bits [High Speed Steel (HSS); 3 mm x 80 mm (or slightly smaller than waveguide width to ensure close contact between sensor and tissue)]
- Silicon based sealant
- Dead-blow hammer
- Machete/Draw knife
- Recommended: Custom made drill guide to insure all holes to be parallel

## Installation
<img align = "right" width = "100" height = "200" src= "https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/026be7f1-6ac1-4896-a6e0-d2b3628eb6de">


**1) Select the tree or palm** of your choice. Please remember, these sensors are sensitive to temperature and should thus be exposed to as little sun radiation as possible. Hence, it it good practice to install sensors on the northward (for northern hemisphere-ists), or southward facing (for southern heimpshere-ists) of the trunk. In addition, we recommend using solar radiation shields to avoid rapid temperature changes. Additionally, we provide code for applying temperature corrections during data processing, as temperature has a significant impact on the FDR sensor reading.
When selecting the specific installtion location on the trunk, make sure that the tissue at the location appears to be healthy with no obvious wounds, infections or branches that could locally affect the measurements.

**2) Remove the bark** using a machete or draw knife, and make sure the exposed wood is fairly plane, so the sensor can rest against the  bark ensuring close contact.

**3) Attach the drill guide** where you would like the sensor to be installed. Mark your drill bits at the same lenght of the sensor needle length, to avoid drilling holes deeper than the sensor. Remember, if you use a drill guide, add the guide's width to the length, and mark the drill bit at: sensor waveguide length [cm] + drill guide width [cm]. 

**4) Drill three parallel holes into the sapwood**. Carefully drill into the tree without using too much force or torque. If you encounter very dense tropical hardwoods, it might take a bit of time and practise. Do not keep drilling if you encounter too much resistance. It will creat substantial heat generated from friction, and can lead to burning/damaging the tissue. Rather, take your time with more attempts, avoidig the drillbit and tissue to overheat. Then, remove the drillguide. 



https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/1f809ab7-2871-45de-a423-c189184d450a













**5) Install FDR/TDR sensor into the tree**. Use a dead blow mallet to gently hammer the sensor into the wood, and ensure that there is close contact with the tree with no obvious air gaps between the sensor and the wood.

**6) Seal the sensor**. Use a silicon based sealant to seal the sensor's head to the woody tissue. It is important to ensure that there is no interaction with the atmosphere as the protective layer of the bark has been removed. This could lead to the locally drying of the wood at the installation site or water condensation at the sensor, affecting sensor readings.

**7) Connect your sensor to a datalogger** & collect your water content data.


## Data processing 
The repository contains an exemplary dataset from three tropical dicotyledonous trees (_Licania octandra_ Kuntze, _Vouacapoua americana_ Aubl., _Manilkara bidentata_ A.Chev.)  and two monocotyledonous palms (_Oenocarpus distichus_ Mart., _Astrocaryum vulgare_ Mart.) from **Floresta Nacional de Caxiuanã, Amazônia** (1°43′S, 51°27′W). 

When using the Teros12 sensors in combination with ZL6 dataloggers, then the output will include measures of temperature, raw data and processed volumetric water content (VWC). ZL6 logger readily process the raw data measured into VWC using a mineral soil cailbration.

$`\theta (m^3/m^3) = 3.879 \times 10^{−4} \times RAW − 0.6956 `$

When using a different sensor - logger combination, we will likely either be measuring dielectric permittivity direclty or raw data, the latter of which we will need to convert into dielctric permittivity first, using the following equation. 

$`\epsilon = (2.887 \times 10^{-9} \times RAW^3 - 2.080 \times 10^{-5} \times RAW^2 + 5.276 \times 10^{-2} \times RAW -43.39 )^2`$
```R
# Calculate dielectric permittivity from the RAW sensor output

dt$ep <- (2.887 * 10^-9 * dt$RAW^3 - 2.080 * 10^-5 * dt$RAW^2 + 5.276 * 10^-2 * dt$RAW -43.39 )^2

dt$ep.sqrt <- sqrt(dt$ep)  # apply square root transformation 
```
### Calculating woody tissue water content
We can then convert measures of dielectric permittivity into stem VWC when working with the species from our paper.
The following equation is derived from our calibration work in tropical trees and palms:         


$θ_{\text{stem}}=0.2227\times \sqrtε_{\text{stem}}-0.396 $ 
 <img align = "right" width = "450" height = "300" src="https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/5d2ca122-0cc9-4d10-b2ac-3015060789ae">
```R
# Estimate the stem water content
# using the TTC

dt$StWC <- 0.2227 * dt$ep.sqrt - 0.396
```
### Applying temperature corrections
Our findings suggested that FDR sensors are highly temperature sensitive, which can lead to artefactual changes in water content. If the sensor is exposed to larger diurnal or seasonal temperature fluctuations, especially in highly seasonal ecosystems, it is important to apply the following temeperature correction:

```R
# Apply temperature correction
mean(dt$t, na.rm = T) # mean T is a suitable reference point
                      # 25.3°C 
dt$t_diff <- as.numeric(dt$t) - mean(dt$t, na.rm = T)
                      # calculate t - difference from reference (mean)
t_effect <- -0.000974 # temperature effect coefficient (from our study)

# Temperature correction - StWC.T
dt$StWC.T <- dt$StWC - dt$t_diff*t_effect  # this is the column for the temperature
                                           # corrected stem water content
require(ggplot2)
ggplot(data = dt[dt$species == 'Vouacapoua americana'&
                   dt$time < '2023-03-30 01:15:00',])+
  geom_line(mapping = aes(time,StWC))+
  geom_line(mapping = aes(time, StWC.T), col = 'red')
                                           # this plot will help visualise the t-bias
```

Please note that our findigs suggest that there are species-specific random variations in the intercepts which negatively affect the accuracy of the measurements when working with different species. However, we found that the slope of the calibration is _universal_ for woody tissue in general. Hence, the calibration can be used to estimate __relative__ changes in stem water content or stem water deficits from the maximum accurately.

The intercept becomes unimportant when Normalizing the water content data; Here is an example of how to calculate stem water deficit from the maximum value:

```R
# Create an empty column for water deficit
# (absolute departure from the maximum saturation within the dataset)
dt$dep <- NA
# Another option is to create a column for relative water content
dt$rwc <- NA

# Loop through each species
for (species in unique(dt$species)) {
  # Subset the data for the current species
  sub_dt <- dt[dt$species == species, ]
  
  # Find the maximum/minimum saturation value for the current species
  StWC_max <- max(sub_dt$StWC.T, na.rm = TRUE)
  StWC_min <- min(sub_dt$StWC.T, na.rm = TRUE)
  
  # Calculate water deficit/RWC for the current species
  sub_dt$def <- sub_dt$StWC.T - StWC_max
  sub_dt$rwc <- (sub_dt$StWC.T - StWC_min)/(StWC_max - StWC_min)
  
  # Merge the calculated RWC values back into the main dataset
  dt[dt$species == species, "dep"] <- sub_dt$dep
  dt[dt$species == species, "rwc"] <- sub_dt$rwc
}
```

Have a lovely time in the field & bom campo e bom trabalho! 

Lion 🌴

 <img align = "right" dpi = 3000 width = "320" height = "250" src= https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/65fb286c-5f4b-4f0d-8e13-bd886ff51a31 >
 
 <img align = "centre" dpi = 3000 width = "320" height = "250" src= https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/3c9796d2-a77a-4878-bf63-72f8d6340126>
 
<img align = "left" dpi = 3000 width = "320" height = "250" src = "https://github.com/lionmartius/Splish-Splash-Sap/assets/146541125/333ce9f4-10f7-4891-ab0c-4b765ffd816d">

                     




