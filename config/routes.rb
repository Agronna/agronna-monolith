Rails.application.routes.draw do
  root "home#index"

  get "acesso-invalido", to: "errors#tenant_required", as: :tenant_required

  post "home/submit", to: "home#submit"

  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  resources :secretaries, path: "/secretarias", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :producers, path: "/produtores", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :users, path: "/usuarios", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
end
