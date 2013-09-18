module Spree
  Ability.class_eval do

    def initialize(user)
      self.clear_aliased_actions

      alias_action :edit, :to => :update
      alias_action :new, :to => :create
      alias_action :new_action, :to => :create
      alias_action :show, :to => :read
      alias_action :delete, :to => :destroy

      user ||= Spree::User.new

      user_roles(user).each do |role|
        ability(role, user)
      end

      Ability.abilities.each do |clazz|
        ability = clazz.send(:new, user)
        @rules = rules + ability.send(:rules)
      end
    end

    def user_roles(user)
      (roles = user.roles.includes(:permissions)).empty? ? Spree::Role.default_role.includes(:permissions) : roles
    end

    def ability(role, user)
      role.ability(self, user)
    end
  end
end