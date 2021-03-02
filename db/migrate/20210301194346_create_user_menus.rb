class CreateUserMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :user_menus do |t|
      t.references :end_user, null: false, foreign_key: true, index: false
      t.references :recipe, null: false, foreign_key: true, index: false
      t.date :cooking_date, null: false
      t.integer :sarve, null: false
      t.boolean :is_cooked, null: false, default: false

      t.timestamps
    end
    add_index :user_menus, [:end_user_id, :cooking_date], unique: true
  end
end
