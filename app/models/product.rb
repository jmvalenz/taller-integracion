class Product < ActiveRecord::Base
  require 'rubygems'
  require 'net/ssh'
  require 'net/scp'
  require 'csv'
  require 'date'

  HOST = 'integra5.ing.puc.cl'
  USER = 'passenger'
  PASS = '1234567890'

  belongs_to :brand
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :prices
  has_many :sales

  validates_presence_of :name, :sku

  def Product.load(filename)
    file = open(filename)
    content = file.read
    Product.load_products(JSON.parse(content, symbolize_names: true))
    file.close
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

  def Product.fetch_prices
    reload_prices
    download_csv
    read_csv
    File.delete "pricing/Pricing.csv"
  end

  def Product.reload_prices
    Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
      result = ssh.exec!("cd access2csv && java -jar access2csv.jar ~/Dropbox/Grupo5/DBPrecios.accdb")
      puts result
    end
  end

  def Product.download_csv
    Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
      result = ssh.scp.download! "access2csv/Pricing.csv", "pricing/Pricing.csv"
      puts result
    end
  end

  def Product.read_csv
    Price.destroy_all # Para cargar precios, se eliminan todos. (Alguna forma más eficiente?)
    text = File.open('pricing/Pricing.csv').read
    CSV.parse(text, headers: true) do |row|
      product = Product.find_by(sku: row[1].to_i.to_s)
      f_act = Date.strptime(row[3].strip, "%m/%d/%Y")
      f_vig = Date.strptime(row[4].strip, "%m/%d/%Y")
      product.prices.create(
        price: row[2],
        expiration_date: f_vig,
        update_date: f_act,
        cost: row[5],
        transfer_cost: row[6]
      )
     end
  end

  def current_price(internet = false)
    if (ofertas = msg_ofertas.active) && ofertas.present?
      ofertas.first.precio.to_d
    elsif (precios = prices.active) && precios.present?
      precios.first.price
    elsif internet
      self.internet_price
    else
      self.price
    end
  end

  ## NOT FINISHED
  def Product.find_or_create_from_hash(hash)
    product = Product.find_by(sku: hash[:sku])
    if product
      product.update(hash)
    else
      product = Product.create(hash)
    end
  end

end
