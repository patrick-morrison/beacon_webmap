#Script to calculate exact image bounds for overlay
#Export from qgis map with CRS=EPSG:3857
#Then save EPSG:3857 geotiff as .jpg
#This gets the bouding box then coverts that to EPSG:4326. 
#If you reproject before getting the bouding box, it is incorrect.

library(raster)
library(tidyverse)
library(sf)
raster <- raster(file.choose())

min <- c(xmin(raster), ymin(raster)) %>% st_point()
max <- c(xmax(raster), ymax(raster)) %>% st_point()

extent <- st_sfc(min, max, crs="+init=EPSG:3857")
projected <- st_transform(extent, crs="+init=EPSG:4326") 
ex <-st_coordinates(projected)

paste0("var imageBounds = [[",ex[3],', ',ex[1], "], [",ex[4],", ",ex[2],"]];")
