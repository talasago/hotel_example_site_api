Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for(
        'User',
        at: :auth,
        skip: [:passwords],
        controllers: {
          registrations: 'api/v1/registrations',
          sessions: 'api/v1/sessions'
        }
      )

      resource :mypage, controller: 'users', only: [:show, :destroy]
      resources :plans, controller: 'plans', only: [:index, :show]
    end
  end
end
