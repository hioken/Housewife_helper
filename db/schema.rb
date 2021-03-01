# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_01_194346) do

  create_table "end_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_name", default: "kenta", null: false
    t.integer "family_size", default: 2, null: false
    t.integer "cooking_time_limit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_end_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_end_users_on_reset_password_token", unique: true
  end

  create_table "fridge_items", force: :cascade do |t|
    t.integer "end_user_id", null: false
    t.integer "ingredient_id", null: false
    t.integer "amount", null: false
    t.integer "mark"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["end_user_id", "ingredient_id"], name: "index_fridge_items_on_end_user_id_and_ingredient_id", unique: true
  end

  create_table "ingredients", id: :bigint, default: nil, force: :cascade do |t|
    t.string "name", null: false
    t.integer "unit", null: false
    t.integer "html_color", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "ingredient_id", null: false
    t.integer "amount", null: false
    t.integer "mark"
    t.integer "seasoning_unit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cooking_time", null: false
    t.boolean "is_old", default: false, null: false
    t.integer "new_menu_recode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_menus", force: :cascade do |t|
    t.integer "end_user_id", null: false
    t.integer "recipe_id", null: false
    t.date "cooking_date", null: false
    t.integer "sarve", null: false
    t.boolean "is_cooked", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["end_user_id"], name: "index_user_menus_on_end_user_id"
  end

  add_foreign_key "fridge_items", "end_users"
  add_foreign_key "fridge_items", "ingredients"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "user_menus", "end_users"
  add_foreign_key "user_menus", "recipes"
end
