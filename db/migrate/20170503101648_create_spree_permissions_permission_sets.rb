class CreateSpreePermissionsPermissionSets < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_permissions_permission_sets do |t|
      t.references :permission, index: true, foreign_key: { to_table: :spree_permissions }
      t.references :permission_set, index: true, foreign_key: { to_table: :spree_permission_sets }
    end
  end
end
