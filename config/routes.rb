Rails.application.routes.draw do
  resources :users do
    member do
      post 'link_to_redtail'
    end
  end

  get '/', to: 'users#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get "/:username", to: 'users#datepicker' #for requester to browse to datepicker
  post "/:username", to: 'users#datepicker', as: 'email'
  post "/users/:id", to: 'users#show', as: 'showme' #lets integration form post to page for api call
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
