module StecmsAppointment
	module Api
	  class ServicesController < ApiController

	  	def index
	  		@services = ::StecmsAppointment::Service.active
	  	end

	  	def show
	  		@service = ::StecmsAppointment::Service.find(params[:id])
	  	end

	  	def price
        service = ::StecmsAppointment::Service.find(params[:id])
        render json: {id: service.id, price: service.price, discount_price: service.show_price(params[:when]).last}
      end

	  end
	end
end
