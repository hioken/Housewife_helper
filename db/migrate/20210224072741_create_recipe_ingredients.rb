class CreateRecipeIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true, index: false
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.integer :amount, null: false

      t.timestamps
    end
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
  end
end
