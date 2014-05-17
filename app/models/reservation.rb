class Reservation < ActiveRecord::Base

    has_many :product_reservation, dependent: :destroy

  def Reservation.load_preservations(ws)
    i = 5
    while not ws[i,1].empty? and ws[i,4].empty?  do
      product_reservation = Product_reservation.create({
        sku: ws[i,1], 
        customer_id: ws[i,2], 
        amount: ws[i,3]
      })
      ws[i,4] = "Si"
      i = i + 1
    end
    ws.save()
  end

    ##################### SYSTEM METHODS #####################
  def Product.load(key)
    key = Google::APIClient::KeyUtils.load_from_pkcs12('29238ebeddba28cc9685d3151dbff93d348c7e76-privatekey.p12', 'notasecret')

    client = Google::APIClient.new(:application_name => 'Project Default Service Account',
        :application_version => '0.1.0')


    client.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      audience: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://spreadsheets.google.com/feeds',
      issuer: '98758856993-2d0o5gfdtno8ee3smg2kbot69j271qg2@developer.gserviceaccount.com',
      signing_key: key)
    client.authorization.fetch_access_token!
    access_token = client.authorization.access_token

    session = GoogleDrive.login_with_oauth(access_token, proxy = nil)
    ws = session.spreadsheet_by_key("0As9H3pQDLg79dEZqd1YzYl80Y0Q0TjlJZDNTclFnTUE").worksheets[0]
    self.load_preservations(ws)
  end