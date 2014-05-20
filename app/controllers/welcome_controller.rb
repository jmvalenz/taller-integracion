class WelcomeController < ApplicationController

  def index
    @warehouse = Warehouse.new
    @depots = @warehouse.depots

    # @orders

    gon.depots = @depots
  end
end
