class Depot
  include ActiveModel::Model

  attr_accessor :_id, :total_space, :used_space, :type

  # Crea un objeto Depot a partir del contenido de un objeto json
  def Depot.parse_from_json(json)
    if json[:pulmon]
      type = "pulmon"
    elsif json[:despacho]
      type = "delivery"
    elsif json[:recepcion]
      type = "reception"
    else
      type = "other" # libre disposición, productos dañados y devoluciones
    end
    new({
      _id: json[:_id],
      total_space: json[:totalSpace],
      used_space: json[:usedSpace],
      type: type
    })
  end

  def available_space
    total_space - used_space
  end

  def skus_with_stock
    @skus_with_stock ||= get_skus_with_stock
  end

  def get_skus_with_stock
    method = "GET"
    string = method + self._id
    path = "/skusWithStock"
    data = { "almacenId" => self._id }
    Warehouse.get_json_response(path, data, method, string)
  end

  def get_stock(sku, limit = nil)
    method = "GET"
    string = method + self._id + sku
    path = "/stock"
    data = { "almacenId" => self._id, "sku" => sku }
    data["limit"] = limit if limit
    Warehouse.get_json_response(path, data, method, string)
  end



end
