class RemoveLinkFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :link, :string
  end
end
