class Customer
  include ActiveModel::Model

  attr_accessor :_id, :first_name, :last_name, :street, :city, :state

  def full_address
    (street_address + ", " + city + ", " + state + ", Chile").titleize
  end

  def street_address
  	street_values = street.split
  	street_address = ""

  	street_values.each do |value|
	  street_address += " " + value
  	  if !!(value =~ /^[-+]?[0-9]+$/)
  	  	break
  	  end
  	end
  	street_address.strip
  end


end