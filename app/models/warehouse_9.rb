class Warehouse_9
  
  include HTTParty
    base_uri 'http://integra9.ing.puc.cl/api/'
    default_params output: 'json'
    format :json

  USER = "grupo5"
  PASS = "deB96hkU"

  def get_sku!(sku, amount, depot_id)
    new_amount = [get_available(sku), amount].min
    if new_amount > 0
      get_sku(sku, new_amount, depot_id)
    else
      0
    end
  end
  def get_sku(sku, amount, depot_id)
    response = self.class.post("/pedirProducto/#{USER}/#{PASS}/#{sku}", body: { almacenId: depot_id, cantidad: amount })
    json = JSON.parse(response.body, symbolize_names: true)
    if json[:status] == 200
      json[:response][:cantidad]
    else
      0
    end
  end

  def get_available(sku)
    response = self.class.get("/disponibles/#{USER}/#{PASS}/#{sku}")
    json = JSON.parse(response.body, symbolize_names: true)
    if json[:status] == 200
      json[:response][:cantidad]
    else
      0
    end
  end

end