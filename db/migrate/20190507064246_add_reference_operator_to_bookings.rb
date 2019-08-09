class AddReferenceOperatorToBookings < ActiveRecord::Migration
  def change
  	add_reference :stecms_appointment_bookings, :stecms_appointment_operator
  end
end
