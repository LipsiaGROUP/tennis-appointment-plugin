require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class OperatorsController < BackendController
    before_action :set_operator, only: [:show, :edit, :update, :destroy]
    before_action :set_active_page
    before_action :get_service_list, only: [:index, :edit]
    # GET /Operators
    def index
      authorize ::StecmsAppointment::Operator
      @collection = ::StecmsAppointment::Operator.all
      @operator = ::StecmsAppointment::Operator.new
      @current_service_ids = @operator.service_ids

      (0..6).each do |day_index|
        @operator.operator_hours.build({ day: day_index })
      end
    end

    # GET /Operators/1
    def show
    end

    # GET /Operators/new
    def new
      @operator = ::StecmsAppointment::Operator.new
      authorize @operator
    end

    # GET /Operators/1/edit
    def edit
      operator_hours = @operator.operator_hours
      @current_service_ids = @operator.service_ids
      
      (0..6).each do |day_index|
        hour = operator_hours.detect { |hour| hour.day.eql? day_index }
        @operator.operator_hours.build({ day: day_index }) unless hour
      end
    end

    # POST /Operators
    def create
      @operator = ::StecmsAppointment::Operator.new(operator_params)
      authorize @operator
      @operator.status = 'active'
      if @operator.save
        redirect_to operators_url, notice: 'operator was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /Operators/1
    def update
      if @operator.update(operator_params)
        redirect_to operators_url, notice: 'operator was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /Operators/1
    def destroy
      @operator.destroy
      redirect_to operators_url, notice: 'operator was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_operator
        @operator = ::StecmsAppointment::Operator.find(params[:id])
        authorize @operator
      end

      def get_service_list
        @services = ::StecmsAppointment::Service.all
      end

      # Only allow a trusted parameter "white list" through.
      def operator_params
        params.require(:operator).permit(:id, :operator_name, :mobile, :email, :operator_active, :description, :avatar,
          operator_hours_attributes: [:id, :day, :h_start, :h_end, :h_start2, :h_end2, :is_active, :_destroy], service_ids: [])
      end

      def set_active_page
        @side_menu ||= "operators"
      end
  end
end
