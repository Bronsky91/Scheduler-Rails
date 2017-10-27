class AddUserkeyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :userkey, :string
  end
end
