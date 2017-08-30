class ChangeTimeslotToInteger < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :timeslot, :integer
  end
end
