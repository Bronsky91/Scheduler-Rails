class RemoveTimeslotFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :timeslot, :integer
  end
end
