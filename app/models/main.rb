class Main

  ################# VENTA MAYORISTA #################

  #Este metodo es llamado una vez al día
  def wholesale_process
    # Cargamos todos los pedidos (orders) que tengan deliver_date <= hoy & not_delivered
    
    # Para cada pedido hacer:
    # Order.where(:delivery_date.lte => Date.today, delivered: false).each do |order|
      # Revisar cada sub pedido
      # order.product_orders.each do |product_order|
        # Revisar stock para sku solicitado
        # warehouse.get_total_sku
        # Reviso reservas del usuario del pedido
        # Si no tiene reserva & no hay stock
          # se quiebra
          # enviar informacion a data-warehouse
          # ===FIN===
        # Si tiene reserva & no hay stock
          # se quiebra
          # se solicita a otra bodega
          # enviar informacion a data-warehouse
          # ===FIN===
        # ===SI HAY STOCK===
        # despachar
        # enviar informacion a data-warehouse
  end

  def fetch_orderd
    # Revisar FTP.
    # Si hay pedidos nuevos, ejecuto wholesale_process

  end

  def passes_validation

    return true

  end

  def wareohuse
    @@warehouse ||= Warehouse.new
  end

end
