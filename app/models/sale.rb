class Sale < ActiveRecord::Base

  scope :active, -> { where(["sales.inicio < ? AND sales.fin > ?", Time.now.to_i, Time.now.to_i]) }
  belongs_to :product
  after_create :tweet

  def self.read_msg
    conn.start
    canal = conn.create_channel
    cola = canal.queue('ofertas', auto_delete: true)
    while cola.message_count > 0
      pop_and_create_sale(cola)
    end
    canal.close
    conn.close
  end

  def self.pop_and_create_sale(queue)
    delivery_info, properties, payload = queue.pop
    msg = JSON.parse(payload, symbolize_names: true)
    sku = msg[:sku]
    precio = msg[:precio]
    inicio = Time.at(msg[:inicio]/1000)
    fin = Time.at(msg[:fin]/1000)
    product = Product.find_by(sku: sku)

    create(sku: sku, precio: precio, inicio: inicio, fin: fin, product: product)
  end

  def self.conn
    @@conn ||= Bunny.new(Settings.cloudamqp.url)
  end

  def self.tweet
    twitter = Tw.new
    prduct = Item.find(sku)

    msg="OFERTA! #{prduct.name} a sólo $#{self.precio} #ofertagrupo5"
    twitter.tweet(msg)
  end

end