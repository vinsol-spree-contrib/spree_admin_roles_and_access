class CreateSpreePermissionSets < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_permission_sets do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end
