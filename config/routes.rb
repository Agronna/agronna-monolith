Rails.application.routes.draw do
  root "home#index"

  post "home/submit", to: "home#submit"
end
