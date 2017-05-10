class RemoveColumnBooleanFromPermissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :spree_permissions, :boolean, :boolean, default: true
  end
end
