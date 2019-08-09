require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class BookingsController < BackendController
    before_action :set_booking, only: [:show, :edit, :update, :destroy, 
      :update_status, :confirm_delete, :drag_and_drop, :drag_and_drop_busy_time, :delete_busy_time, :edit_busy_time, :update_busy_time]
    before_action :set_active_page
    before_action :setup_form, only: [:new, :edit]

    # GET /bookings
    def index
      authorize ::StecmsAppointment::Booking
    end

    def calendar
      authorize ::StecmsAppointment::Booking
      date_start = params[:start].to_date.to_time.to_i
      cookies[:start_calendar] = date_start
      date_end = params[:end].to_date.to_time.to_i
      calendar_bookings_hashes = ::StecmsAppointment::Booking.get_calendar_bookings(date_start, date_end,
        params[:employee_id])

      operators_schedules_hashes = ::StecmsAppointment::Operator.get_operators_schedules_hashes(date_start)

      puts operators_schedules_hashes

      if calendar_bookings_hashes.present?
        calendar_bookings_hashes << operators_schedules_hashes
        render json: calendar_bookings_hashes
      else
        render json: [operators_schedules_hashes]
      end
    end

    def agenda
      authorize ::StecmsAppointment::Booking
      operators_hashes =
        if params[:id].to_i.zero?
          ::StecmsAppointment::Operator.active.get_id_and_name_hashes
        else
          ::StecmsAppointment::Operator.active.get_id_and_name_by_operator_hashes(params[:id])
        end

      render json: operators_hashes
    end

    def get_updates
      authorize ::StecmsAppointment::Booking
      @new_booking_events_hashes = ::StecmsAppointment::Booking.new_events_hashes(params[:interval], params[:resource_view],
        params[:calendar_date], params[:employee_id])

      @new_removed_events_hashes = ::StecmsAppointment::Booking.new_removed_events_hashes(params[:interval], params[:resource_view],
        params[:calendar_date], params[:employee_id])
    end

    # GET /bookings/1
    def show
    end

    # GET /bookings/new
    def new
      @action_url = bookings_url
      @booking = ::StecmsAppointment::Booking.new(schedule_time: params[:time])
      authorize @booking
    end

    # GET /bookings/1/edit
    def edit
      @customer = @booking.user
      @action_url = booking_url(@booking)
      @customer_hash = @customer.convert_to_hashes.to_json.html_safe if @customer
    end

    # POST /bookings
    def create
      duration, price =
        if @variant
          [@variant.duration, @variant.price]
        else
          service = ::StecmsAppointment::Service.select(:duration, :price).find(booking_params[:stecms_appointment_service_id])
          [service.try(:duration), service.try(:price)]
        end

      end_time = booking_params[:start_time] + duration.to_i.seconds
      merge_booking_params = booking_params.merge({ end_time: end_time, duration: duration, price: price })

      merge_booking_params.delete(:schedule_time)
      merge_booking_params.delete(:variant_id)

      booking = ::StecmsAppointment::Booking.new(merge_booking_params)
      authorize booking

      respond_to do |format|
        composed_booking = booking.verify_composed_booking
        if booking.valid?
          booking.save

          if composed_booking[:composed]
            composed_booking[:result].each do |compose_booking_attr|
              compose_booking_attr.delete('ancestry')
              booking.children.create(compose_booking_attr)
            end
            booking.is_composed_treatment = true
            booking.save

            @booking_event_hash = []
            bookings =  Booking.with_joined_tables.where('stecms_appointment_bookings.id IN (?)', booking.children.pluck(:id))
            bookings.each { |obj| @booking_event_hash << obj.generate_event_hash(true) }
          else
            booking_with_info = ::StecmsAppointment::Booking.with_joined_tables.where('stecms_appointment_bookings.id = ?', booking.id).first
            @booking_event_hash = booking_with_info.generate_event_hash
            
          end
          format.js
        else
          @error_messages = booking.errors.full_messages.join(", ")
          format.js
        end
      end
    end

    # PATCH/PUT /bookings/1
    def update
      respond_to do |format|
        if @booking.update(booking_params)
          booking_with_info = Booking.with_joined_tables.where(id: @booking.id).first
          @booking_event_hash = booking_with_info.generate_event_hash(true)
          format.js
        else
          format.js
        end
      end
    end

    def update_status
      respond_to do |format|
        if params[:status].eql?('noshow') && (Time.now.to_i < @booking.end)
          format.js { render js: 'alertStatusNoShow()' }
        else
          if @booking.update_attributes(status: params[:status])
            booking_with_info = Booking.with_joined_tables.where(id: @booking.id).first
            @booking_event_hash = booking_with_info.generate_event_hash(true)
            format.js
          else
            format.js
          end
        end
      end
    end

    def drag_and_drop
      if @booking.update_attributes(booking_params_dragged)
        render json: true
      else
        render json: @booking.errors.full_messages.join(", ")
      end
    end

    # Change blocked time after drag and drop blocked time panel on agenda
    #
    def drag_and_drop_busy_time
      if @booking.update_attributes(busy_time_params_dragged)
        render json: true
      else
        render json: false
      end
    end

    def new_busy_time
      @operators = ::StecmsAppointment::Operator.all
      @busy_time = ::StecmsAppointment::Booking.new

      authorize @busy_time
    end

    # create schedule block time on agenda
    #
    def edit_busy_time
      @operators = ::StecmsAppointment::Operator.all
      @busy_time = @booking
    end

    # create schedule block time on agenda
    #
    def create_busy_time
      busy_time = ::StecmsAppointment::Booking.new(busy_time_params)
      authorize busy_time

      if busy_time.save
        @busy_time_event_hash = busy_time.generate_event_hash
      end
    end

    # update schedule block time on agenda
    #
    def update_busy_time
      if @booking.update_attributes(busy_time_params)
        @busy_time_event_hash = @booking.generate_event_hash
      end
    end

    # delete schedule block time on agenda
    #
    def delete_busy_time
      @busy_time_id = params[:id]
      ::StecmsAppointment::Booking.where(id: params[:id]).update_all(status: 'cancelled')
    end

    # DELETE /bookings/1
    # Delete booking schedule on agenda
    #
    def confirm_delete
      des_treatment, operator_name = [@booking.service.try(:title), @booking.operator.try(:operator_name)]
      start_date, start_time = [@booking.start_date.strftime('%d/%m/%Y'), @booking.start_date.strftime('%H:%M')]
      @description_extended = "#{des_treatment} con #{operator_name} in data #{start_date} ore #{start_time}"
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_booking
        @booking = ::StecmsAppointment::Booking.find(params[:id])
        authorize @booking
      end

      def setup_form
        @new_customer = Customer.new
        @operators = ::StecmsAppointment::Operator.all
        @service_categories = ::StecmsAppointment::Service.all
      end

      def busy_time_params_dragged
        current_params = params.require(:employee_schedule_status).permit(:busy_date_start, :"busy_time_start(5i)",
          :"busy_time_end(5i)", :employee_id)

        start_time = Time.parse("#{current_params[:busy_date_start]} #{current_params[:"busy_time_start(5i)"]}").to_i
        end_time = Time.parse("#{current_params[:busy_date_start]} #{current_params[:"busy_time_end(5i)"]}").to_i

        current_params.replace({
          stecms_appointment_operator_id: current_params[:employee_id],
          start_time: start_time,
          end_time: end_time,
        })
      end

      def busy_time_params
        current_params = params.require(:booking).permit(:schedule_date, :start_time, :end_time, :stecms_appointment_operator_id, :note)
        date = current_params.delete(:schedule_date)
        current_params[:start_time] = Time.parse("#{string_to_date(date)} #{current_params[:start_time]}")
        current_params[:end_time] = Time.parse("#{string_to_date(date)} #{current_params[:end_time]}")
        current_params[:duration] = current_params[:end_time] - current_params[:start_time]
        current_params.merge({from_where: 'mio', status: 'employeeBusyTime', tag: 'busyTime' })
      end

      # Only allow a trusted parameter "white list" through.
      def booking_params
        current_params = params.require(:booking).permit(:stecms_appointment_operator_id, :start_time, :stecms_appointment_service_id, :status, :note,
          :variant_id, :stecms_appointment_customer_id, :schedule_time)

        start_time =
          if current_params[:start_time]
            date_and_time = "#{string_to_date(current_params[:start_time])} #{params[:booking][:schedule_time]}"
            Time.parse(date_and_time).to_i
          else
            nil
          end

        user_id = current_params[:stecms_appointment_customer_id] ? current_params[:stecms_appointment_customer_id] : ''

        current_params.merge(
          start_time: start_time,
          from_where: 'admin',
          stecms_appointment_customer_id: user_id
        )
      end

      def booking_params_dragged
        current_params = params.require(:service_booking).permit(:schedule_date, :schedule_time,
          :schedule_time_end, :employee_id, :service_id)

        start_time = Time.parse("#{current_params[:schedule_date]} #{current_params[:schedule_time]}").to_i
        end_time = Time.parse("#{current_params[:schedule_date]} #{current_params[:schedule_time_end]}").to_i

        current_params.replace({
          stecms_appointment_operator_id: current_params[:employee_id],
          stecms_appointment_service_id: current_params[:service_id],
          start_time: start_time,
          end_time: end_time
        })
      end

      def set_active_page
        @side_menu ||= "bookings"
      end

      def string_to_date(str_date)
        date = str_date.titleize.split(', ').last()

        date.gsub!(/Gennaio|Febbraio|Marzo|Aprile|Maggio|Giugno|Luglio|luglio|Agosto|Settembre|Ottobre|Novembre|Dicembre/,
          'Gennaio' => 'January',
          'Febbraio' => 'February',
          'Marzo' => 'March',
          'Aprile' => 'April',
          'Maggio' => 'May',
          'Giugno' => 'June',
          'Luglio' => 'July',
          'Agosto' => 'August',
          'Settembre' => 'September',
          'Ottobre' => 'October',
          'Novembre' => 'November',
          'Dicembre' => 'December'
        )
      end
  end
end
