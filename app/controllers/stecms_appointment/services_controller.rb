require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class ServicesController < BackendController
    before_action :set_service, only: [:show, :edit, :update, :destroy]
    before_action :setup_form, only: [:new, :edit]
    before_action :set_active_page
    # GET /services
    def index
      authorize ::StecmsAppointment::Service
      @collection = ::StecmsAppointment::Service.all
    end

    # GET /services/1
    def show
    end

    # GET /services/new
    def new
      @service = ::StecmsAppointment::Service.new
      authorize @service
    end

    # GET /services/1/edit
    def edit
      @discount_per_day = @service.discount_per_day
      @promo_ids_prices_per_day = @service.promo_ids_prices_per_day
    end

    # POST /services
    def create
      @service = ::StecmsAppointment::Service.new(service_params)
      authorize @service

      if @service.save
        redirect_to services_url, notice: 'Service was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /services/1
    def update
      if @service.update(service_params)
        redirect_to services_url, notice: 'Service was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /services/1
    def destroy
      @service.destroy
      redirect_to services_url, notice: 'Service was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_service
        @service = ::StecmsAppointment::Service.find(params[:id])
        authorize @service
      end

      def setup_form
        @service_categories = ::StecmsAppointment::ServiceCategory.all
        @active_treatments = ::StecmsAppointment::Service.all
        @operators = ::StecmsAppointment::Operator.all
        @current_operator_ids = params[:action] == "new" ? [] : @service.operator_ids
      end

      # Only allow a trusted parameter "white list" through.
      def service_params
        params[:service][:operator_ids] ||= []
        promotion_params = params.require(:service).permit(
          :stecms_appointment_service_category_id, :title, :description, :status, :book_online,
          :price, :duration, :discount_value, :discount_price, :discount_valid_from, :discount_valid_to, :discount_public_from, :pause_time_minutes,
          :discount_public_to, :promo_variant, :is_composed, :preferred, {operator_ids: []}, composed_treatments_attributes: [:id, :stecms_appointment_service_id, :service_parent_id, :pause_time_minutes, :_destroy],
           promotions_attributes: [:id, :standard_promotion_id, :short_hair_promotion_id,
          :long_hair_promotion_id, :day, :is_active, :discount_type, :discount_value, :discount_price, :short_price,
          :discount_short_price, :long_price, :discount_long_price, :discount_valid_from, :discount_valid_to, :_destroy]
        )

        if promotion_params[:promotions_attributes].present?
          promotion_params[:promotions_attributes].keep_if { |param| param[:is_active].present? && param[:discount_value].present? }
          promotion_params[:promotions_attributes]
        end

        promotion_params
      end

      def set_active_page
        @side_menu ||= "services"
      end
  end
end
