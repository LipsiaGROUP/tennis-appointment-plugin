require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class ServiceCategoriesController < BackendController
    before_action :set_service_category, only: [:show, :edit, :update, :destroy]
    before_action :set_active_page

    # GET /service_categories
    def index
      authorize ::StecmsAppointment::ServiceCategory
      @collection = ::StecmsAppointment::ServiceCategory.all
    end

    # GET /service_categories/1
    def show
    end

    # GET /service_categories/new
    def new
      @service_category = ::StecmsAppointment::ServiceCategory.new
      authorize @service_category
    end

    # GET /service_categories/1/edit
    def edit
    end

    # POST /service_categories
    def create
      @service_category = ::StecmsAppointment::ServiceCategory.new(service_category_params)
      authorize @service_category

      if @service_category.save
        redirect_to service_categories_url, notice: 'Service category was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /service_categories/1
    def update
      if @service_category.update(service_category_params)
        redirect_to service_categories_url, notice: 'Service category was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /service_categories/1
    def destroy
      @service_category.destroy
      redirect_to service_categories_url, notice: 'Service category was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_service_category
        @service_category = ::StecmsAppointment::ServiceCategory.find(params[:id])
        authorize @service_category
      end

      # Only allow a trusted parameter "white list" through.
      def service_category_params
        params.require(:service_category).permit(:title)
      end

      def set_active_page
        @side_menu ||= "service_categories"
      end
  end
end
