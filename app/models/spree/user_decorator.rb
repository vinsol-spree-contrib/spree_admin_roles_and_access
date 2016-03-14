module Spree
  Spree.user_class.class_eval do
    has_many :spree_role_users, class_name: 'Spree::RoleUser'
    has_many :roles, through: :spree_role_users, class_name: 'Spree::Role'
  end
end
