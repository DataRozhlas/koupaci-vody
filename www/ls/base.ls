L.Icon.Default.imagePath = "https://samizdat.cz/tools/leaflet/images/"
proj = ->
  proj4 do
    '+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813975277778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m no_defs'
    'EPSG:4326'
    it
data = for id, datum of ig.data.mereni
  datum.latLng = L.latLng (proj [datum.x, datum.y]).reverse!
  yearsAssoc = {}
  for evaluation in datum.evaluations
    [d, m, y] = evaluation.date.split "." .map parseInt _, 10
    evaluation.dateString = evaluation.date
    evaluation.date = new Date!
      ..setTime 12 * 3600 * 1e3
      ..setDate d
      ..setMonth m + 1
      ..setFullYear y
    yearsAssoc[y] ?= []
    yearsAssoc[y].push evaluation
  d = new Date!
    ..setTime 0
    ..setMonth 5
    ..setDate 1
  goodResults = 0
  allResults = 0
  datum.years = for year, evaluations of yearsAssoc
    year = parseInt year, 10
    d.setFullYear year
    timeStart = d.getTime!
    for evaluation in evaluations
      evaluation.relativeTime = evaluation.date.getTime! - timeStart
      allResults++
      goodResults++ if evaluation.result <= 2
    {year, evaluations, timeStart}
  datum.ratio = (goodResults / allResults) || 1
  datum
d = new Date!
  ..setTime 0
  ..setMonth 5
  ..setDate 0


d = new Date!
  ..setTime 0
  ..setMonth 5
  ..setDate 0
t1 = d.getTime!
percentage = ->
  decimals = if it < 0.01 then 1 else 0
  "#{window.ig.utils.formatNumber it * 100, decimals}&nbsp;%"

container = d3.select ig.containers.base
mapElement = container.append \div
  ..attr \class \map

map = L.map do
  * mapElement.node!
  * minZoom: 7
    maxZoom: 12
    zoom: 7
    center: [49.78, 15.5]
    maxBounds: [[48.3, 11.6], [51.3, 19.1]]

baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    attribution: 'CC BY-NC-SA <a href="http://rozhlas.cz">Rozhlas.cz</a>. Data <a href="https://www.czso.cz/" target="_blank">ČSÚ</a>, mapová data &copy; <a target="_blank" href="http://osm.org">OpenStreetMap</a>, podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l2/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.8

map
  ..addLayer baseLayer
  ..addLayer labelLayer

markerColorScale = d3.scale.linear!
  ..domain [0 0.25 0.5 0.75 1]
  ..range ['rgb(215,25,28)','rgb(253,174,97)','rgb(255,255,191)','rgb(171,217,233)','rgb(44,123,182)']
data.forEach (datum) ->
  color = markerColorScale datum.ratio
  radius = 7
  icon = L.divIcon do
    html: "<div style='background-color: #color;line-height:#{radius}px'></div>"
    iconSize: [radius + 10, radius + 10]
  marker = L.marker datum.latLng, {icon}
    ..addTo map
    ..on \click -> infobar.display datum

infobar = new ig.InfoBar container
geocoder = new ig.Geocoder mapElement.node!
  ..on \latLng (latlng) ->
    map.setView latlng, 12

legend = mapElement.append \div
  ..attr \class \legend
  ..append \ul
    ..selectAll \li .data markerColorScale.range!reverse! .enter!append \li
      ..style \background-color -> it
  ..append \span
    ..attr \class \popisky
    ..append \span
      ..html "většinou vhodné ke koupání"
    ..append \span
      ..html "často nevhodné"
