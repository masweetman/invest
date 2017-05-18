Rails.application.routes.draw do

  resources :settings
  resources :companies do
    resources :earnings
  end
  resources :queries

  get 'update_quotes', to: 'companies#update_quotes'
  
  root 'companies#index'

end
