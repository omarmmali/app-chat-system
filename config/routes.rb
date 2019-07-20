Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/applications' do
    scope ':application_token' do
      get '/', to: 'client_applications#show'
      patch '/', to: 'client_applications#update'

      get '/chats', to: 'application_chats#index'
    end
    get '/', to: 'client_applications#index'
    post '/', to: 'client_applications#create'
  end
end
