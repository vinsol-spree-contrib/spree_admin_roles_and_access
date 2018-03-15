class AddAdminBooleanToRoles < ActiveRecord::Migration
  def change
    add_column :spree_roles, :admin_accessible, :boolean, default: false
  end
end
