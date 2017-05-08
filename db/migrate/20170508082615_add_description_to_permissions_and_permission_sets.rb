class AddDescriptionToPermissionsAndPermissionSets < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_permissions, :description, :string, default: ''
    add_column :spree_permission_sets, :description, :string, default: ''
  end
end
