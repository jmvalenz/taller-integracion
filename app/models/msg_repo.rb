class MsgRepo < ActiveRecord::Base
  require 'bunny'
  require 'json'

  def self.read_msg
    conn = Bunny.new('amqp://kncydrxj:MzJ3mNOLFh-Vnj2_AA7LSiP8x9AkTUx7@tiger.cloudamqp.com/kncydrxj')
    conn.start
    ch = conn.create_channel
    q = ch.queue('reposicion', :auto_delete => true)
    while q.message_count > 1000 #*cambiarlo a cero el lunes!!!!!!!!
      q.pop do |delivery_info, properties, body|
        puts body
        msg = JSON.parse(body)
        sku = msg['sku']
        fecha = Time.at(msg['fecha']/1000)
        almacenId = msg['almacenId']
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
  t.integer :fecha
  t.string :almacenId
  t.string :int
=end
