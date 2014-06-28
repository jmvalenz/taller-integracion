class Main

  ################# VENTA MAYORISTA #################

  #Este metodo es llamado una vez al día
  def Main.wholesale_process
    Rails.logger.info("***************** INICIO WHOLESALE PROCESS ******************")
    Order.not_delivered.ready_to_deliver.each do |order|
      order.process
    end
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
