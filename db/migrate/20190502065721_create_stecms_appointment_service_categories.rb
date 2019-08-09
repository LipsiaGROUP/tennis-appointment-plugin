class CreateStecmsAppointmentServiceCategories < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_service_categories do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
