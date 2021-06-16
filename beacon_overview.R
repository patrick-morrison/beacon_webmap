library(leaflet)
library(sf)
library(geojsonsf)
library(htmlwidgets)

#Burials
bib <- geojson_sf("bib_shapes.geojson")
kev <- geojson_sf("kevin_2018_outlines.geojson") %>%
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
nhl <- geojson_sf("nhl_boundary.geojson") 

map <- leaflet(bib, options = leafletOptions(preferCanvas = TRUE)) %>% 
  addProviderTiles(providers$Esri.WorldImagery,
                   options = providerTileOptions(minZoom = 8, maxZoom = 24),
                   group="basemap") %>% 
  groupOptions("basemap", zoomLevels = 0:18) %>% 
  addPolygons(data=nhl, fill = FALSE, color = "coral") %>% 
  addPolygons(opacity = 0.5, weight = 2, popup=popup,
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
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/beacon_3857_high.jpg';
        var imageBounds = [[-28.4731733528342, 113.78348182555], [-28.4775356528342, 113.78963552555]];

        L.imageOverlay(imageUrl, imageBounds).addTo(myMap);
      }
      ") %>% 
  htmlwidgets::onRender("
      function(el, x) {
        console.log(this);
        var myMap = this;
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/BIB5-10.jpg';
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
        var imageUrl = 'https://patrick-morrison.github.io/beacon_webmap/TR_08NOV_3857_KevinEdwards.jpg';
        var imageBounds = [[-28.475406190117, 113.785688393598], [-28.475466315117, 113.785758113598]];
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
  htmlwidgets::onRender(paste0("
    function(el, x) {
      $('head').append('<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" />');
      console.log(this);
      var myMap = this;
      myMap.setView([-28.47557, 113.785956], 19)
    }"))
map
saveWidget(map, file="beacon.html")
