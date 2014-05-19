class Price < ActiveRecord::Base

  
  belongs_to :product
  scope :active, -> { where(['expiration_date >= ?',  Date.today]) }
  
  
  
end
