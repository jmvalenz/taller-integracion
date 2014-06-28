class ProductOrder < ActiveRecord::Base

  belongs_to :order

  def process(customer)
    Rails.logger.debug("********_ Iniciando proceso de pedido #{sku} por #{amount.to_i} unidades _**********")

    warehouse = Warehouse.new
    stock = warehouse.get_total_stock(sku)
    requested_amount = amount.to_i
    product = Product.find_by(sku: sku)
    sent_amount = 0
    return if product.blank?

    available_amount = stock - Reservation.not_reserved_amount_for_customer(sku, order.customer_id)
    available_amount = available_amount > 0 ? available_amount : 0

    # Si no hay stock, pido a otras bodegas lo que me falta
    if available_amount < requested_amount
      Rails.logger.info("** Pedido: #{sku}, orden #{order.order_id}. NO TENGO STOCK, pido a bodegas #{requested_amount - available_amount} unidades **")
      available_amount += warehouse.ask_for_product(sku, requested_amount - available_amount)
    end

    amount_to_send = available_amount < requested_amount ? available_amount : requested_amount

    address = customer.full_address
    price = product.current_price.to_i

    begin
      Rails.logger.info("********_ Inicio envío de #{sku} a cliente {order.customer_id}, #{amount_to_send} UNIDADES _**********")
      sent_amount = warehouse.dispatch_stock!(sku, amount_to_send, address, price, order.order_id)
      Rails.logger.info("********_ FIN envío de #{sku} a cliente {order.customer_id}, #{sent_amount} UNIDADES _**********")
    rescue => e
      Rails.logger.error("Hubo un error al enviar stock #{sku} a cliente #{order.customer_id}")
      Rails.logger.error($!.message)
    end

    out_of_stock = amount_to_send - sent_amount
    DataWarehouse::Dispatch.create(customer_id: order.customer_id, order_id: order.order_id, address: address, items_delivered: sent_amount, items_not_delivered: out_of_stock, delivered_at: Time.now, date_delivery: order.date_delivery, entered_at: order.entered_at)
    Sprees.actualizarStock(sku)

    Rails.logger.debug("********_ FIN proceso de pedido _**********")

    out_of_stock == 0
  end

end