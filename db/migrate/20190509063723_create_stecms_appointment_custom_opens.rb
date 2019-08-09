class CreateStecmsAppointmentCustomOpens < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_custom_opens do |t|
      t.integer :start_date
      t.integer :end_date
      t.string :time_open
      t.string :time_closed

      t.timestamps null: false
    end
  end
end
