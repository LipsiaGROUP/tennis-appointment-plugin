# desc "Explaining what the task does"
# task :stecms_appointment do
#   # Task goes here
# end



namespace :stecms_appointment do
  desc "run copy migration and check dependency"
  task :generate do
    puts "====Star copy migration===="
    puts "\e[32mCheck dependency Stecms Coupon Plugin\e[0m"
    if !"StecmsCoupon".safe_constantize
      puts "\033[0;31m====Stecms Coupon Plugin Not install====\e[0m\n"
      puts " add on Gemfile gem 'stecms_coupon', github: 'LipsiaGROUP/stecms-coupon-plugin' "
      puts "====End===="
    else
      dbconf = {
        :adapter    => "mysql2",
        :host       => ENV['APP_DB_HOST'],
        :encoding   => "utf8",
        :collation  => "utf8_unicode_ci",
        :username   => ENV['APP_DB_USER'],
        :password   => ENV['DATABASE_PASSWORD'],
        :database   => ENV['APP_DB_NAME']
      }
      ActiveRecord::Base.establish_connection(dbconf)
      if !ActiveRecord::Base.connection.table_exists? 'stecms_coupon_promos'
        system("rake stecms_coupon:install:migrations")
      end
      system("rake stecms_appointment:install:migrations")
      puts "====done copy migration===="
    end


  end
end
