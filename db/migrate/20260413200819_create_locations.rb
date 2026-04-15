class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :address
      t.string :zip_code
      t.decimal :latitude
      t.decimal :longitude
      t.json :geolocation # I would use jsonb here in a production setting, but sqlite3 doesn't seem to support it.

      t.timestamps
    end

    add_index :locations, :zip_code
  end
end
