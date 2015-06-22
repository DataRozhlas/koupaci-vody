monthMillis = 30 * 86400 * 1e3
day = 86400 * 1e3
months =
  * name: "črv"
    start: 0 * day
  * name: "čvc"
    start: 30 * day
  * name: "srp"
    start: 61 * day
  * name: "zář"
    start: 92 * day
  * name: "říj"
    start: 122 * day
class ig.InfoBar
  (@parentElement) ->
    @graphTip = new ig.GraphTip @parentElement
    @element = @parentElement.append \div
      ..attr \class \info-bar
    @header = @element.append \h3
      ..html "Lipno"
    @closeBtn = @element.append \a
      ..attr \class \close-button
      ..attr \href \#
      ..html "×"
      ..on \click @~hide
    @graphsContainer = @element.append \div
      ..attr \class \graphs-container
    @graphsSlider = @graphsContainer.append \div
      ..attr \class \graphs-slider
    @color = d3.scale.ordinal!
      ..domain [5 4 3 2 1]
      ..range ['rgb(215,25,28)','rgb(253,174,97)','rgb(254,224,144)','rgb(171,217,233)','rgb(44,123,182)']
    @scale = d3.scale.linear!
      ..domain [0 122 * 86400 * 1e3]
      ..range [0 148]
    @voronoi = d3.geom.voronoi!
      ..x ~> @scale it.relativeTime
      ..y ~> 2
      ..clipExtent [[0, 0], [150, 70]]

  display: (data) ->
    @header.html data.title
    @parentElement.classed \info-bar-active yes
    @graphsSlider.html ''
    @graphsSlider.style \width "#{data.years.length * 170 + 30}px"
    @graphsContainer.node!scrollLeft = data.years.length * 160
    # voronoiPolygons = voronoi dataPoints
    #   .filter -> it
    showTip = @~showTip

    @graphsSlider.selectAll \svg.graph .data data.years .enter!append \svg
      ..attr \class \graph
      ..attr \height 70
      ..attr \width 150
      ..append \g
        ..attr \class \boxes
        ..selectAll \rect .data (.evaluations) .enter!append \rect
          ..attr \x ~> (@scale it.relativeTime) - 2
          ..attr \y -> 30 - (6 - it.result) * 5
          ..attr \height -> (6 - it.result) * 5
          ..attr \width 5
          ..attr \fill ~> @color it.result
      ..append \g
        ..attr \transform "translate(0, 30)"
        ..attr \class \legend
        ..append \line
          ..attr \x2 148
        ..selectAll \line.tick .data months .enter!append \line
          ..attr \x1 (d, i) ~> @scale d.start
          ..attr \x2 (d, i) ~> @scale d.start
          ..attr \y2 5
        ..selectAll \text .data months.slice 0, 4 .enter!append \text
          ..text (.name)
          ..attr \x (d, i) ~> @scale (months[i].start + months[i+1].start) * 0.5
          ..attr \y 15
          ..attr \text-anchor \middle
        ..append \text
          ..attr \class \year
          ..attr \x 75
          ..attr \y 32
          ..attr \text-anchor \middle
          ..text -> it.year
      ..append \g
        ..attr \class \voronoi
        ..selectAll \path .data (~> @voronoi it.evaluations .filter -> it && it.length) .enter!append \path
          ..attr \d -> polygon it
          ..on \mouseover -> showTip it.point, @
          ..on \touchstart -> showTip it.point, @
          ..on \mouseout @graphTip~hide

  showTip: (point, element) ->
    {left:svgLeft, top} = ig.utils.offset element.parentNode.parentNode
    svgLeft -= @graphsContainer.node!scrollLeft
    pointLeft = @scale point.relativeTime
    @graphTip.display svgLeft + pointLeft, top, "Měření z #{toHumanDate point.date}:<br>
    Hodnocení #{point.result} – #{resultNames[point.result]}"
    # console.log it.point


  hide: ->
    @parentElement.classed \info-bar-active no
    @graphsSlider.html ''

polygon = ->
  "M#{it.join "L"}Z"

monthNames = <[ledna února března dubna května června července srpna září října listopadu prosince]>
resultNames = ["", "Voda vhodná ke koupání", "Voda vhodná ke koupání s mírně zhoršenými vlastnostmi", "Zhoršená jakost vody", "Voda nevhodná ke koupání", "Voda nebezpečná ke koupání – zákaz koupání"]
toHumanDate = (date) ->
  "#{date.getDate!}. #{monthNames[date.getMonth!]} #{date.getFullYear!}"

