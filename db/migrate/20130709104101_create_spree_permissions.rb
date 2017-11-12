class CreateSpreePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_permissions do |t|
      t.string :title, null: false, unique: true
      t.integer :priority, default: 0
      t.boolean :visible, :boolean, default: true

      t.timestamps null: false
    end

    add_index :spree_permissions, :visible
  end
end
