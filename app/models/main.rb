class Main

  ################# VENTA MAYORISTA #################

  #Este metodo es llamado una vez al día
  def Main.wholesale_process
    # Cargamos todos los pedidos (orders) que tengan deliver_date <= hoy & not_delivered
    Order.not_delivered.ready_to_deliver.each do |order|
      # PRIMERO REVISAR SI HAY STOCK PARA CADA SUB PEDIDO
      # RECHAZAR SI NO HAY STOCK PARA CUALQUIERA
      stocks = {}
      reserved = {}
      order.product_orders.each do |product_order|
        stocks[product_order.sku] = warehouse.get_total_stock(product_order.sku)
        reserved[product_order.sku] = 0
      end
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
    
  end

  def Main.fetch_orders
    Order.check_new_orders
  end

  def Main.warehouse
    @@warehouse ||= Warehouse.new
  end

end
