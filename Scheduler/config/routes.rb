Rails.application.routes.draw do
  get '/', to: 'users#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get "/:username", to: 'users#datepicker'
  post "/:username", to: 'users#submit'

  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
