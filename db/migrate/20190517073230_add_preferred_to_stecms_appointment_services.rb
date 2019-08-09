class AddPreferredToStecmsAppointmentServices < ActiveRecord::Migration
  def change
  	add_column :stecms_appointment_services, :preferred, :boolean, default: false
  	add_column :stecms_appointment_services, :is_composed, :boolean, default: false
  	add_column :stecms_appointment_services, :description, :text
  end
end
