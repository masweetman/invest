Rails.application.routes.draw do

  resources :companies do
    resources :earnings
  end
  resources :queries

  get 'update', to: 'companies#update'
  
  root 'companies#index'

end
