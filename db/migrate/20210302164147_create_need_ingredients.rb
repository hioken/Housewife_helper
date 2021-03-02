class CreateNeedIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :need_ingredients do |t|
      t.references :end_user, null: false, foreign_key: true, index: false
      t.references :ingredient_id, null: false, foreign_key: true, index: false
      t.integer :amount, null: false

      t.timestamps
    end
    add_index :need_ingredients, [:end_user_id, :ingredient_id], unique: true
  end
end
