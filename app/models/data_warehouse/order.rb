class DataWarehouse::Order
  include Mongoid::Document
  field :customer_id, type: String
  field :order_id, type: Integer
  field :address, type: String # Guardar full adress
  field :street_address, type: String
  field :success, type: Boolean
  field :delivered_at, type: DateTime # Guardar con fecha de delivery
  field :date_delivery, type: Date
  field :entered_at, type: DateTime


end