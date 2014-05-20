# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/




$ ->
  $("#warehouses").highcharts
    chart:
      type: "bar"
    title:
      text: "Elementos en bodega"
    xAxis:
      categories: gon.depots.map (depot) -> depot.type
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
          name: "No atrasados"
          y: gon.notDelayedOrders
          sliced: true
          selected: true
        }
      ]
    ]
