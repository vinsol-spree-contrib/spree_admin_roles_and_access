class RemoveColumnBooleanFromPermissions < SpreeExtension::Migration[4.2]
  def change
    remove_column :spree_permissions, :boolean, :boolean, default: true
  end
end
