class CreateSpreeRolesPermissionSets < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_roles_permission_sets do |t|
      t.references :role, index: true
      t.references :permission_set, index: true
      t.foreign_key :spree_roles, column: :role_id
      t.foreign_key :spree_permission_sets, column: :permission_set_id
    end
  end
end
