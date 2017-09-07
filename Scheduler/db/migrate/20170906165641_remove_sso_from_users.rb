class RemoveSsoFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :sso, :text
  end
end
