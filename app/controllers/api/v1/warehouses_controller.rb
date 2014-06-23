class Api::V1::WarehousesController < Api::V1::BaseController

  def move_product
    sku = params[:sku]
    quantity = params[:cantidad].to_i
    depot_id = params[:almacenId]

    unless Product.exists?(sku: sku)
      render json: { error: "Producto con SKU '#{sku}' no existe" } and return
    end

    w = Warehouse.new
    available_quantity = w.get_total_stock(sku)
    if available_quantity >= quantity
      begin
        w.move_products_to_warehouse!(sku, quantity, depot_id)
      rescue
        render json: { error: "Hubo un error interno" }
      end
      render json: { sku: sku, cantidad: quantity }
    else
      render json: { error: "No hay suficiente stock" }
    end
  end

end
