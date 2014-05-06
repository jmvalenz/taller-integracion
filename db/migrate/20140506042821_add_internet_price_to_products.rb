class AddInternetPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :internet_price, :decimal
  end
end
