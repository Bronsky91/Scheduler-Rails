class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.integer :timeslot
      t.integer :redtailid
      t.string :link

      t.timestamps
    end
  end
end
