class DataWarehouse::Order
  include Mongoid::Document
  field :customer_id, type: String
end