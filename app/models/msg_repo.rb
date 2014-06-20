class MsgRepo < ActiveRecord::Base
  require 'bunny'
  
  def self.read_msg

    # start a communication session with the amqp server
    # declare a queue
    # declare default direct exchange which is bound to all queues
    # publish a message to the exchange which then gets routed to the queue
    # get message from the queue
    
    # no estoy segura
    channel = @conn.create_channel
    cola = channel.queue('reposicion', :auto_delete => true)

    channel.prefetch(1)

  end

  def self.connect
    @conn = Bunny.new('amqp://kncydrxj:MzJ3mNOLFh-Vnj2_AA7LSiP8x9AkTUx7@tiger.cloudamqp.com/kncydrxj')
    @conn.start
  end

  def self.disconnect
    @conn.stop
  end  
end
