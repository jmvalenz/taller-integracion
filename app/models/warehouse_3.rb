class Warehouse_3

  include HTTParty
    base_uri 'http://integra3.ing.puc.cl/api/'
    default_params output: 'json'
    format :json

  USER = "grupo5"
  PASS = "grupo5"

  def get_sku!(sku, amount, depot_id)
    get_sku(sku, amount, depot_id)
  end


  def get_sku(sku, amount, depot_id)
    response = self.class.post("/pedirProducto", query: {SKU: sku, cantidad: amount},
    body: { usuario: USER, password: PASS, almacen_id: depot_id})
    json = JSON.parse(response.body, symbolize_names: true).first
    if json[:SKU]
      json[:cantidad]
    else
      0
    end
  end

end