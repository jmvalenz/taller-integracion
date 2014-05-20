class DataWarehouse::Product
  include Mongoid::Document
  field :name, type: String
  field :product_id, type: Integer
  field :quantity, type: Integer



end