class Warehouse
  include ActiveModel::Model

  STOCKS_URL = "http://bodega-integracion-2014.herokuapp.com"

  attr_accessor :depots

  def depots
    @depots ||= load_depots
  end

  def depots!
    @depots = load_depots
  end

  def get_total_stock(sku)
    300
  end

  ##################### SYSTEM METHODS #####################
  def Warehouse.get_json_response(path, data, method, auth_string)
    url = URI.join(STOCKS_URL, path)
    if method == "GET"
      url.query = URI.encode_www_form(data)
      req = Net::HTTP::Get.new(url.request_uri)
    elsif method == "POST"
      req = Net::HTTP::Post.new(url.request_uri)
      req.set_form_data data
    elsif method == "DELETE"
      req = Net::HTTP::Delete.new(url.request_uri)
      req.set_form_data data
    end
    Rails.logger.debug("[DEBUG] Authorization: " + get_authorization_string(auth_string))
    req.add_field("Authorization", get_authorization_string(auth_string))
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    JSON.parse(res.body, symbolize_names: true)
  end

  def move_stock(product_id, destination_depot)
    method = "POST"
    string = method + product_id + destination_depot
    path = "/moveStock"
    data = { "productoId" => product_id, "almacenId" => destination_depot }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end

  def move_stock_to_warehouse(product_id, destination_depot)
    method = "POST"
    string = method + product_id + destination_depot
    path = "/moveStockBodega"
    data = { "productoId" => product_id, "almacenId" => destination_depot }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end

  def dispatch_stock(product_id, address, price, order_id)
    method = "DELETE"
    string = method + product_id + address + price.to_s + order_id
    path = "/stock"
    data = { "productoId" => product_id, "direccion" => address, "precio" => price, "pedidoId" => order_id }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end
  
  def stock_sku (sku)
    stock = 0
    depots.each do |depot|
      stock = stock + depot.get_stock(sku).count
    end
    stock
  end

  private

  def Warehouse.get_request_hash(string)
    # strict_encode64
    Base64.strict_encode64("#{OpenSSL::HMAC.digest('sha1', Settings.stocks_management_system.private_key, string)}")
  end

  def Warehouse.get_authorization_string(string)
    hash = get_request_hash(string)
    "UC #{Settings.stocks_management_system.public_key}:#{hash}"
  end

  def load_depots
    method = "GET"
    string = method
    path = "/almacenes"
    data = {}
    json_depots = Warehouse.get_json_response(path, data, method, string)
    response = []
    json_depots.each do |json_depot|
      response << Depot.parse_from_json(json_depot)
    end
    response
  end


end
