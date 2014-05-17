class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_order, dependent: :destroy

    def Order.load(filename)
	    doc = Nokogiri::XML(file)
	    customer = Customer.find_or_create_by(rut: doc.xpath("//Pedidos//rut").to_s[/>(.*?)</, 1])
      doc.xpath("//Pedidos//rut").to_s[/>(.*?)</, 1]
      date = doc.xpath("//Pedidos/fecha").to_s[/>(.*?)</, 1]
      time = doc.xpath("//Pedidos/hora").to_s[/>(.*?)</, 1]
      date_delivery = doc.xpath("//Pedidos//fecha").to_s[/>(.*?)</, 1]
      address_id = doc.xpath("//Pedidos//direccionId").to_s[/>(.*?)</, 1]

      Order.load_orders(doc)

      file.close
  	end

  	def Order.load_orders(doc)    
      doc.xpath("//Pedidos").each do |pedido|
        order = Product_order.create({
        sku: pedido.xpath("//sku").to_s[/>(.*?)</, 1], 
        amount: pedido.xpath("//cantidad").to_s[/>(.*?)</, 1]
      })
      end
    end
  end


end