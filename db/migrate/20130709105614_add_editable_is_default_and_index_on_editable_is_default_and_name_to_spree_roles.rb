class AddEditableIsDefaultAndIndexOnEditableIsDefaultAndNameToSpreeRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_roles, :editable, :boolean, default: true
    add_column :spree_roles, :is_default, :boolean, default: false

    add_index(:spree_roles, :is_default)
    add_index(:spree_roles, :editable)
  end
end
