Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/applications' do

    scope ':application_token' do
      get '/', to: 'client_applications#show'
      patch '/', to: 'client_applications#update'

      scope '/chats' do
        get '/', to: 'application_chats#index'
        post '/', to: 'application_chats#create'

        scope ':chat_number' do
          get '/', to: 'application_chats#show'
          patch '/', to: 'application_chats#update'

          get '/messages', to: 'chat_messages#index'
        end
      end

    end
    get '/', to: 'client_applications#index'
    post '/', to: 'client_applications#create'
  end
end
