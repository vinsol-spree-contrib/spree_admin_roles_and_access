module Spree
  class RolesPermissionSet < ActiveRecord::Base
    belongs_to :role
    belongs_to :permission_set
  end
end
