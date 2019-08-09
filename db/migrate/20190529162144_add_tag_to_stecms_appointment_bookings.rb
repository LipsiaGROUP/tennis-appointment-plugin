class AddTagToStecmsAppointmentBookings < ActiveRecord::Migration
  def change
  	add_column :stecms_appointment_bookings, :tag, :string, default: 'bookonline'
  end
end
