class DeprecateLegacyRolesAndPermissions < ActiveRecord::Migration[4.2]
  def display_warning
    ActiveSupport::Deprecation.warn('Direct relationship between roles and permissions is deprecated. Use #legacy_permissions to access old permissions')
  end

  def up
    display_warning
    ActiveSupport::Deprecation.warn('Creating Permission Sets from roles')
    Spree::Role.find_each do |role|
      permission_set = Spree::PermissionSet.where(name: role.name).first_or_create!
      role_permissions = role.legacy_permissions
      if role_permissions.present?
        role_permissions.each do |permission|
          permission_set.permissions << permission unless permission_set.permissions.include? permission
        end

        if permission_set.permissions.present?
          permission_set.save!
          role.permission_sets << permission_set
        end
      end
    end
  end

  def down
    display_warning
    ActiveSupport::Deprecation.warn('Cannot undo creation of permission sets, Down is treated as a NOOP')
  end
end
