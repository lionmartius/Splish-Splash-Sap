# Processing Stem Water Content Data from ZL6 Loggers

## Overview

This repository contains scripts and instructions for processing stem water content data from ZL6 Loggers.

## Steps to Follow

1. **Fork and Clone the Repository**
   - Fork the repository `Splish-Splash-Sap` and clone it to your local machine.

2. **Branch Information**
   - The current branch for processing is `stwc_data_processing_ZL6`.

3. **Data Storage**
   - Store all the downloaded original ZL6 data without any pre-treatment in the folder `Data/data_original`.
   - Store the META data (follow the example for how to prepare the META data) in the folder `Data/data_original/meta`.

4. **Running the Scripts**
   - Run the scripts in the following order:
     1. `packages`
     2. `config`
     3. `functions`
     4. `processing`

5. **Global Environment**
   - `DATA_PATH` will be set as a global environment variable within your working environment.

6. **Output**
   - The processed data will be saved as one data file in the `data_processed/temp_corrected` folder.
   - Plots will be saved for each individual as PDF files in the `plots` folder.


## Notes

- Ensure that the `DATA_PATH` is correctly set in your environment to avoid any issues with file paths.
- Follow the example provided for preparing the META data to ensure consistency.

## Contact

For any questions or issues, please contact the repository maintainer.
