Rails.application.routes.draw do
  resources :client_applications, except: [:index, :new, :edit, :destroy], path: '/applications', param: :token do
    resources :application_chats, except: [:new, :edit, :destroy], path: '/chats', param: :number do
      resources :chat_messages, except: [:new, :edit, :destroy], path: '/messages', param: :number do
        collection do
          get :search
        end
      end
    end
  end
end
