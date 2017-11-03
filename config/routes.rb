Rails.application.routes.draw do
  resources :users
  get '/', to: 'users#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get "/:username", to: 'users#datepicker', as: 'datepicker' #for requester to browse to datepicker
  post :scheduled, to: 'users#scheduled', as: :scheduled
  post "/users/:id", to: 'users#show', as: 'showme' #lets integration form post to page for api call
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
