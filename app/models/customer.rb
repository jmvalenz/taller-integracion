class Customer
  include ActiveModel::Model

  attr_accessor :_id, :first_name, :last_name, :street, :city, :state

  def full_address
    (street + ", " + city + ", " + state).titleize
  end



end