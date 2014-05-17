require 'net/sftp'
require 'nokogiri'

class Main

  ################# VENTA MAYORISTA #################

  #Este evento es gatillado por un nuevo pedido
  def wholesale_process
    # 
  end

  def fetch_orderd
    # Revisar FTP.
    # Si hay pedidos nuevos, ejecuto wholesale_process


	Net::SFTP.start('integra.ing.puc.cl', 'grupo5', :password => '823823k') do |sftp|
	# sftp.file.open("/home/grupo5/Pedidos/pedido_1001.xml") do |file|
		sftp.dir.foreach("/home/grupo5/Pedidos/") do |order|
	    	
			#Se comprueba que la orden no haya sido ingresada previamente
			if passes_validation?(remote_file)
	    		Order.load_orders(order)
	    		
	    	order.close
		end
	end

  end

  def passes_validation

  	return true

  end

end
