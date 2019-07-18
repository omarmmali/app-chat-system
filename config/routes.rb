Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/applications/:token', to: 'client_applications#show'
  patch '/applications/:token', to: 'client_applications#update'
  get '/applications', to: 'client_applications#index'
  post '/applications', to: 'client_applications#create'
end
