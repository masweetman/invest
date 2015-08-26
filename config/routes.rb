Rails.application.routes.draw do

  resources :companies do
    resources :earnings
  end

  get 'update', to: 'companies#update'
  
  root 'companies#index'

end
