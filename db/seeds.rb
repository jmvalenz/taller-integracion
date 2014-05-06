# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "================ INICIO SEEDS ================"

puts "================ Eliminando tuplas en base de datos ================"
Brand.destroy_all
Category.destroy_all
Product.destroy_all
ProductCategory.destroy_all
puts "================ Tuplas eliminadas ================"

puts "================ Cargando archivo de productos ================"
products_path = Rails.root.join("db/productos.json")
Product.load(products_path)
puts "================ Carga de productos finalizada ================"


puts "================ FIN SEEDS ================"