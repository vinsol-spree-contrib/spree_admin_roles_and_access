class CreateSpreePermissionSets < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_permission_sets do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end
