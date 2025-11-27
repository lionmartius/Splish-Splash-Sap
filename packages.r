# Install and Load relevant packages

packages <- c("readr",
              "dplyr",
              "ggplot2",
              "ggpubr",
              "lubridate",
              "hms",
              "lme4",
              "lmerTest",
              "MuMIn",
              "interactions",
              "stringr",
              "data.table",
              "readxl")

for (package in packages) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package)
    }
    library(package, character.only = TRUE)
}
