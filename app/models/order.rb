class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_order, dependent: :destroy

    def Order.load(filename)
	    doc = Nokogiri::XML(file)
	   
      order = Order.create_by({
        customer_id: doc.xpath("//Pedidos//rut").to_s[/>(.*?)</, 1]
        address_id: doc.xpath("//Pedidos//direccionId").to_s[/>(.*?)</, 1]
        date: doc.xpath("//Pedidos/fecha").to_s[/>(.*?)</, 1]
        time: doc.xpath("//Pedidos/hora").to_s[/>(.*?)</, 1]
        date_delivery: doc.xpath("//Pedidos//fecha").to_s[/>(.*?)</, 1]
        
      })

      order.load_orders(doc)

      file.close
  	end

  	def load_product_orders(doc)    
      doc.xpath("//Pedidos//Pedido").each do |pedido|
        self.product_orders.create({
          sku: pedido.xpath("//sku").to_s[/>(.*?)</, 1], 
          amount: pedido.xpath("//cantidad").to_s[/>(.*?)</, 1]
      })
      end
    end
  end

  def Order.check_new_Order()
    Net::SFTP.start('orders_sftp_system.url', 'orders_sftp_system.user', password: 'orders_sftp_system.') do |sftp|
    # sftp.file.open("/home/grupo5/Pedidos/pedido_1001.xml") do |file|
      sftp.dir.foreach("/home/grupo5/Pedidos/") do |order|
          
        #Se comprueba que la orden no haya sido ingresada previamente
        if passes_validation?(remote_file)
            Order.load_orders(order)

          order.close
      end
    end
  end

end