Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :roles, except: [:show]
    resources :permissions, except: [:show]
    resources :permission_sets
  end
end
