class MsgRepo < ActiveRecord::Base



  def self.read_msg
    conn.start
    canal = conn.create_channel
    q = canal.queue('reposicion', :auto_delete => true)
    # while q.message_count > 1000 #*cambiarlo a cero el lunes!!!!!!!!
      delivery_info, properties, payload = q.pop
      msg = JSON.parse(payload, symbolize_names: true)
      sku = msg[:sku]
      fecha = Time.at(msg[:fecha]/1000)
      almacenId = msg[:almacenId]
    # end
    canal.close
    conn.close
  end

  def self.suscribe_to_queue
    conn.start
    canal = conn.create_channel

    q = canal.queue("reposicion", auto_delete: true)
    self.consumer = q.subscribe(ack: true) do |delivery_info, properties, payload|
      puts "Received #{payload}, message properties are #{properties.inspect} #{delivery_info}"
    end

    canal.close
    conn.close
  end

  def self.unsuscribe_from_queue
    @@consumer.cancel
  end

  def self.conn
    @@conn ||= Bunny.new(Settings.cloudamqp.url)
  end

  def self.consumer=(value)
    @@consumer = value
  end

  def self.consumer
    @@consumer
  end

end


=begin
  t.string :sku
  t.integer :fecha
  t.string :almacenId
  t.string :int
=end
