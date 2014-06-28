class Sprees
  include ActiveModel::Model

  def Sprees.reload
    Rails.logger.info("****===Eliminando Sprees===****")
    unload
    Rails.logger.info("****===Recargando Sprees===****")
    load
    Rails.logger.info("****===FIN Sprees===****")
  end

  def Sprees.unload
    Spree::Taxonomy.destroy_all
    Spree::Taxon.destroy_all
    Spree::Product.destroy_all
  end

  def Sprees.load
    categories = Spree::Taxonomy.create(name: "Categorias")
    brands = Spree::Taxonomy.create(name: "Marcas")

    Brand.all.each do |brand|
      Spree::Taxon.create(name: brand.name, parent: brands.root)
    end
    Category.all.each do |category|
      Spree::Taxon.create(name: category.name, parent: categories.root)
    end

    Product.all.each do |product|
      spree_variant = Spree::Variant.find_by(sku: product.sku)
      unless spree_variant
        spree_product = Spree::Product.create(name: product.name, price: product.internet_price.to_s, description: product.description, sku: product.sku, shipping_category_id: 1, available_on: Time.now)
        spree_image = Spree::Image.create(attachment: open(product.image_path), viewable: spree_product.master)
        spree_product.taxons << Spree::Taxon.find_by(name: product.brand.name)
        product.categories.each do |category|
          taxon = Spree::Taxon.find_by(name: category.name)
          spree_product.taxons << taxon unless spree_product.taxons.include? taxon
        end
        spree_stock = spree_product.stock_items.first
        spree_stock.set_count_on_hand(warehouse.get_total_stock(product.sku) - Reservation.reserved_amount(product.sku))
      end
    end
  end

  def Sprees.changePrice(sku, precio)
    if producto = Spree::Variant.find_by_sku(sku)
      begin
        producto.price << precio
      rescue
      end
    end
  end


  def Sprees.actualizarStock(sku)
    if producto = Spree::Variant.find_by_sku(sku)
      p = Spree::StockItem.find(producto.id)
      stock = warehouse.get_total_stock(sku) - Reservation.reserved_amount(sku)
      begin
        p.set_count_on_hand(stock)
      rescue
      end
    end
  end


  def Sprees.warehouse
    @@warehouse ||= Warehouse.new
  end

end
