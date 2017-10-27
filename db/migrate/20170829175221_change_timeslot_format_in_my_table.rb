class ChangeTimeslotFormatInMyTable < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :timeslot, :text
  end
end
