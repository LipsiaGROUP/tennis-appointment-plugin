class CreateStecmsAppointmentOperatorHours < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_operator_hours do |t|
      t.integer :day
      t.string :h_start
      t.string :h_end
      t.string :h_start2
      t.string :h_end2
      t.references :stecms_appointment_operator

      t.timestamps null: false
    end
  end
end
