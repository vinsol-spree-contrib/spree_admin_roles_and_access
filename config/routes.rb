Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :roles, :except => [:show]
    resources :permissions, :except => [:edit, :update, :show]
  end
end
