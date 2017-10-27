class ChangeTimeslotToInteger < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :timeslot, :text
  end
end
