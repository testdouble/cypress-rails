Rails.application.routes.draw do
  get "/an_static_form", to: "forms#static"

  resources :compliments

  root "compliments#index"
end
