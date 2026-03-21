Rails.application.routes.draw do
  root "home#index"

  get "acesso-invalido", to: "errors#tenant_required", as: :tenant_required

  post "home/submit", to: "home#submit"

  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  resources :secretaries, path: "/secretarias", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :producers, path: "/produtores", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :machines, path: "/maquinarios", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :properties, path: "/propriedades", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :service_providers, path: "/prestadores", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }
  resources :users, path: "/usuarios", only: [ :index, :new, :create, :edit, :update, :destroy ], path_names: { new: "cadastrar", edit: "editar" }

  resources :service_orders, path: "/ordens-servico", path_names: { new: "cadastrar", edit: "editar" } do
    member do
      patch :start, path: "iniciar"
      patch :complete, path: "finalizar"
      patch :cancel, path: "cancelar"
    end
  end

  resources :payment_receipts, path: "/comprovantes", path_names: { new: "novo", edit: "editar" } do
    member do
      patch :approve, path: "aprovar"
      patch :reject, path: "rejeitar"
    end
  end

  resources :schedules, path: "/agendamentos", path_names: { new: "novo", edit: "editar" } do
    member do
      patch :start_service_order, path: "iniciar-os"
      patch :complete_service_order, path: "finalizar-os"
    end
    collection do
      get :calendar, path: "calendario"
      get :events
    end
  end
end
