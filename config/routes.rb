Rails.application.routes.draw do

  resources :companies do
    resources :earnings
  end

  get 'update_data', to: 'companies#update_data'
  
  root 'companies#index'

end
