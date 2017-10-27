class AddTimeslot < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :timeslot, :string
  end
end
