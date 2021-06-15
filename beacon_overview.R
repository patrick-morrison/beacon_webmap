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
beacon <- raster::stack('beacon.tif')# %>% raster::aggregate(1.2)

map <- leaflet(bib, options = leafletOptions(preferCanvas = TRUE)) %>% 
  addProviderTiles(providers$CartoDB, options = providerTileOptions(minZoom = 8, maxZoom = 24)) %>% 
  addRasterRGB(beacon, 1,2,3, group = "True colours", project = FALSE, maxBytes = 10 * 1024 * 1024,) %>%
  addPolygons(data=nhl, fill = FALSE, color = "coral") %>% 
  addPolygons(popup=popup, popupOptions = popupOptions(maxWidth = 150)) %>% 
  addCircles(data=batavia, color='green', label = "Batavia wreck site", labelOptions = labelOptions(noHide = T, direction = "bottom"))%>%
  fitBounds(113.788, -28.47561, 113.784, -28.47523) %>% 
  addScaleBar(position = 'bottomleft') %>% 
  addLegend("topright", 
                    colors =c("blue", "coral"),
                    labels= c("Burial","NHL Boundary"),
                    opacity = 1)
map

map$dependencies <- list(
  htmlDependency(
    name = "custom"
    ,version = "1"
    # if local file use file instead of href below
    #  with an absolute path
    ,src = c(file="custom-1")
    ,stylesheet = "leaflet_custom.css"
  )
)
saveWidget(map, file="beacon.html")

