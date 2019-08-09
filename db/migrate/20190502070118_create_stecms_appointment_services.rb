class CreateStecmsAppointmentServices < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_services do |t|
      t.string :title
      t.integer :duration, default: 0
      t.float :price, default: 0
      t.string :discount_type
      t.string :discount_value
      t.float :discount_price, default: 0
      t.datetime :discount_valid_from
      t.datetime :discount_valid_to
      t.integer :order_number, default: 1
      t.boolean :active, default: true
      t.references :stecms_appointment_service_category

      t.timestamps null: false
    end
  end
end
