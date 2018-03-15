class RemoveColumnBooleanFromPermissions < ActiveRecord::Migration
  def change
    remove_column :spree_permissions, :boolean, :boolean, default: true
  end
end
