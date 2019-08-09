require 'test_helper'

module StecmsAppointment
  class ServiceCategoriesControllerTest < ActionController::TestCase
    setup do
      @service_category = stecms_appointment_service_categories(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:service_categories)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create service_category" do
      assert_difference('ServiceCategory.count') do
        post :create, service_category: {  }
      end

      assert_redirected_to service_category_path(assigns(:service_category))
    end

    test "should show service_category" do
      get :show, id: @service_category
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @service_category
      assert_response :success
    end

    test "should update service_category" do
      patch :update, id: @service_category, service_category: {  }
      assert_redirected_to service_category_path(assigns(:service_category))
    end

    test "should destroy service_category" do
      assert_difference('ServiceCategory.count', -1) do
        delete :destroy, id: @service_category
      end

      assert_redirected_to service_categories_path
    end
  end
end
