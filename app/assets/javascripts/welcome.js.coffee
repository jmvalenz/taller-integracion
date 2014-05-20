# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/




$ ->
  $("#test").highcharts
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

  return
