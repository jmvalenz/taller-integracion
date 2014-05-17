class Crm < ActiveRecord::Base
	
	include HTTParty
  	base_uri 'http://integra.ing.puc.cl/vtigerCRM'
  	default_params :output => 'json'
  	format :json
  	
  	def Crm.get_customer(id)
      query = "select * from Contacts where cf_707='#{id}';"
	    Rails.logger.debug(cookies['sessionName'])
      response = get('/webservice.php?', query: { operation: :query, sessionName: cookies['sessionName'], query: query})
      json = JSON.parse(response.body, symbolize_names: true)
      result = json[:result].first
      i = result[:cf_707]
      fn = result[:firstname]
      ln = result[:lastname]
      if result[:mailingstreet].empty?
        s = result[:otherstreet]
      else
        s = result[:mailingstreet]
      end
      if result[:mailingcity].empty?
        c = result[:othercity]
      else
        c = result[:mailingcity]
      end
      if result[:mailingstate].empty?
        st = result[:otherstate]
      else
        st = result[:mailingstate]
      end
      Customer.new(_id: i, first_name: fn, last_name: ln, street: s, city: c, state: st)
  	end

  	def Crm.login
      # Obtengo el challenge token
      token = get_challenge[:result][:token]
      # El API accessKey es MD5(token + accessKey)
      generated_key = Digest::MD5.hexdigest(token.to_s + Settings.vtiger.accessKey.to_s)
      response = post('/webservice.php', body: { operation: "login", username: Settings.vtiger.username, accessKey: generated_key })
      json = JSON.parse(response.body, symbolize_names: true)
      cookies['sessionName'] = json[:result][:sessionName]
  	end
    
    def Crm.logout
      response = get('/webservice.php?', query: { operation: :logout, sessionName: cookies['sessionName'] })
      JSON.parse(response.body, symbolize_names: true)
    end

  	private 
  	def Crm.get_challenge
      response = get('/webservice.php?', query: { operation: :getchallenge, username: Settings.vtiger.username })
      JSON.parse(response.body, symbolize_names: true)
  	end

end