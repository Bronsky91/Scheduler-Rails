class AddSlotlengthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :slot_length, :integer
  end
end
