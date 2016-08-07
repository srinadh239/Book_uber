class ChangeTimeFormatIntraveltimes < ActiveRecord::Migration
  def change
  	change_column :traveltimes, :time, :string
  end
end
