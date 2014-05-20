class DataWarehouse::Order
  include Mongoid::Document
  field :customer_id, type: String
  field :order_id, type: Integer
  # field :address, type: String

  # t.integer  "order_id"
  #   t.string   "customer_id"
  #   t.integer  "address_id"
  #   t.datetime "entered_at"
  #   t.date     "date_delivery"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.datetime "delivered_at"
  #   t.boolean  "success"
end