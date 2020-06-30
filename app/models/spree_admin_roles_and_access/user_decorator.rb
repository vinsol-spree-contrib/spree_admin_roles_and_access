module SpreeAdminRolesAndAccess
  module UserDecorator
    def self.prepended(base)
      base.alias_attribute :roles, :spree_roles
    end
  end
end

Spree.user_class.prepend SpreeAdminRolesAndAccess::UserDecorator