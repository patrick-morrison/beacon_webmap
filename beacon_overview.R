library(leaflet)
library(sf)
library(geojsonsf)
library(htmlwidgets)

#Burials
bib <- geojson_sf("spatial/bib_shapes.geojson")
kev <- geojson_sf("spatial/kevin_2018_outlines.geojson") %>%
  st_cast(to="POLYGON")

kev$geometry[1]

bib$geometry[7] <- kev$geometry[5]
bib$geometry[10] <- kev$geometry[4]
bib$geometry[12] <- kev$geometry[1]
bib$geometry[11] <- kev$geometry[3]
bib$geometry[8] <- kev$geometry[2]

bib <- bib[bib$ID!="BIB17U",]

popup = paste0( "<b>ID: ", bib$ID, "</b></br>",
                "Description: " , bib$Description, "</br>",
                "Sex: " , bib$Sex,"</br>",
                "Stature: " , bib$Stature)

#National heritage list boundary
nhl <- geojson_sf("spatial/nhl_boundary.geojson") 

#3D models

artefacts <- geojson_sf("spatial/artefacts.geojson")
artefacts_popup <- paste0("<b>",artefacts$Name,"<b></br><div class=\"sketchfab-embed-wrapper\"> <iframe title=\"",artefacts$Name,"\" frameborder=\"0\" allowfullscreen mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\" allow=\"fullscreen; autoplay; vr\" xr-spatial-tracking execution-while-out-of-viewport execution-while-not-rendered web-share height=\"300\" src=\"", artefacts$Embed, "\">")


map <- leaflet(bib, options = leafletOptions(preferCanvas = TRUE)) %>% 
  addProviderTiles(providers$Esri.WorldImagery,
                   options = providerTileOptions(minZoom = 8, maxZoom = 24),
                   group="basemap") %>% 
  groupOptions("basemap", zoomLevels = 0:18) %>% 
  addPolygons(data=nhl, fill = FALSE, color = "coral") %>% 
  addCircles(data=artefacts, popup = artefacts_popup,
             color = "green", radius = .3, fillOpacity = 0.05, weight = 3,
             popupOptions = popupOptions(maxHeight = 320)) %>% 
  addPolygons(opacity = 0.6, fillOpacity = 0.05, weight = 3, popup=popup,
              popupOptions = popupOptions(maxWidth = 150)) %>% 
  addCircles(113.7919,-28.49164, color='green',
             label = "Batavia wreck",
             labelOptions = labelOptions(noHide = T, direction = "bottom")) %>%
  addScaleBar(position = 'bottomleft') %>% 
  addLegend("topright", 
                    colors =c("blue", "coral", 'green'),
                    labels= c("Burial","NHL", 'Artefact'),
                    opacity = 1) %>% 
  addMeasure(primaryLengthUnit = "meters", secondaryLengthUnit  = "feet",
             primaryAreaUnit="sqmeters") %>% 
  #Add image overlays using custom javascript
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/overlays/beacon_landgate_3857.jpg';
        var imageBounds = [[-28.4767451632643, 113.78459900452], [-28.4738129947051, 113.78811918142]];

        L.imageOverlay(imageUrl, imageBounds, {opacity:1}).addTo(myMap);
      }
      ") %>% 
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/overlays/BIB5-10.jpg';
        var imageBounds = [[-28.475220, 113.785611], [-28.475235, 113.785630]];
        var bib5to10 = L.imageOverlay(imageUrl, imageBounds);
        myMap.addLayer(bib5to10);
        myMap.on('zoomend', function() {
            if (myMap.getZoom() <20){
            myMap.removeLayer(bib5to10);
        }
        else {
                myMap.addLayer(bib5to10);
            }
            });
        }
      ") %>% 
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/overlays/TR_08NOV_3857_KevinEdwards.jpg';
        var imageBounds = [[-28.4754649721572, 113.785689443598], [-28.475407300117, 113.785757071056]];
        var bib5to10 = L.imageOverlay(imageUrl, imageBounds);
        myMap.addLayer(bib5to10);
        myMap.on('zoomend', function() {
            if (myMap.getZoom() <20){
            myMap.removeLayer(bib5to10);
        }
        else {
                myMap.addLayer(bib5to10);
            }
            });
        }
      ") %>% 
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/overlays/TR_08NOV_BILS_6160_3857_KevinEdwards.jpg';
        var imageBounds = [[-28.4754466683899, 113.785745471317], [-28.4754426150744, 113.785749686212]];
        var bils6160 = L.imageOverlay(imageUrl, imageBounds);
        myMap.addLayer(bils6160);
        myMap.on('zoomend', function() {
            if (myMap.getZoom() <22){
            myMap.removeLayer(bils6160);
        }
        else {
                myMap.addLayer(bils6160);
            }
            });
        }
      ") %>% 
  htmlwidgets::onRender(paste0("
    function(el, x) {
      $('head').append('<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" />');
      console.log(this);
      var myMap = this;
      myMap.setView([-28.47557, 113.785956], 19)
    }"))
map
saveWidget(map, file="beacon.html")
