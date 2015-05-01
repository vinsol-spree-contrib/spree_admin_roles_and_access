Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :roles, :except => [:show, :destroy]
  end
end
