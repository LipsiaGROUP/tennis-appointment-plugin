require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class BusinessHoursController < BackendController
    before_action :set_active_page
    
    def index
      authorize ::StecmsAppointment::BusinessHour
      @setting = ::StecmsAppointment::Setting.last

      business_hours = @setting.business_hours

      (0..6).each do |day_index|
        hour = business_hours.detect { |hour| hour.day.eql? day_index }
        @setting.business_hours.build({ day: day_index }) unless hour
      end

      @setting.business_hours.order(:day)
    end
    
    def update
      authorize ::StecmsAppointment::BusinessHour

      setting = ::StecmsAppointment::Setting.find(params[:id])
      prms = params[:setting][:business_hours_attributes].map{|x| x[1]}
      prms.each{ |x| x[:active] = (x[:active] == "1") }
      params[:setting][:business_hours_attributes] = []
      params[:setting][:business_hours_attributes] = prms
      params[:setting][:id] = setting.id

      if setting.update_attributes(bussines_hour_params)
        redirect_to business_hours_url, notice: 'Business Hour was successfully updated.'
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def bussines_hour_params
        params.require(:setting).permit(:id, business_hours_attributes: [:id, :day, :h_start, :h_end, :h_start2, :h_end2, :is_active, :active, :_destroy])
      end

      def set_active_page
        @side_menu ||= "open_hours"
      end
  end
end