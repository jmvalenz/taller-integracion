class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_orders, dependent: :destroy

  default_scope { order(entered_at: :asc) }
  scope :delivered, -> { where.not(delivered_at: nil) }
  scope :not_delivered, -> { where(delivered_at: nil) }
  scope :ready_to_deliver, -> { where('date_delivery <= ?', Date.today) }
  scope :not_ready_to_deliver, -> { where('date_delivery > ?', Date.today) }

  def Order.load(file)
    name = File.basename(file.path)
    doc = Nokogiri::XML(file)

    orders = doc.at_xpath("//Pedidos")

    date = orders.attr("fecha")
    time = orders.attr("hora")
    order_info = {
      order_id: name[/pedido_(.*?)\.xml/, 1],
      customer_id: orders.at_xpath("rut").content.strip,
      address_id: orders.at_xpath("direccionId").content.strip,
      entered_at: DateTime.parse(date + " " + time),
      date_delivery: orders.at_xpath("fecha").content.strip
    }
    order = Order.create(order_info)
    order.load_product_orders(orders)
	end

	def load_product_orders(doc)
    doc.xpath("Pedido").each do |suborder|
      self.product_orders.create({
        sku: suborder.at_xpath("sku").content.strip,
        amount: suborder.at_xpath("cantidad").content.strip,
        order_unit: suborder.at_xpath("cantidad").attr("unidad").strip
      })
    end
  end

  def Order.check_new_orders
    conn = FunSftp::SFTPClient.new(Settings.orders_sftp_system.url, Settings.orders_sftp_system.user, Settings.orders_sftp_system.password)
    conn.chdir "Pedidos"

    existing_orders = Order.select(:order_id).map{|id| "pedido_#{id.order_id}.xml" }
    entries = conn.entries(".", true) - [".", ".."]
    new_orders = entries - existing_orders # Esto elimina las llamadas a base de datos innecesarias

    new_orders.each do |filename|
      order_id = filename[/pedido_(.*?).xml/, 1]
      begin
        conn.download!(filename, Rails.root.join("tmp", filename))
      rescue
      end
      f = File.open(Rails.root.join("tmp", filename))
      Order.load(f)
      f.close
      File.delete(f)
    end
  end

  def process
    Crm.login
    crm_customer = Crm.get_customer(address_id)
    success = true

    Rails.logger.debug("*******__ Iniciando proceso de orden #{order_id} __********")
    product_orders.each do |product_order|

      general_success = product_order.process(crm_customer)

      # Si llega a haber una que falle, todas fallan
      if success
        success = general_success
      end
    end

    update(delivered_at: Time.now, success: success)

    # enviar informacion a data-warehouse

    address = crm_customer.full_address

    DataWarehouse::Order.create(customer_id: customer_id, order_id: order_id, address: address, success: !out_of_stock, delivered_at: Time.now, date_delivery: date_delivery, entered_at: entered_at)

    Rails.logger.debug("*******__ FIN proceso de orden #{order_id} __********")

    Crm.logout
  end

end