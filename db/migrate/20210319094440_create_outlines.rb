class CreateOutlines < ActiveRecord::Migration[6.1]
  def change
    create_table :outlines do |t|
      t.date :today, null: false
      t.integer :user, null: false

      t.timestamps
    end
  end
end
