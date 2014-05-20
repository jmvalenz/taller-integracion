class Main

  ################# VENTA MAYORISTA #################

  #Este metodo es llamado una vez al día
  def Main.wholesale_process
    Crm.login
    Order.not_delivered.ready_to_deliver.each do |order|
      broken = false
      customer_id = order.customer_id

      order.product_orders.each do |product_order|
        sku = product_order.sku
        stock = warehouse.get_total_stock(sku)
        requested_amount = product_order.amount.to_i
        product = Product.find_by(sku: sku)
        next if product.blank?
        if stock > requested_amount
          available_amount = stock - Reservation.not_reserved_amount_for_customer(sku, customer_id)
          if available_amount > requested_amount
            customer = Crm.get_customer(order.address_id)
            address = customer.full_address
            price = product.actual_price.to_i
            # warehouse.dispatch_stock(sku, address, price, order.order_id)
          else
            broken = true
          end
        else
          broken = true
          # warehouse.ask_for_product(sku, requested_amount - stock)
        end
      end

      # order.update(delivered_at: Time.now, success: !broken)

      # enviar informacion a data-warehouse
    end
    Crm.logout
  end

  # CADA 10 minutos
  def Main.fetch_orders
    Order.check_new_orders
  end

  # Cada X minutos
  def Main.fetch_reservations
    Reservation.load
  end

  # Cada X minutos
  def Main.fetch_prices
    Product.fetch_prices
  end

  def Main.warehouse
    @@warehouse ||= Warehouse.new
  end

end
