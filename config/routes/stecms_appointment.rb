namespace :stecms_appointment, path: "/" do
  namespace :frontend do
    resources :appointment_services, except: [:edit, :update] do
      collection do
        get :change_date_calendar
      end

      member do
        get :reminder_booking
      end
    end

    get 'change-month/:month/:year/:treatment', to: 'appointment_services#change_month_calendar', as: :change_month_calendar
  end
end
