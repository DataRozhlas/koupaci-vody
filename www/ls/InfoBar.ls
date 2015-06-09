class ig.InfoBar
  (@parentElement) ->
    @element = @parentElement.append \div
      ..attr \class \info-bar
    @header = @element.append \h3
      ..html "Lipno"
    @closeBtn = @element.append \a
      ..attr \class \close-button
      ..attr \href \#
      ..html "×"
      ..on \click @~hide

  display: (data) ->
    @header.html data.title
    @parentElement.classed \info-bar-active yes

  hide: ->
    @parentElement.classed \info-bar-active no
