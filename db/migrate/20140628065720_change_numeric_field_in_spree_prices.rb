class ChangeNumericFieldInSpreePrices < ActiveRecord::Migration
  def self.up
   change_column :spree_prices, :amount, :decimal, :precision => 10, :scale => 2, :null => true
  end
  def self.down
   change_column :spree_prices, :amount, :decimal, :precision => 8, :scale => 2, :null => true
  end
end
