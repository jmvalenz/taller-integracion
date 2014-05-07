class Warehouse
  include ActiveModel::Model

  STOCKS_URL = "http://bodega-integracion-2014.herokuapp.com"

  attr_accessor :depots

  def depots
    @depots ||= load_depots
  end

  def Warehouse.get_request_hash(string)
    # strict_encode64
    Base64.strict_encode64("#{OpenSSL::HMAC.digest('sha1', Settings.stocks_management_system.private_key, string)}")
  end

  def Warehouse.get_authorization_string(string)
    hash = get_request_hash(string)
    "UC #{Settings.stocks_management_system.public_key}:#{hash}"
  end

  def Warehouse.get_json_response(path, data, method, auth_string)
    url = URI.join(STOCKS_URL, path)
    url.query = URI.encode_www_form(data)
    if method == "GET"
      req = Net::HTTP::Get.new(url.request_uri)
    elsif method == "POST"
      req = Net::HTTP::Post.new(url.request_uri)
    elsif method == "DELETE"
      req = Net::HTTP::Delete.new(url.request_uri)
    end
    req.add_field("Authorization", get_authorization_string(auth_string))
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    JSON.parse(res.body, symbolize_names: true)
  end

  def load_depots
    method = "GET"
    string = method
    path = "/almacenes"
    data = {}
    json_depots = Warehouse.get_json_response(path, data, method, string)
    response = []
    json_depots.each do |json_depot|
      response << Depot.parse_from_json(json_depot)
    end
    response
  end

  

end