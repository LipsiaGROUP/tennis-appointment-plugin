class CreateStecmsAppointmentBusinessHours < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_business_hours do |t|
      t.string :h_end2
      t.string :h_start2
      t.string :h_end
      t.string :h_start
      t.string :day

      t.timestamps null: false
    end
  end
end
