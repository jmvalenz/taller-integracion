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

  end

  def passes_validation

    return true

  end

end
