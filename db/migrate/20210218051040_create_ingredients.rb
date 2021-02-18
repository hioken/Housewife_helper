class CreateIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :ingredients, id: false do |t|
      t.column :id, 'int(4) PRIMARY KEY'
      t.string :name, null: false
      t.integer :unit, null: false
      t.integer :html_color, null: false

      t.timestamps
    end
  end
end
