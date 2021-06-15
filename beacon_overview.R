library(leaflet)
library(sf)
library(geojsonsf)
library(htmlwidgets)
library(raster)
library(leafem)

bib <- geojson_sf("bib_shapes.geojson")

popup = paste0( "<b>ID: ", bib$ID, "</b></br>",
                "Description: " , bib$Description, "</br>",
                "Sex: " , bib$Sex,"</br>",
                "Stature: " , bib$Stature
)

batavia <- geojson_sf("batavia_wrecksite.geojson")
nhl <- geojson_sf("nhl_boundary.geojson")
beacon <- raster::stack('beacon.tif')# %>% raster::aggregate(5)
bib5to10 <- raster('BIB5-10.tif')# %>% raster::aggregate(5)

pal <- colorRampPalette(c("black", "white"))
plot(bib5to10, col=pal(10))

map <- leaflet(bib, options = leafletOptions(preferCanvas = TRUE)) %>% 
  addProviderTiles(providers$Esri.WorldImagery, options = providerTileOptions(minZoom = 8, maxZoom = 24), group="basemap") %>% 
  addRasterRGB(beacon, 1,2,3, group = "True colours", project = FALSE, maxBytes = 10 * 1024 * 1024) %>%
  addRasterImage(bib5to10, colors=pal(10), project = TRUE, maxBytes = 10 * 1024 * 1024) %>%
  addPolygons(data=nhl, fill = FALSE, color = "coral") %>% 
  addPolygons(popup=popup, popupOptions = popupOptions(maxWidth = 150)) %>% 
  addCircles(data=batavia, color='green', label = "Batavia wreck site", labelOptions = labelOptions(noHide = T, direction = "bottom"))%>%
  fitBounds(113.788, -28.47561, 113.784, -28.47523) %>% 
  addScaleBar(position = 'bottomleft') %>% 
  addLegend("topright", 
                    colors =c("blue", "coral"),
                    labels= c("Burial","NHL"),
                    opacity = 1) %>% 
  groupOptions("True colours", zoomLevels = 17:30) %>% 
  groupOptions("basemap", zoomLevels = 0:18) %>% 
  groupOptions("burials", zoomLevels = 20:30)
map

saveWidget(map, file="beacon.html")

