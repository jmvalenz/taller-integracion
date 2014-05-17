class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_order, dependent: :destroy

  def Order.load(file)
    name = file.name
    doc = Nokogiri::XML(file)
    
    date = doc.xpath("//Pedidos/fecha").to_s[/>(.*?)</, 1]
    time = doc.xpath("//Pedidos/hora").to_s[/>(.*?)</, 1]
    order_info = {
      order_id: name[/pedido_(.*?).xml/, 1],
      customer_id: doc.xpath("//Pedidos//rut").to_s[/>(.*?)</, 1],
      address_id: doc.xpath("//Pedidos//direccionId").to_s[/>(.*?)</, 1],
      date: DateTime.parse(date + " " + time),
      date_delivery: doc.xpath("//Pedidos//fecha").to_s[/>(.*?)</, 1]
    }
    order = Order.create(order_info)
    order.load_orders(doc)

    order.persisted?
	end

	def load_product_orders(doc)    
    doc.xpath("//Pedidos//Pedido").each do |pedido|
      self.product_orders.create({
        sku: pedido.xpath("//sku").to_s[/>(.*?)</, 1], 
        amount: pedido.xpath("//cantidad").to_s[/>(.*?)</, 1]
    })
  end

  def Order.check_new_Order()
    Net::SFTP.start(Settings.orders_sftp_system.url, Settings.orders_sftp_system.user, password: Settings.orders_sftp_system.password) do |sftp|
    # sftp.file.open("/home/grupo5/Pedidos/pedido_1001.xml") do |file|

      sftp.dir.foreach("/home/grupo5/Pedidos/") do |file|  
        order_id = file.name[/pedido_(.*?).xml/, 1]
        if not Order.exists?(order_id: order_id)
          Order.load(file)
        end
      end
    end
  end
end