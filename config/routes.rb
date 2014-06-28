TallerIntegracion::Application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/store'
          resources :crms

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'dashboard' => "welcome#dashboard", as: "dashboard"
  get 'welcome/orders'

  namespace :api do
    api_version(:module => "v1", :path => {:value => "v1"}) do
      post "pedirProducto" => "warehouses#move_product"
    end
  end
end
