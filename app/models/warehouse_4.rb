class Warehouse_4

  include HTTParty
    base_uri 'http://integra4.ing.puc.cl/api/'
    default_params output: 'json'
    format :json

  USER = "grupo5"
  PASS = "675af2de40aa875fb8877a7afa3a11e0989ae496"

  def get_sku!(sku, amount, depot_id)
    get_sku(sku, amount, depot_id)
  end


  def get_sku(sku, amount, depot_id)
    response = self.class.post("/pedirProducto", body: { usuario: USER, password: PASS, almacen_id: depot_id, SKU: sku, cantidad: amount})
    json = JSON.parse(response.body, symbolize_names: true)
    if json[:sku]
      json[:cantidad]
    else
      0
    end
  end

end