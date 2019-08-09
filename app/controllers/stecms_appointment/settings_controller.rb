require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class SettingsController < BackendController
    before_action :set_active_page

    def index
    	authorize ::StecmsAppointment::Setting
    	@setting = ::StecmsAppointment::Setting.last
    end

    def update
    	setting = ::StecmsAppointment::Setting.find(params[:id])
      authorize setting
      if setting.update_attributes(setting_params)
        redirect_to settings_url, notice: 'Setting was successfully updated.'
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def setting_params
        params.require(:setting).permit(:id, :paypal_email, 
        	:time_slots_granularity, :paypal_clientid, :calendar_blocktime_colore, 
        	:calendar_specialcategory_colore, :calendar_treatment_colore, 
        	:booking_next_fifteen, :rounding, accepted_payment_options: [])
      end

      def set_active_page
        @side_menu ||= "setting"
      end

  end

end