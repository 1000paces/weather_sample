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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_132211) do
  create_table "forecasts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "current"
    t.json "extended"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["zip_code"], name: "index_forecasts_on_zip_code", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.json "geolocation"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["zip_code"], name: "index_locations_on_zip_code"
  end
end
