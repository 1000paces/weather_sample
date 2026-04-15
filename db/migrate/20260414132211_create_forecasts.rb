class CreateForecasts < ActiveRecord::Migration[8.1]
  def change
    create_table :forecasts do |t|
      t.string :zip_code
      t.json :current
      t.json :extended

      t.timestamps
    end

    add_index :forecasts, :zip_code, unique: true
  end
end
