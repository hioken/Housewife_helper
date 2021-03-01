class CreateUserMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :user_menus do |t|
      t.references :end_user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true, index: false
      t.date :cooking_date, null: false
      t.integer :sarve, null: false
      t.boolean :is_cooked, null: false, default: false

      t.timestamps
    end
  end
end
