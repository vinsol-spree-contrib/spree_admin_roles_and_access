class CreateSpreePermissionsPermissionSets < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_permissions_permission_sets do |t|
      t.references :permission, index: true
      t.references :permission_set, index: true
      t.foreign_key :spree_permissions, column: :permission_id
      t.foreign_key :spree_permission_sets, column: :permission_set_id
    end
  end
end
