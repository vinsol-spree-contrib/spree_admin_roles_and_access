module Spree
  class Permission < ActiveRecord::Base
    include Permissions

    default_scope { order(:priority) }

    # DEPRECATED: Use permission sets instead only here for aiding migration for existing users
    has_and_belongs_to_many :legacy_roles, join_table: 'spree_roles_permissions', class_name: 'Spree::Role'

    has_many :permissions_permission_sets, dependent: :destroy
    has_many :permission_sets, through: :permissions_permission_sets

    validates :title, presence: true, uniqueness: true

    scope :visible, lambda { where(visible: true) }

    def ability(current_ability, user)
      send(title, current_ability, user)
    end

    def name
      title.gsub('-', '_').humanize
    end
  end
end
