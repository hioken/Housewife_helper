class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.integer :cooking_time, null: false
      t.boolean :is_old, null: false, default: false
      t.integer :new_menu_recode

      t.timestamps
    end
  end
end
