Rails.application.routes.draw do
  
  devise_for :users
  resources :displays
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "static#detail-test"
end
