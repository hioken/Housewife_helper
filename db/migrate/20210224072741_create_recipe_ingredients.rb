class CreateRecipeIngredients < ActiveRecord::Migration[6.0]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.integer :amount, null: false
      t.integer :mark
      t.integer :seasoning_unit

      t.timestamps
    end
  end
end
