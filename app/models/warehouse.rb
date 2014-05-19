class Warehouse
  include ActiveModel::Model

  STOCKS_URL = "http://bodega-integracion-2014.herokuapp.com"

  attr_accessor :depots, :delivery_depot

  def depots
    @depots ||= load_depots
  end

  def depots!
    @depots = load_depots
  end

  def ask_for_product(sku, amount)
    # Buscar bodega por bodega: tiene una moneita
    amount_left = amount
    
    w9 = Warehouse_9.new
    amount_left -= w9.get_sku!(sku, amount, reception_depot._id)

    amount_left
  end

  def delivery_depot
    unless @delivery_depot
      depots.each do |depot|
        if depot.type == "delivery"
          @delivery_depot = depot
          return @delivery_depot
        end
      end
    end
    @delivery_depot
  end

  def reception_depot
    unless @reception_depot
      depots.each do |depot|
        if depot.type == "reception"
          @reception_depot = depot
          return @reception_depot
        end
      end
    end
    @reception_depot
  end

  def get_total_stock(sku)
    stock = 0
    sync = Mutex.new
    threads = []

    depots.each do |depot|
      threads << Thread.new do
        depot.get_skus_with_stock.each do |item|
          if item[:_id] == sku
            sync.synchronize do
              stock += item[:total]
            end
            break
          end
        end
      end
    end

    threads.each do |t|
      t.join
    end

    stock
  end

  def move_products_to_warehouse!(sku, quantity, destination_depot)
    # Mover elementos a almacen de despacho y enviarlos a la bodega de destino
    products = []
    products_on_delivery_depot = []
    sync = Mutex.new
    threads = []

    # Obtengo los productos para un sku dado
    depots.each do |depot|
      if depot.type != "delivery"
        threads << Thread.new do
          sync.synchronize do
            products << depot.get_stock(sku, quantity)
          end
        end
      end
    end

    threads << Thread.new do
      products_on_delivery_depot << delivery_depot.get_stock(sku, quantity)
    end
    

    threads.each do |t|
      t.join
    end

    products.flatten!
    products_on_delivery_depot.flatten!

    sync = Mutex.new
    threads = []

    # Ahora muevo los primeros quantity productos (1º los que ya estan en despacho y de ahi el resto)
    if (products.length + products_on_delivery_depot.length) >= quantity
      quantity_left = quantity - products_on_delivery_depot[0..(quantity - 1)].length
      products_on_delivery_depot[0..(quantity - 1)].each do |product|
        threads << Thread.new do
          move_stock_to_warehouse(product[:_id], destination_depot)
        end
      end
      products[0..(quantity_left - 1)].each do |product|
        threads << Thread.new do
          move_stock(product[:_id], delivery_depot._id)
          move_stock_to_warehouse(product[:_id], destination_depot) 
        end
      end
      
      threads.each do |t|
        t.join
      end
      true
    else
      false
    end
  end

  ##################### SYSTEM METHODS #####################
  def Warehouse.get_json_response(path, data, method, auth_string)
    url = URI.join(STOCKS_URL, path)
    case method
    when "GET"
      url.query = URI.encode_www_form(data)
      req = Net::HTTP::Get.new(url.request_uri)
    when "POST"
      req = Net::HTTP::Post.new(url.request_uri)
      req.set_form_data data
    when "DELETE"
      req = Net::HTTP::Delete.new(url.request_uri)
      req.set_form_data data
    end
    req.add_field("Authorization", get_authorization_string(auth_string))
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
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
