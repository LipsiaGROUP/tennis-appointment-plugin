class SetupComposedServices < ActiveRecord::Migration
  def change
  	create_table :stecms_appointment_composed_services do |t|
      t.integer :service_parent_id
      t.references :stecms_appointment_service
      t.integer :pause_time_minutes, default: 0
      t.timestamps null: false
    end

    add_column :stecms_appointment_services, :pause_time_minutes, :integer
  end
end
