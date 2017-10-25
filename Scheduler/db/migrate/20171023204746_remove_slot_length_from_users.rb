class RemoveSlotLengthFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :slot_length, :integer
  end
end
