class WelcomeController < ApplicationController

  def index
  end

  def dashboard
    @warehouse = Warehouse.new
    @depots = @warehouse.depots

    @delayed_orders = Order.not_delivered.ready_to_deliver
    @not_delayed_orders = Order.not_delivered.not_ready_to_deliver

    @last_five_orders = DataWarehouse::Order.desc(:delivered_at).limit(5).map{ |order|  [order.customer_id, order.coordinates].flatten }

    #@most_wanted_products = Product.


    gon.depots = @depots.map { |d| { type_to_s: d.type_to_s, used_space: d.used_space, total_space: d.total_space } }
    gon.delayed_orders = @delayed_orders.count
    gon.not_delayed_orders = @not_delayed_orders.count
    gon.last_five_orders = @last_five_orders

  end

  def orders
    @orders = Order.not_delivered
  end
end
