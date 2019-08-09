class CreateStecmsAppointmentBookings < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_bookings do |t|
      t.integer :start_time
      t.integer :end_time
      t.string :status
      t.string :from_where
      t.string :number
      t.float :price, default: 0
      t.string :discount_type
      t.float :discount_value, default: 0
      t.float :discount_price, default: 0
      t.integer :duration, default: 0
      t.string :title
      t.string :note
      t.boolean :is_composed_treatment, default: false
      t.references :stecms_appointment_service

      t.timestamps null: false
    end
  end
end
