Public.SubjectTrajectoryComponent = Ember.Component.extend(
  tagName: "svg"
  attributeBindings: "width height".w()
  margin:
    top: 20
    right: 20
    bottom: 30
    left: 40


  w: (->
    @get("width") - @get("margin.left") - @get("margin.right")
  ).property("width")


  h: (->
    @get("height") - @get("margin.top") - @get("margin.bottom")
  ).property("height")

  transformG: (->
    "translate(" + @get("margin.left") + "," + @get("margin.top") + ")"
  ).property()

  transformX: (->
    "translate(0," + @get("h") + ")"
  ).property("h")

  draw: ->
    formatPercent = d3.format(".0%")
    width = @get("w")
    height = @get("h")
    data = @get("data")
    svg = d3.select("#" + @get("elementId"))

    x = d3.scale.ordinal().rangeRoundBands([
      0
      width
    ], 0.1)

    y = d3.scale.linear().range([
      height
      0
    ])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left").ticks(5).tickFormat(formatPercent)

    x.domain data.map((d) ->
      d.letter
    )

    y.domain [
      0
      d3.max(data, (d) ->
        d.frequency
      )
    ]

    svg.select(".axis.x").call xAxis
    svg.select(".axis.y").call yAxis
    
    svg.select(".rects").selectAll("rect").data(data).enter().append("rect").attr("class", "bar").attr("x", (d) ->
      x d.letter
    ).attr("width", x.rangeBand()).attr("y", (d) ->
      y d.frequency
    ).attr "height", (d) ->
      height - y(d.frequency)

    return

  didInsertElement: ->
    @draw()
    return
)