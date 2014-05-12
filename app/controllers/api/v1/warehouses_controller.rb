class Api::V1::WarehousesController < Api::V1::BaseController
  
  def move_product
    sku = params[:sku]
    quantity = params[:cantidad].to_i
    w = Warehouse.new
    available_quantity = w.get_total_stock(sku)
    if available_quantity >= quantity

      render json: { sku: sku, cantidad: quantity }
    else
      render json: { error: "No hay suficiente stock" }
    end
  end
  
end
