class MsgOferta < ActiveRecord::Base
  require 'bunny'
  
  def self.read_msg
    conn = Bunny.new('amqp://kncydrxj:MzJ3mNOLFh-Vnj2_AA7LSiP8x9AkTUx7@tiger.cloudamqp.com/kncydrxj')
    conn.start
    canal = conn.create_channel
    cola = canal.queue('ofertas', :auto_delete => true)
    while cola.message_count > 1000 #*cambiarlo a cero el lunes!!!!!!!!
      cola.pop do |body|
        puts body
        msg = JSON.parse(body)
        sku = msg['sku']
        precio = msg['precio']
        inicio = Time.at(msg['inicio']/1000)
        fin = Time.at(msg['fin']/1000)
      end
    end
    conn.close
  end

  def self.connect
    @conn = Bunny.new('amqp://kncydrxj:MzJ3mNOLFh-Vnj2_AA7LSiP8x9AkTUx7@tiger.cloudamqp.com/kncydrxj')
    @conn.start
  end

  def self.disconnect
    @conn.stop
  end
end


=begin
  t.string :sku
  t.integer :precio
  t.integer :inicio
  t.integer :fin
=end
