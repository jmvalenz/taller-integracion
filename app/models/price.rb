class Price < ActiveRecord::Base


  belongs_to :product
  scope :active, -> { where(['update_date <= ? AND expiration_date >= ?',  Date.today, Date.today]) }



end
