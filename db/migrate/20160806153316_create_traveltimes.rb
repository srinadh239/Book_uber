class CreateTraveltimes < ActiveRecord::Migration
  def change
    create_table :traveltimes do |t|
      t.float :source_latitude
      t.float :source_longitude
      t.float :destination_latitude
      t.float :destination_longitude
      t.datetime :time
      t.string :email

      t.timestamps null: false
    end
  end
end
