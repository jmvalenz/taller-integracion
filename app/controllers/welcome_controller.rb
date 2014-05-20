class WelcomeController < ApplicationController

  def index
    @warehouse = Warehouse.new
    @depots = @warehouse.depots

    @delayed_orders = Order.not_delivered.ready_to_deliver
    @not_delayed_orders = Order.not_delivered.not_ready_to_deliver

    #@most_wanted_products = Product.


    gon.depots = @depots
    gon.delayed_orders = @delayed_orders.count
    gon.not_delayed_orders = @not_delayed_orders.count

  end

  def orders
    @orders = Order.not_delivered
  end
end
