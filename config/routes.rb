Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'signup', controllers: {
        registrations: 'api/v1/registrations'
      }
      resources :mypages, controller: 'users', only: [:destroy]
    end
  end
end
