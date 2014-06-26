class Main

  ################# VENTA MAYORISTA #################

  #Este metodo es llamado una vez al día
  def Main.wholesale_process
    Rails.logger.info("***************** INICIO WHOLESALE PROCESS ******************")
    Crm.login
    Order.not_delivered.ready_to_deliver.each do |order|
      out_of_stock = false
      customer_id = order.customer_id
      customer = Crm.get_customer(order.address_id)

      order.product_orders.each do |product_order|
        sku = product_order.sku
        stock = warehouse.get_total_stock(sku)
        requested_amount = product_order.amount.to_i
        product = Product.find_by(sku: sku)
        next if product.blank?

        if stock > requested_amount
          available_amount = stock - Reservation.not_reserved_amount_for_customer(sku, customer_id)
          if available_amount > requested_amount

            address = customer.full_address
            price = product.current_price.to_i
            begin
              warehouse.dispatch_stock!(sku, address, price, order.order_id)
            rescue => e
              Rails.logger.error($!.message)
            end

	          Sprees.actualizarStock(sku)

          else
            out_of_stock = true
          end
        else
          out_of_stock = true
          warehouse.ask_for_product(sku, requested_amount - stock)
        end
      end

      order.update(delivered_at: Time.now, success: !out_of_stock)

      # enviar informacion a data-warehouse

      address = customer.full_address

      DataWarehouse::Order.create(customer_id: customer_id, order_id: order.order_id, address: address, success: !out_of_stock, delivered_at: Time.now, date_delivery: order.date_delivery, entered_at: order.entered_at)

      # Ejemplo para enviar a data-warehouse:
      # Crear un modelo dentro de app/models/data_warehouse/model.rb (cambiar model.rb por el modelo)
      # Crear los fields necesarios (ver ejemplo app/models/data_warehouse/order.rb)
      # IMPORTANTE: Como esta en mongo, no es necesario correr migraciones, solo definir los fields ahi mismo
      # Aquí en esta zona del codigo poner (de nuevo, cambiar Model por lo que se haya creado):
      # DataWarehouse::Model.create(field1: contenido, field2: contenido, ...)
      # ASI YA SE ESTA ENVIANDO INFORMACION AL Data Warehouse
    end
    Crm.logout
    Rails.logger.info("***************** FIN WHOLESALE PROCESS ******************")
  end

  def Main.repeated_cron_jobs
    Rails.logger.info("===============Iniciando cron jobs comunes===============")
    fetch_orders
    fetch_reservations
    fetch_sales
    clean_reception_depot
    activate_sales
    Rails.logger.info("===============Finalizados cron jobs comunes===============")
  end


  def Main.activate_sales
    Rails.logger.info("===============Activando Ofertas===============")
    Sale.active.without_tws.each do |sale|
      sale.activate
    end
    Rails.logger.info("===============FIN Activando Ofertas===============")
  end

  # CADA 10 minutos
  def Main.fetch_orders
    Rails.logger.info("===============Fetching Pedidos===============")
    Order.check_new_orders
    Rails.logger.info("===============Fin Fetching pedidos===============")
  end

  # Cada 10 minutos
  def Main.fetch_reservations
    Rails.logger.info("===============Cargando reservas===============")
    Reservation.load
    Rails.logger.info("===============FIN Cargando reservas===============")
  end

  # Cada 12 horas
  def Main.fetch_prices
    Rails.logger.info("===============Cargando precios===============")
    Product.fetch_prices
    Rails.logger.info("===============FIN Cargando precios===============")
  end

  def Main.warehouse
    @@warehouse ||= Warehouse.new
  end

  # Cada 10 minutos
  def Main.fetch_sales
    Rails.logger.info("===============CARGANDO OFERTAS DE COLA===============")
    Sale.read_msg
    Rails.logger.info("===============FIN CARGANDO OFERTAS DE COLA===============")
  end

  def Main.clean_reception_depot
    Rails.logger.info("===============LIMPIANDO BODEGAS DE RECEPCION===============")
    warehouse.clean_depots
    Rails.logger.info("===============FIN LIMPINANDO BODEGAS DE RECEPCION Y PULMON===============")
  end


end
