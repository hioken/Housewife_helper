class CreateFridgeItems < ActiveRecord::Migration[6.1]
  def change
    create_table :fridge_items do |t|
      t.references :end_user, null: false, foreign_key: true, index: false
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.integer :amount, null: false
      t.integer :mark

      t.timestamps
    end
    add_index :fridge_items, [:end_user_id, :ingredient_id], unique: true
  end
end
