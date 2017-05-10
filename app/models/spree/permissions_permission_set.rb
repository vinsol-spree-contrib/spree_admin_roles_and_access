module Spree
  class PermissionsPermissionSet < ActiveRecord::Base
    belongs_to :permission
    belongs_to :permission_set
  end
end
