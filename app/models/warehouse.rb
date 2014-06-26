class Warehouse
  include ActiveModel::Model
  require 'rubygems'
  require 'net/ssh'
  require 'net/scp'
  require 'csv'
  require 'date'

  STOCKS_URL = "http://bodega-integracion-2014.herokuapp.com"
  HOST = 'integra5.ing.puc.cl'
  USER = 'passenger'
  PASS = '1234567890'

  BULK_LIMIT = 50

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

    warehouses = []
    warehouses << Warehouse_9.new
    warehouses << Warehouse_4.new
    warehouses << Warehouse_3.new

    warehouses.shuffle!

    warehouses.each do |wh|
      break if amount_left == 0
      begin
        amount_left -= wh.get_sku!(sku, amount_left, reception_depot._id)
      rescue
        Rails.logger.warn("Bodega #{wh.class} con problemas")
      end
    end

    # Retorno cuanto me faltó por pedir
    amount_left
  end

  def delivery_depot
    depots.each do |depot|
      if depot.type == "delivery"
        @delivery_depot = depot
        return @delivery_depot
      end
    end
    @delivery_depot
  end

  def reception_depot
    depots.each do |depot|
      if depot.type == "reception"
        @reception_depot = depot
        return @reception_depot
      end
    end
    @reception_depot
  end

  def pulmon_depot
    depots.each do |depot|
      if depot.type == "pulmon"
        @pulmon_depot = depot
        return @pulmon_depot
      end
    end
    @pulmon_depot
  end

  def other_depots
    @other_depots = []
    depots.each do |depot|
      if depot.type == "other"
        @other_depots << depot
      end
    end
    @other_depots
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

    # threads << Thread.new do
    #   products_on_delivery_depot << delivery_depot.get_stock(sku, quantity)
    # end


    threads.each do |t|
      t.join
    end

    products.flatten!
    products_on_delivery_depot.flatten!

    sync = Mutex.new
    threads = []

    # Ahora muevo los primeros quantity productos (1º los que ya estan en despacho y de ahi el resto)
    ### FALTA: Revisar si se pueden mover cosas a Delivery!! Si está llena no se mueve nada y queda la cagá
    products_moved = 0
    available_products = products.length + products_on_delivery_depot.length
    Rails.logger.info("En este momento hay #{available_products} productos de #{sku} en la bodega")
    products_to_move = available_products > quantity ? quantity : available_products
    Rails.logger.info("De los cuales pretendo enviar #{products_to_move}")
    quantity_left = quantity - products_on_delivery_depot[0..(quantity - 1)].length

    products_on_delivery_depot[0..(quantity - 1)].each do |product|
      threads << Thread.new do
        moved_json = move_stock_to_warehouse(product[:_id], destination_depot)
        unless !!moved_json[:error]
          products_moved += 1
        else
          Rails.logged.warn("Hubo un problema al enviar un producto a otra bodega")
        end
      end
    end
    threads.each do |t|
      t.join
    end

    threads = []
    products[0..(quantity_left - 1)].each do |product|
      threads << Thread.new do
        moved_json = move_stock(product[:_id], delivery_depot._id)
        unless !!moved_json[:error]
          moved_json = move_stock_to_warehouse(product[:_id], destination_depot)
          unless !!moved_json[:error]
            products_moved += 1
          else
            Rails.logged.warn("Hubo un problema al enviar un producto a otra bodega")
          end
        else
          Rails.logged.warn("Hubo un problema al mover un producto a bodega de despacho")
        end
      end

      threads.each do |t|
        t.join
      end
    end
    products_moved
  end

  def clean_depots
    total_items_moved = 1
    while total_items_moved != 0
      total_items_moved = 0
      total_items_moved += clean_reception_depot
      total_items_moved += clean_pulmon_depot
    end
  end

  def clean_reception_depot
    items_moved = 0
    Rails.logger.debug("Loading depots")
    depots!
    reception_items = reception_depot.used_space
    available_space = other_depots.map(&:available_space).sum
    unless reception_items == 0 || available_space == 0
      Rails.logger.debug("Hay productos en recepcion y espacio disponible en bodegas")
      while (stock = reception_depot.get_skus_with_stock) && stock.present?
        available_depot = other_depots.sort{ |a, b| b.available_space <=> a.available_space }.first
        Rails.logger.debug("Espacio disponible en bodega #{available_depot._id}: #{available_depot.available_space}")
        break if available_depot.available_space <= 0
        bulk_moved = move_bulk_products(reception_depot, available_depot, stock.first[:_id], available_depot.available_space)
        Rails.logger.debug("Se movieron #{bulk_moved} productos a bodega #{available_depot._id}")
        items_moved += bulk_moved
        depots!
      end
    else
      Rails.logger.debug("No hay espacio en bodegas o no hay productos en recepcion")
    end
    items_moved
  end

  def clean_pulmon_depot
    items_moved = 0
    Rails.logger.debug("Loading depots")
    depots!
    pulmon_items = pulmon_depot.used_space
    available_space = reception_depot.available_space
    unless pulmon_items == 0 || available_space == 0
      Rails.logger.debug("Hay productos en pulmon y espacio disponible en recepcion")
      while (stock = pulmon_depot.get_skus_with_stock) && stock.present?
        Rails.logger.debug("Espacio disponible en bodega de recepcion: #{reception_depot.available_space}")
        break if reception_depot.available_space <= 0
        bulk_moved = move_bulk_products(pulmon_depot, reception_depot, stock.first[:_id], reception_depot.available_space)
        Rails.logger.debug("Se movieron #{bulk_moved} productos a bodega de recepcion")
        items_moved += bulk_moved
        depots!
      end
    else
      Rails.logger.debug("No hay espacio en recepcion o no hay productos en pulmon")
    end
    items_moved
  end

  def clean_delivery_depot
    items_moved = 0
    Rails.logger.debug("Limpiando Almacen de despacho")
    depots!
    delivery_items = delivery_depot.used_space
    available_space = other_depots.map(&:available_space).sum
    unless delivery_items == 0 || available_space == 0
      Rails.logger.debug("Hay productos en despacho y espacio disponible en bodegas")
      while (stock = delivery_depot.get_skus_with_stock) && stock.present?
        available_depot = other_depots.sort{ |a, b| b.available_space <=> a.available_space }.first
        Rails.logger.debug("Espacio disponible en bodega #{available_depot._id}: #{available_depot.available_space}")
        break if available_depot.available_space <= 0
        bulk_moved = move_bulk_products(delivery_depot, available_depot, stock.first[:_id], available_depot.available_space)
        Rails.logger.debug("Se movieron #{bulk_moved} productos a bodega #{available_depot._id}")
        items_moved += bulk_moved
        depots!
      end
    else
      Rails.logger.debug("No hay espacio en bodegas o no hay productos en delivery")
    end
    items_moved
  end

  def move_bulk_products(depot_from, depot_to, sku, limit = nil)
    sync = Mutex.new
    threads = []
    # El límite de threads es el menor entre el limite y BULK_LIMIT (para testear con pocos threads)
    max_limit = limit < BULK_LIMIT ? limit : BULK_LIMIT
    products = depot_from.get_stock(sku, max_limit)
    moved_products = products.count
    # Obtengo los productos para un sku dado
    products.each do |product|
      threads << Thread.new do
        begin
          json_stock = move_stock(product[:_id], depot_to._id)
          if !!json_stock[:error]
            sync.synchronize do
              moved_products -= 1
            end
          end
        rescue
          sync.synchronize do
            moved_products -= 1
          end
        end
      end
    end

    threads.each do |t|
      t.join
    end

    moved_products
  end

  def dispatch_stock!(product_id, address, price, order_id)
    # Si el producto ya está en despacho, no pasa nada con este método, así que no es problema
    move_stock(product_id, delivery_depot._id)
    dispatch_stock(product_id, address, price, order_id)
  end

  def empty_delivery_depot
    sync = Mutex.new
    threads = []
    products = delivery_depot.get_skus_with_stock

    products.each do |product|
      product_instances = delivery_depot.get_stock(product[:_id])
      product_instances.each do |product_instance|
        threads << Thread.new do
          begin
            Rails.logger.debug("Se despacha #{product_instance[:_id]}")
            dispatch_stock(product_instance[:_id], "Vicuña Mackenna Poniente 4860, Stgo, Macul, Chile", "0", "EMPTY_DEPOT")
          rescue
            Rails.logger.debug("Error de conexión")
          end
        end
      end
    end

    threads.each do |t|
      t.join
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
    begin
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
      JSON.parse(res.body, symbolize_names: true)
    rescue
      Rails.logger.warn("Error al comunicarse con Sistema de Bodegas")
      {error: "Error al comunicarse con Sistema de Bodegas"}
    end
  end

  def move_stock(product_id, destination_depot)
    method = "POST"
    string = method + product_id.to_s + destination_depot
    path = "/moveStock"
    data = { "productoId" => product_id, "almacenId" => destination_depot }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end

  def move_stock_to_warehouse(product_id, destination_depot)
    method = "POST"
    string = method + product_id.to_s + destination_depot
    path = "/moveStockBodega"
    data = { "productoId" => product_id, "almacenId" => destination_depot }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end

  def dispatch_stock(product_id, address, price, order_id)
    method = "DELETE"
    string = method + product_id.to_s + address + price.to_s + order_id.to_s
    path = "/stock"
    data = { "productoId" => product_id, "direccion" => address, "precio" => price, "pedidoId" => order_id }
    json_depots = Warehouse.get_json_response(path, data, method, string)
  end

  def reload_prices
    Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
      result = ssh.exec!("cd access2csv && java -jar access2csv.jar ~/Dropbox/Grupo5/DBPrecios.accdb")
      puts result
    end
  end

  def download_csv
    Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
      result = ssh.scp.download! "access2csv/Pricing.csv", "pricing/Pricing.csv"
      puts result
    end
  end

  def read_csv
    text=File.open('pricing/Pricing.csv').read
    fecha = 0
    CSV.parse(text, headers: true) do |row|
      f_act= Date.strptime(row[3].strip, "%m/%d/%Y")
      f_vig= Date.strptime(row[4].strip, "%m/%d/%Y")
      fecha = f_vig
      puts row
     end
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
