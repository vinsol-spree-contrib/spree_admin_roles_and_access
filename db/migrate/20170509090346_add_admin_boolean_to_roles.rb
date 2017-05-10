class AddAdminBooleanToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_roles, :admin_accessible, :boolean, default: false
  end
end
