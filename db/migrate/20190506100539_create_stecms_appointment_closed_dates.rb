class CreateStecmsAppointmentClosedDates < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_closed_dates do |t|
      t.integer :start
      t.integer :end
      t.string :description
      t.string :status

      t.timestamps null: false
    end
  end
end
