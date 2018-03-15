class AddDisplayBooleanToPermissionSets < ActiveRecord::Migration
  def change
    add_column :spree_permission_sets, :display_permission, :boolean, default: false
  end
end
