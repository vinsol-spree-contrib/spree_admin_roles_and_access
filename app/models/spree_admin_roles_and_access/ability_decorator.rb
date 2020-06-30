module SpreeAdminRolesAndAccess
  module AbilityDecorator
    def initialize(user)
      self.clear_aliased_actions

      alias_action :edit, to: :update
      alias_action :new, to: :create
      alias_action :new_action, to: :create
      alias_action :show, to: :read
      alias_action :index, to: :read
      alias_action :delete, to: :destroy

      user ||= Spree.user_class.new

      user_roles(user).map(&:permissions).flatten.uniq.map { |permission| permission.ability(self, user) }

      ::Spree::Ability.abilities.each do |clazz|
        ability = clazz.send(:new, user)
        @rules = rules + ability.send(:rules)
      end
    end

    def user_roles(user)
      (roles = user.roles.includes(:permissions)).empty? ? Spree::Role.default_role.includes(:permissions) : roles
    end
  end
end

Spree::Ability.prepend SpreeAdminRolesAndAccess::AbilityDecorator