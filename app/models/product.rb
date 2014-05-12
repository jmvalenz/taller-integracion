class Product < ActiveRecord::Base

  belongs_to :brand
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  validates_presence_of :name, :sku

  def Product.load(filename)
    file = open(filename)
    content = file.read
    Product.load_products(JSON.parse(content, symbolize_names: true))
  end

  def Product.load_products(array_of_hashes)
    array_of_hashes.each do |hash|
      brand = Brand.find_or_create_by(name: hash[:marca])
      internet_price = hash[:precio][:internet]
      normal_price = hash[:precio][:normal]
      product = Product.create({
        sku: hash[:sku], 
        name: hash[:modelo], 
        internet_price: internet_price, 
        price: normal_price, 
        brand: brand, 
        description: hash[:descripcion],
        image_path: hash[:imagen]
      })
      hash[:categorias].each do |category_name|
        if category_name.present?
          category = Category.find_or_create_by(name: category_name)
          product.categories << category
        end
      end
    end
  end


  ## NOT FINISHED
  def Product.find_or_create_from_hash(hash)
    product = Product.find_by(sku: hash[:sku])
    if product
      product.update_attributes(hash)
    else
      product = Product.create(hash)
    end
  end

end
