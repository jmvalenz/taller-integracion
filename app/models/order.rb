class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_orders, dependent: :destroy


  def Order.load(file)
    Rails.logger.debug("ORDER: Creando orden")
    name = File.basename(file.path)
    doc = Nokogiri::XML(file)

    orders = doc.at_xpath("//Pedidos")
    
    date = orders.attr("fecha")
    time = orders.attr("hora")
    order_info = {
      order_id: name[/pedido_(.*?).xml/, 1],
      customer_id: orders.at_xpath("rut").content,
      address_id: orders.at_xpath("direccionId").content,
      entered_at: DateTime.parse(date + " " + time),
      date_delivery: orders.at_xpath("fecha").content
    }
    order = Order.create(order_info)
    Rails.logger.debug("ORDER: Orden creada, ahora a sub ordenes")
    order.load_product_orders(orders)
	end

	def load_product_orders(doc)    
    doc.xpath("Pedido").each do |suborder|
      Rails.logger.debug("SUBORDER: Creando sub orden sku: #{suborder.xpath("sku").to_s[/>(.*?)</, 1]}")
      self.product_orders.create({
        sku: suborder.at_xpath("sku").content, 
        amount: suborder.at_xpath("cantidad").content,
        order_unit: suborder.at_xpath("cantidad").attr("unidad")
      })
    end
  end

  def Order.check_new_orders
    conn = FunSftp::SFTPClient.new(Settings.orders_sftp_system.url, Settings.orders_sftp_system.user, Settings.orders_sftp_system.password)
    conn.chdir "Pedidos"
    
    conn.entries(".", true).each do |filename|
      next if filename == "." || filename == ".."
      order_id = filename[/pedido_(.*?).xml/, 1]
      unless Order.exists?(order_id: order_id)
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
  end

end