class AddAdminBooleanToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_roles, :admin_accessible, :boolean, default: false
  end
end
