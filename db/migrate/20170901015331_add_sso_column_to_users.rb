class AddSsoColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sso, :text
  end
end
