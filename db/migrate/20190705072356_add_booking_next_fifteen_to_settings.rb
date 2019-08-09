class AddBookingNextFifteenToSettings < ActiveRecord::Migration
  def change
  	add_column :stecms_appointment_settings, :booking_next_fifteen, :boolean, default: false
  	add_column :stecms_appointment_settings, :rounding, :integer, default: 1800
  end
end
