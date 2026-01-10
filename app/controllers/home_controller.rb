class HomeController < ApplicationController
  def index
  end

  def submit
    @nome  = params[:nome]
    @email = params[:email]

    flash.now[:notice] = "Formulário enviado com sucesso!"
    render :index
  end
end
