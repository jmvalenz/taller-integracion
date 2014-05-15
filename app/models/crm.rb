class Crm < ActiveRecord::Base
	
	#include HTTParty
  	#base_uri 'http://integra.ing.puc.cl/vtigerCRM'
  	#default_params :output => 'json'
  	#format :json

  	def self.getchallenge(username)
    	get('http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=getchallenge', :query => {:username => username})
  	end

  	def self.login(username, password)
    	post('/webservice.php?operation=login', :query => {:username => username, :accessKey => password})
  	end

end



