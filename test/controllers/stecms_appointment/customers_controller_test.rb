require 'test_helper'

module StecmsAppointment
  class CustomersControllerTest < ActionController::TestCase
    setup do
      @customer = stecms_appointment_customers(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:customers)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create customer" do
      assert_difference('Customer.count') do
        post :create, customer: { address: @customer.address, birthday: @customer.birthday, cell: @customer.cell, city: @customer.city, email: @customer.email, gender: @customer.gender, name: @customer.name, notes: @customer.notes, password: @customer.password, zip: @customer.zip }
      end

      assert_redirected_to customer_path(assigns(:customer))
    end

    test "should show customer" do
      get :show, id: @customer
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @customer
      assert_response :success
    end

    test "should update customer" do
      patch :update, id: @customer, customer: { address: @customer.address, birthday: @customer.birthday, cell: @customer.cell, city: @customer.city, email: @customer.email, gender: @customer.gender, name: @customer.name, notes: @customer.notes, password: @customer.password, zip: @customer.zip }
      assert_redirected_to customer_path(assigns(:customer))
    end

    test "should destroy customer" do
      assert_difference('Customer.count', -1) do
        delete :destroy, id: @customer
      end

      assert_redirected_to customers_path
    end
  end
end
