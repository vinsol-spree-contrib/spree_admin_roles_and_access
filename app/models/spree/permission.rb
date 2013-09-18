module Spree
  class Permission < ActiveRecord::Base
    include Permissions

    attr_accessible :title, :priority

    default_scope order(:priority)

    has_and_belongs_to_many :roles, :join_table => 'spree_roles_permissions', :class_name => 'Spree::Role'

    validates :title, :presence => true, :uniqueness => true

    scope :visible, where(:visible => true)

    def ability(current_ability, user)
      send(title, current_ability, user)
    end
  end
end