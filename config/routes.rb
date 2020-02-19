StecmsAppointment::Engine.routes.draw do
  resources :customers do
  	collection do
  		get 'search'
  	end
  end
  resources :settings, only: [:index, :update]
  resources :business_hours, only: [:index, :update]
	resources :bookings do
		member do
			delete :confirm_delete
			get :edit_busy_time
			put :update_busy_time
			delete :delete_busy_time
		end

		collection do
			get :calendar
			get :agenda
			get :get_variants
			get :new_busy_time
			post :create_busy_time
			post :get_updates
			post :drag_and_drop
			post :agenda
			patch :update_status
		end
	end
	resources :services
	resources :operators
	resources :service_categories
	resources :closed_dates

	# namespace :frontend do
	# 	resources :appointment_services, except: [:edit, :update] do
 #      collection do
 #        get :change_date_calendar
 #      end

 #      member do
 #        get :reminder_booking
 #      end
 #    end

 #    get 'change-month/:month/:year/:treatment', to: 'appointment_services#change_month_calendar', as: :change_month_calendar
	# end
	#


	namespace :api do
		resources :operators, only: [:index] do
			collection do
				post :available_for_treatments
			end
		end

		resources :bookings, only: [:show, :create] do
			collection do
				post :month_calendar
				post :get_bookings
				
			end

			member do 
				get :get_booking
				# post :get_booking
				get :remove_booking
			end
		end

		resources :services, only: [:index, :show] do
			collection do
				post :price
			end
		end
	end
end
