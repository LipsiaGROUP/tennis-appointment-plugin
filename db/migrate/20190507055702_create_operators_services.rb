class CreateOperatorsServices < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_operators_services do |t|
    	t.belongs_to :stecms_appointment_operator, index: {:name => "index_operators_services_on_operator_id"}
      t.belongs_to :stecms_appointment_service, index: {:name => "index_operators_services_on_service_id"}
    end
  end
end
