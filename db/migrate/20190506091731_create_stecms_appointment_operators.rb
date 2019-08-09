class CreateStecmsAppointmentOperators < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_operators do |t|
      t.string :operator_name
      t.integer :operator_active, default: 1
      t.string :status
      t.string :mobile
      t.string :email
      t.string :gender
      t.string :avatar
      t.string :description

      t.timestamps null: false
    end
  end
end
