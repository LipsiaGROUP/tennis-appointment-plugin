## Stecms Appointment Plugin

This plugin provide feature for managing service and appointment list for STECMS.

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'stecms_appointment', github: 'LipsiaGROUP/stecms-appointment-plugin'
```

And then execute:

    $ bundle

## Usage

Add this line to app/assets/javascripts/backend/backend.js

```javascript
//= require stecms_appointment
```

Add this line to app/assets/stylesheets/backend/backend.scss

```stylesheet
@import "stecms_appointment";
```

Add this line to config/routes/backend_routes.rb (inside namespace :backend block)

```ruby
mount StecmsAppointment::Engine, at: "/stecms_appointment", as: 'stecms_appointment'
```

Run this command to generate required migration:
```ruby
 rake stecms_appointment:generate
```

We need modify the backend layout for calendar page only, edit on app/views/layouts/backend.haml
```ruby
- unless action_name.eql?('index') and controller_name.eql?('bookings')
  =javascript_include_tag "backend/backend"
```

and then `rake db:migrate`

You can setup link (usually on `app/views/backend/_backend_menu.haml`) with this:
```ruby
 link_to 'Promotion', StecmsCoupon::Engine.routes.url_helpers.bookings_path
```
