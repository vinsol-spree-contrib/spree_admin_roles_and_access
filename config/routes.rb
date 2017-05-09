Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :roles, except: [:show]
    resources :permissions, except: [:show]
    resources :permission_sets
    resource :default_admin_dashboard, only: :show
  end
end
