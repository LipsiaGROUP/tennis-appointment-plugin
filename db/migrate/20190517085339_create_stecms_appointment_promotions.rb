class CreateStecmsAppointmentPromotions < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_promotions do |t|
      t.integer :day
      t.float :price
      t.string :discount_type
      t.float :discount_value
      t.float :discount_price
      t.references :stecms_appointment_service
      t.references :stecms_appointment_variant
      t.datetime :discount_valid_from
      t.datetime :discount_valid_to

      t.timestamps null: false
    end
  end
end
