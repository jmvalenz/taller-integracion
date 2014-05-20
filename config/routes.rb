TallerIntegracion::Application.routes.draw do
  resources :crms

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'welcome#orders'

  namespace :api do
    api_version(:module => "v1", :path => {:value => "v1"}) do
      post "pedirProducto" => "warehouses#move_product"
    end
  end
end
