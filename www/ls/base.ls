L.Icon.Default.imagePath = "https://samizdat.cz/tools/leaflet/images/"
proj = ->
  proj4 do
    '+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs'
    'EPSG:4326'
    it

data = for id, datum of ig.data.mereni
  datum.latLng = L.latLng (proj [datum.x, datum.y]).reverse!
  datum


percentage = ->
  decimals = if it < 0.01 then 1 else 0
  "#{window.ig.utils.formatNumber it * 100, decimals}&nbsp;%"

container = d3.select ig.containers.base
mapElement = container.append \div
  ..attr \class \map

map = L.map do
  * mapElement.node!
  * minZoom: 7,
    maxZoom: 12,
    zoom: 7,
    center: [49.78, 15.5]
    maxBounds: [[48.3,11.6], [51.3,19.1]]

baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 0.8
    attribution: 'CC BY-NC-SA <a href="http://rozhlas.cz">Rozhlas.cz</a>. Data <a href="https://www.czso.cz/" target="_blank">ČSÚ</a>, mapová data &copy; <a target="_blank" href="http://osm.org">OpenStreetMap</a>, podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l2/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.8

map
  ..addLayer baseLayer
  ..addLayer labelLayer

for datum in data
  marker = L.marker datum.latLng
    ..addTo map
