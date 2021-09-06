module Spree
  module RoleDecorator

    def self.prepended(base)
      base.has_many :roles_permission_sets, dependent: :destroy
      base.has_many :permission_sets, through: :roles_permission_sets
      base.has_many :permissions, through: :permission_sets

      # DEPRECATED: Use permission sets instead. Only here for aiding migration for existing users
      base.has_and_belongs_to_many :legacy_permissions, join_table: 'spree_roles_permissions', class_name: 'Spree::Permission'

      base.validates :name, uniqueness: true, allow_blank: true
      base.validates :permission_sets, length: { minimum: 1, too_short: :atleast_one_permission_set_is_required }, on: :update
    end  

    def has_permission?(permission_title)
      permissions.pluck(:title).include?(permission_title)
    end

  end  
end
Spree::Role.prepend Spree::RoleDecorator