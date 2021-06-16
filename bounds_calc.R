#Script to calculate exact image bounds for overlay
#Export from qgis map with CRS=EPSG:3857
#Then save EPSG:3857 geotiff as .jpg

library(raster)
raster <- raster(file.choose()) %>% aggregate(10)
projected <- projectRaster(raster, crs="+init=EPSG:4326") 
ex <- extent(projected)

paste0("var imageBounds = [[",ex@ymax,', ',ex@xmin, "], [",ex@ymin,", ",ex@xmax,"]];")