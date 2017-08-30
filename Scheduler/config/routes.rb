Rails.application.routes.draw do
  get '/', to: 'users#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get "/:username", to: 'users#datepicker' #for requester to browse to datepicker
  post "/:username", to: 'users#submit' #for requester to submit time
  post "/users/:id", to: 'users#show', as: 'showme'#lets integration form post to page for api call

  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
