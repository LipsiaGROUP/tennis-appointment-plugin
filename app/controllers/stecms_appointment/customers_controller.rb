require_dependency "stecms_appointment/application_controller"

module StecmsAppointment
  class CustomersController < BackendController
    before_action :set_customer, only: [:show, :edit, :update, :destroy]
    before_action :set_side_menu

    def search
      authorize Customer
      @customer = ::StecmsAppointment::Customer.search_customers(params[:term])
      render json: @customer, status: :ok
    end

    # GET /customers
    def index
      authorize Customer
      @customers = Customer.all.order("created_at DESC")
    end

    # GET /customers/1
    def show
      authorize @customer
    end

    # GET /customers/new
    def new
      @customer = Customer.new
      authorize @customer
    end

    # GET /customers/1/edit
    def edit
      authorize @customer
    end

    # POST /customers
    def create
      @customer = Customer.new(customer_params)
      authorize @customer

      if @customer.save
        redirect_to @customer, notice: 'Customer was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /customers/1
    def update
      authorize Customer
      if @customer.update(customer_params)
        redirect_to @customer, notice: 'Customer was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /customers/1
    def destroy
      authorize @customer
      @customer.destroy
      redirect_to customers_url, notice: 'Customer was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.

      def set_side_menu
        @side_menu = "customers"
      end

      def set_customer
        @customer = Customer.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def customer_params
        params.require(:customer).permit(:name, :email, :password, :cell, :gender, :birthday, :address, :city, :zip, :notes)
      end
    end
  end
