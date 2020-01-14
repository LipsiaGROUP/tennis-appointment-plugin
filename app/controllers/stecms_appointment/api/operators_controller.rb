module StecmsAppointment
	module Api
	  class OperatorsController < ApiController

	  	def available_for_treatments
	  		treatment_list = []
			treatments_param = params[:treatments]
			treatments_param.each do |param|
				# operators = ::StecmsAppointment::Operator.get_available_operators_for_treatment(param, params[:when])
				
				treatment_data = {
					treatment_id: param[:treatment_id],
					duration: ::StecmsAppointment::Service.find(param[:treatment_id]).duration
				  }

				operators = ::StecmsAppointment::Operator.get_available_operators_for_treatment(treatment_data, params[:when])
				
				treatment_list << {treatment_id: param["treatment_id"], operators: operators}
			end
        	render json: {operators: treatment_list}
	  	end

	  	def index
	  		@operators = Operator.select(:id, :operator_name, :avatar, :description).where(status: 'active', operator_active: 1)
      end

	  end
	end
end