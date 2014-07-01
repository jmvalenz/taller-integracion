# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


window.initialize = ->
  map = undefined
  bounds = new google.maps.LatLngBounds()
  mapOptions = mapTypeId: "roadmap"

  last_five_orders = gon.lastFiveOrders
  # Display a map on the page
  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)
  map.setTilt 45

  # Multiple Markers
  markers = last_five_orders
  # Info Window Content
  infoWindowContent = []
  i = 0
  while i < last_five_orders.length
    infoWindowContent.push ["<div class=\"info_content\">" + "<h3>Orden</h3>" + "<p> Cliente: " + last_five_orders[i][0] + "</p>" + "</div>"]
    i++
  # Display multiple markers on a map
  infoWindow = new google.maps.InfoWindow()
  marker = undefined
  i = undefined

  # Loop through our array of markers & place each one on the map
  i = 0
  while i < markers.length
    position = new google.maps.LatLng(markers[i][1], markers[i][2])
    bounds.extend position
    marker = new google.maps.Marker(
      position: position
      map: map
      title: markers[i][0]
    )

    # Allow each marker to have an info window
    google.maps.event.addListener marker, "click", ((marker, i) ->
      ->
        infoWindow.setContent infoWindowContent[i][0]
        infoWindow.open map, marker
        return
    )(marker, i)

    # Automatically center the map fitting all markers on the screen
    map.fitBounds bounds
    i++

  # # Override our map zoom level once our fitBounds function runs (Make sure it only runs once)
  # boundsListener = google.maps.event.addListener((map), "bounds_changed", (event) ->
  #   @setZoom 14
  #   google.maps.event.removeListener boundsListener
  #   return
  # )
  return

$ ->
  script = document.createElement('script');
  script.src = "//maps.googleapis.com/maps/api/js?sensor=false&callback=initialize";
  document.body.appendChild(script);




  $("#warehouses").highcharts
    chart:
      type: "bar"
    title:
      text: "Elementos en bodega"
    xAxis:
      categories: gon.depots.map (depot) -> depot.type_to_s
    yAxis:
      title:
        text: "Elementos"

    series: [
      {
        name: "Porcentaje Utilizado"
        data: gon.depots.map (depot) -> parseFloat((100 * depot.used_space / depot.total_space).toFixed(2))
      }
    ]




  Highcharts.getOptions().colors = Highcharts.map(Highcharts.getOptions().colors, (color) ->
    radialGradient:
      cx: 0.5
      cy: 0.3
      r: 0.7

    stops: [
      [
        0
        color
      ]
      [ # darken
        1
        Highcharts.Color(color).brighten(-0.3).get("rgb")
      ]
    ]
  )

  # Build the chart
  $("#orders").highcharts
    chart:
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false

    title:
      text: "Estado de Pedidos"

    tooltip:
      pointFormat: "{series.name}: <b>{point.percentage:.1f}%</b>"

    plotOptions:
      pie:
        allowPointSelect: true
        cursor: "pointer"
        dataLabels:
          enabled: false
          format: "<b>{point.name}</b>: {point.percentage:.1f} %"
          style:
            color: (Highcharts.theme and Highcharts.theme.contrastTextColor) or "black"

          connectorColor: "silver"

    series: [
      type: "pie"
      name: "Pedidos"
      data: [
        [
          "Atrasados"
          gon.delayedOrders
        ]
        {
          name: "A tiempo"
          y: gon.notDelayedOrders
          sliced: true
          selected: true
        }
      ]
    ]
