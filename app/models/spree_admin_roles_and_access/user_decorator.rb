module SpreeAdminRolesAndAccess
  module UserDecorator
    alias_attribute :roles, :spree_roles
  end
end

Spree::User.prepend SpreeAdminRolesAndAccess::UserDecorator