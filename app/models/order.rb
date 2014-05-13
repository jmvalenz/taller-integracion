class Order < ActiveRecord::Base

  belongs_to :customer
  has_many :product_order, dependent: :destroy

    def Order.load(filename)
	    file = open(filename)
	    doc = Nokogiri::XML(file)
	    customer = Customer.find_or_create_by(rut: doc.xpath("//Pedidos//rut"))
      date = doc.xpath("//Pedidos[fecha]")
      time = doc.xpath("//Pedidos[hora]")
      date_delivery = doc.xpath("//Pedidos//fecha")
      address_id = doc.xpath("//Pedidos//direccionId")

      Order.load_orders(doc)

      file.close
  	end

  	def Order.load_orders(doc)    
      doc.xpath("//Pedidos").each do |pedido|
        order = Product_order_.create({
        sku: pedido.xpath("//sku"), 
        amount: pedido.xpath("//cantidad"), 
      })
      end
    end
  end


end