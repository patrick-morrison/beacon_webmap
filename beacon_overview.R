library(leaflet)
library(sf)
library(geojsonsf)
library(htmlwidgets)

#Burials
bib <- geojson_sf("bib_shapes.geojson")
popup = paste0( "<b>ID: ", bib$ID, "</b></br>",
                "Description: " , bib$Description, "</br>",
                "Sex: " , bib$Sex,"</br>",
                "Stature: " , bib$Stature)

#National heritage list boundary
nhl <- geojson_sf("nhl_boundary.geojson")

# create the string for responsiveness that will be injected in the <head> section of the leaflet output html file.
# https://stackoverflow.com/questions/46453598/is-there-a-way-to-make-leaflet-map-popup-responsive-on-r
responsiveness = "\'<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\'"

map <- leaflet(bib, options = leafletOptions(preferCanvas = TRUE)) %>% 
  fitBounds(113.788, -28.4761, 113.7845, -28.4744) %>% 
  addProviderTiles(providers$Esri.WorldImagery,
                   options = providerTileOptions(minZoom = 8, maxZoom = 24),
                   group="basemap") %>% 
  groupOptions("basemap", zoomLevels = 0:18) %>% 
  addPolygons(data=nhl, fill = FALSE, color = "coral") %>% 
  addPolygons(popup=popup,
              popupOptions = popupOptions(maxWidth = 150)) %>% 
  addCircles(113.7919,-28.49164, color='green',
             label = "Batavia wreck",
             labelOptions = labelOptions(noHide = T, direction = "bottom")) %>%
  addScaleBar(position = 'bottomleft') %>% 
  addLegend("topright", 
                    colors =c("blue", "coral"),
                    labels= c("Burial","NHL"),
                    opacity = 1) %>% 
  addMeasure(primaryLengthUnit = "meters", secondaryLengthUnit  = "feet",
             primaryAreaUnit="sqmeters") %>% 
  #Add image overlays using custom javascript
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/beacon.jpg';
        var imageBounds = [[-28.473346, 113.783548], [-28.477364, 113.789071]];

        L.imageOverlay(imageUrl, imageBounds).addTo(myMap);
      }
      ") %>% 
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/BIB5-10.jpg';
        var imageBounds = [[-28.475220, 113.785611], [-28.475235, 113.785630]];

        L.imageOverlay(imageUrl, imageBounds).addTo(myMap);
      }
      ") %>% 
  htmlwidgets::onRender(paste0("
    function(el, x) {
      $('head').append(",responsiveness,");
    }")) %>% 
htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var bounds = [[-28.4761, 113.788], [-28.4744, 113.7845]];
        myMap.fitBounds(bounds);
      }
      ") #custom javascript to fix extent after adjusting for phone size
map
saveWidget(map, file="beacon.html")
