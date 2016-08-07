class ChangetimeTypeIntraveltimes < ActiveRecord::Migration
  def change
  	change_column :traveltimes, :time, :timestamp, :null => false
  end
end
