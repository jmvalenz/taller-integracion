class Api::V1::BaseController < ApplicationController
  
  # Poner aqui validacion de API con before_filter
  before_action :validate_user
  skip_before_action :verify_authenticity_token

  def validate_user
    username = params[:usuario]
    password = params[:password]
    if user = WarehouseUser.find_by(username: username)
      if user.password != password
        render json: {error: "Credenciales inválidas"} and return
      end
    else
      render json: {error: "Usuario no encontrado"} and return
    end
  end

end