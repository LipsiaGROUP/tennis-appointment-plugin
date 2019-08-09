require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class ClosedDatesController < BackendController
    before_action :set_closed_date, only: [:show, :edit, :update, :destroy]
    before_action :set_active_page
    # GET /ClosedDates
    def index
      authorize ::StecmsAppointment::ClosedDate
      @collection = ::StecmsAppointment::ClosedDate.all
    end

    # GET /ClosedDates/1
    def show
    end

    # GET /ClosedDates/new
    def new
      @closed_date = ::StecmsAppointment::ClosedDate.new
      authorize @closed_date
    end

    # GET /ClosedDates/1/edit
    def edit
    end

    # POST /ClosedDates
    def create
      @closed_date = ::StecmsAppointment::ClosedDate.new(closed_date_params)
      authorize @closed_date
      
      if @closed_date.save
        redirect_to closed_dates_url, notice: 'ClosedDate was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ClosedDates/1
    def update
      if @closed_date.update(closed_date_params)
        redirect_to closed_dates_url, notice: 'ClosedDate was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ClosedDates/1
    def destroy
      @closed_date.destroy
      redirect_to closed_dates_url, notice: 'ClosedDate was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_closed_date
        @closed_date = ::StecmsAppointment::ClosedDate.find(params[:id])
        authorize @closed_date
      end

      # Only allow a trusted parameter "white list" through.
      def closed_date_params
        current_params = params.require(:closed_date).permit(:start, :end, :description)
        current_params[:start] = Time.parse(current_params[:start]).to_i
        current_params[:end] = Time.parse(current_params[:end]).to_i
        current_params
      end

      def set_active_page
        @side_menu ||= "closed_dates"
      end
  end
end
