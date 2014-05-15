class Crm < ActiveRecord::Base
	
<<<<<<< HEAD
	rails include HTTParty
  	#base_uri 'http://integra.ing.puc.cl/vtigerCRM'
  	#default_params :output => 'json'
  	#format :json
=======
	include HTTParty
  	base_uri 'http://integra.ing.puc.cl/vtigerCRM'
  	default_params :output => 'json'
  	format :json
>>>>>>> 5eb79a60bab982b045ca61272241f6b17aa13f79

  	def Crm.get_challenge
    	response = get('/webservice.php?', query: { operation: :getchallenge, username: Settings.vtiger.username })
      JSON.parse(response.body, symbolize_names: true)
  	end

<<<<<<< HEAD
  	def self.login(username, password)
    	#token = getchallenge(username)
    	post('http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=login', :query => {:username => username, :accessKey => password})
=======
  	def Crm.login
      # Obtengo el challenge token
      token = get_challenge[:result][:token]
      # El API accessKey es MD5(token + accessKey)
      generated_key = Digest::MD5.hexdigest(token.to_s + Settings.vtiger.accessKey.to_s)

      response = post('/webservice.php', body: { operation: "login", username: Settings.vtiger.username, accessKey: generated_key })
      JSON.parse(response.body, symbolize_names: true)
>>>>>>> 5eb79a60bab982b045ca61272241f6b17aa13f79
  	end

end



