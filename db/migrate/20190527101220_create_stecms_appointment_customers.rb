class CreateStecmsAppointmentCustomers < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_customers do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :cell
      t.string :gender
      t.string :birthday
      t.string :address
      t.string :city
      t.string :zip
      t.string :notes

      t.timestamps null: false
    end

    add_reference :stecms_appointment_bookings, :stecms_appointment_customer
  end
end
