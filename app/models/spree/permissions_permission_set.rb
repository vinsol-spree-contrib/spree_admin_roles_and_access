module Spree
  class PermissionsPermissionSet < ActiveRecord::Base
    belongs_to :permission
    belongs_to :permission_set, touch: true
  end
end
