Rails.application.routes.draw do
  get "/an_static_form", to: "forms#static"
end
