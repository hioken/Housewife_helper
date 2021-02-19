class CreateFridgeItems < ActiveRecord::Migration[6.1]
  def change
    create_table :fridge_items do |t|
      t.references :end_user, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
