class Tw < ActiveRecord::Base
  require 'twitter'
  require 'bunny'

  def self.tweet(msg)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "Tli6mWsBhcJgJORYcknP2ts0l"
      config.consumer_secret     = "3TJSb4Y4DNg4kJt1cZcjvCe7bLQ7PKs78ZHKfjJQV6gxD5mzIi"
      config.access_token        = "2573196487-KltYXKzalSomXuJlZLYSYiNnez8PV7eAXkZJzFz"
      config.access_token_secret = "sEfhHCzsEUgnhhTCr7mbP26m4WGKvwU7OTGsXtb5l09uy"
    end

    client.update(msg)
  end

  def self.postOferta(sku, precio, inicio, fin)
    product=Item.find(sku)

    if(!product.internet_price)
      internet_price=Procing.where(sku: sku).first.precio
    elsif(product.internet_price<=0)
      internet_price=Producto.where(sku: sku).first.precio
    end 

    fecha_inicio= Date.strptime((inicio/1000).to_s, '%s')
    fecha_fin= Date.strptime((fin/1000).to_s, '%s')
    hora_inicio=Time.at(inicio/1000)
    hora_fin=Time.at(fin/1000)

    brand = product.brand
    name = product.name

    msg="OFERTA DEL #{fecha_inicio} AL #{fecha_fin}! #{brand} #{name} - ANTES: $#{internet_price} | AHORA: $#{precio}"

    tweet(msg)
  end

end
