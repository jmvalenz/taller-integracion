class DataWarehouse::Dispatch
  include Mongoid::Document
  field :customer_id, type: String
  field :order_id, type: Integer
  field :address, type: String # Guardar full adress
  field :street_address, type: String
  field :items_delivered, type: Integer
  field :items_not_delivered, type: Integer # Guardar con fecha de delivery
  field :delivered_at, type: DateTime
  field :date_delivery, type: Date
  field :entered_at, type: DateTime
end