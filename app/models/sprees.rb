class Sprees
  include ActiveModel::Model
  
  def Sprees.cargarJson
    products_path = Rails.root.join("db/productos.json")
    data =File.open(products_path).read
    categorias = Spree::Taxonomy.find_by_name("Categoria")
    r_categorias = categorias.root
    marcas = Spree::Taxonomy.find_by_name("Marca")
    r_marcas = marcas.root
    texto = JSON.parse(data)
    for i in 0...texto.length
     		
      if not taxon1 = Spree::Taxon.find_by_name(texto[i]['marca'])
        Spree::Taxon.create(:name => texto[i]['marca'], :parent_id => r_marcas.id)
      end
      for j in 0..texto[i]['categorias'].length-1
        if not taxon2 = Spree::Taxon.find_by_name(texto[i]['categorias'][j])
          Spree::Taxon.create(:name => texto[i]['categorias'][j], :parent_id => r_categorias.id)
        end
      end
    end
  end
      
  def Sprees.cargarSpree
    products_path = Rails.root.join("db/productos.json")
    data =File.open(products_path).read
    texto = JSON.parse(data)
    for i in 0...texto.length
      if not producto = Spree::Variant.find_by_sku(texto[i]['sku'])
        p = Spree::Product.create :name => texto[i]['modelo'], :price => texto[i]['precio']['internet'], :description => texto[i]['descripcion'], :sku => texto[i]['sku'], :shipping_category_id => 1, :available_on => Time.now
        img = Spree::Image.create(:attachment => open(texto[i]['imagen']), :viewable => p.master)
        p.taxons << Spree::Taxon.find_by_name(texto[i]['marca'])
        for j in 0..texto[i]['categorias'].length-1
          taxon = Spree::Taxon.find_by_name(texto[i]['categorias'][j])
          begin
            p.taxons << taxon
          rescue
          end
        end
      end
    end
  end

  def Sprees.cargarStock
    products_path = Rails.root.join("db/productos.json")
    data =File.open(products_path).read
    texto = JSON.parse(data)
    for i in 0...texto.length
      if producto = Spree::Variant.find_by_sku(texto[i]['sku'])
      	p = Spree::StockItem.find(producto.id)
        stock = warehouse.get_total_stock(texto[i]['sku'])
      	begin
          p.set_count_on_hand(stock)
      	rescue
      	end
      end
    end
  end

 def Sprees.actualizarStock(sku)
   if producto = Spree::Variant.find_by_sku(sku)
    p = Spree::StockItem.find(producto.id)
    stock = warehouse.get_total_stock(sku)
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
