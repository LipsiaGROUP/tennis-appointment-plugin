class CreateStecmsAppointmentVariants < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_variants do |t|
      t.string :title
      t.string :duration
      t.float :price
      t.references :stecms_appointment_service
      t.string :discount_type
      t.float :discount_value
      t.float :discount_price
      t.datetime :discount_valid_from
      t.datetime :discount_valid_to
      t.datetime :discount_public_from
      t.datetime :discount_public_to

      t.timestamps null: false
    end
  end
end
