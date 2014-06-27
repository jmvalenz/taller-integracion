class Sale < ActiveRecord::Base

  scope :active, -> { where(["sales.inicio < ? AND sales.fin > ?", Time.now.to_i, Time.now.to_i]) }
  scope :without_tws, -> { includes(:tw).where(tws: { sale_id: nil }) }
  belongs_to :product
  has_one :tw



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
    #Actualizo en Spree
    Sprees.changePrice(sku, precio)
  end

  def self.conn
    @@conn ||= Bunny.new(Settings.cloudamqp.url)
  end

  def tweet
    msg="OFERTA! #{product.name.truncate(40)} a sólo $#{self.precio.to_i}. Solo hasta el #{} #ofertagrupo5"
    Tw.tweet(msg)
  end

  def activate
    self.tw = tweet
    save
  end

end