module Spree
  Spree.user_class.class_eval do
    alias_attribute :roles, :spree_roles
  end
end
