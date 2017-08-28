class CreateAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :appointments do |t|
      t.integer :ownerid
      t.datetime :datetime
      t.boolean :allday
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
