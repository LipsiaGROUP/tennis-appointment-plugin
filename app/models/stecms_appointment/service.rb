module StecmsAppointment
	class Service < ActiveRecord::Base
		belongs_to :category, class_name: 'StecmsAppointment::ServiceCategory', foreign_key: :stecms_appointment_service_category_id
		has_many :bookings, class_name: 'StecmsAppointment::Booking', foreign_key: :stecms_appointment_service_id
		has_many :variants, class_name: 'StecmsAppointment::Variant', foreign_key: :stecms_appointment_service_id
		has_many :promotions, class_name: 'StecmsAppointment::Promotion', foreign_key: :stecms_appointment_service_id
		has_and_belongs_to_many :operators, class_name: 'StecmsAppointment::Operator', foreign_key: 'stecms_appointment_service_id', association_foreign_key: 'stecms_appointment_operator_id', allow_destroy: true
		has_many :composed_treatments, class_name: 'StecmsAppointment::ComposedService', foreign_key: 'service_parent_id'

		accepts_nested_attributes_for :composed_treatments, reject_if: :all_blank, allow_destroy: true
		accepts_nested_attributes_for :promotions, reject_if: :all_blank, allow_destroy: true

		before_save :set_required_columns

		attr_accessor :pricing_level_id, :service_pricing_level_price, :service_pricing_level_sale_price,
		:duration_text, :promo_variant

		scope :active, -> { where(active: true) }

		def duration_in_minute
			(self.duration / 60.0).round if self.duration.present?
		end

		def show_price(day="")
			day = Time.now if day.blank?
			if self.variants.exists?
				prices = []
				self.variants.each do |variant|
					prices << variant.show_price(day)
				end
				prices.sort { |price| price[1] }.first
			else
				self.get_discounted_price_from_self_table(day)
			end
		end

	  # Returns discount price of a treatment based on a day
	  # It will return discount value and treatment price after discount info on array format
	  #
	  def get_discounted_price_from_self_table(day)
	  	if day.is_a?(String)
	  		day = day.to_date rescue Date.today
	  	end
	  	if (discount_valid_from && discount_valid_to)
	  		if (discount_valid_from.to_date .. discount_valid_to.to_date).cover?(day)
	  			[discount_value, discount_price]
	  		else
	  			get_discounted_price_from_promotions_table(day)
	  		end
	  	else
	  		get_discounted_price_from_promotions_table(day)
	  	end
	  end

	  # Returns discount price of a treatment based on a day from promotions table
	  # It will return discount value and treatment price after discount info on array format
	  #
	  def get_discounted_price_from_promotions_table(day)
	  	promo = promotions.where("day = (?) AND (?) BETWEEN date(stecms_appointment_promotions.discount_valid_from) AND date(stecms_appointment_promotions.discount_valid_to)", day.wday, day).first

	  	if promo.present?
	  		[promo.discount_value, promo.discount_price]
	  	else
	  		[nil, price]
	  	end
	  end

	  def get_promo_variant
	  	unique_promotions_by_variant = promotions.joins(:variant).select("stecms_appointment_variants.title")
	  	.where('stecms_appointment_variants.title NOT LIKE ?', '%standard%').distinct.pluck(:title)

	  	promo_variant = "0"

	  	if unique_promotions_by_variant.any? && unique_promotions_by_variant.length < 2
	  		promo_variant_it = unique_promotions_by_variant.first

	  		promo_variant = if promo_variant_it.include? 'corti'
	  			'short-hair'
	  		elsif promo_variant_it.include? 'folti'
	  			'long-hair'
	  		end
	  	end

	  	promo_variant
	  end

	  def discount_per_day
	  	promotions = self.promotions
	  	.joins('LEFT JOIN stecms_appointment_variants ON stecms_appointment_promotions.stecms_appointment_variant_id = stecms_appointment_variants.id')
	  	.select("DISTINCT(stecms_appointment_promotions.day) day,
	  		stecms_appointment_promotions.discount_type, stecms_appointment_promotions.discount_value,
	  		stecms_appointment_promotions.discount_valid_from, stecms_appointment_promotions.discount_valid_to")

	  	discount_per_day = {}

	  	promotions.each do |promotion|
	  		discount_per_day[promotion.day] = {
	  			type: promotion.discount_type, value: promotion.discount_value.to_i,
	  			valid_from: (promotion.discount_valid_from.strftime("%d-%m-%Y") rescue nil),
	  			valid_to: (promotion.discount_valid_to.strftime("%d-%m-%Y") rescue nil) }
	  		end

	  		discount_per_day
	  	end

	  	def promo_ids_prices_per_day
	  		promotions = self.promotions
	  		.joins('LEFT JOIN stecms_appointment_variants ON stecms_appointment_promotions.stecms_appointment_variant_id = stecms_appointment_variants.id')
	  		.select("stecms_appointment_variants.title, stecms_appointment_promotions.day, stecms_appointment_promotions.id,
	  			stecms_appointment_promotions.day, stecms_appointment_promotions.discount_price AS price")

	  		promo_ids_prices_per_day = {}

	  		promotions.each do |promotion|
	  			promo_ids_prices_per_day[promotion.day] = {} unless promo_ids_prices_per_day[promotion.day].present?

	  			variant_id_key, variant_price_key =
	  			if promotion.title.try(:include?, 'corti')
	  				[:short_promo_id, :short_promo_price]
	  			elsif promotion.title.try(:include?, 'folti')
	  				[:long_promo_id, :long_promo_price]
	  			else
	  				[:standard_promo_id, :standard_promo_price]
	  			end

	  			promo_ids_prices_per_day[promotion.day][variant_id_key] = promotion.id
	  			promo_ids_prices_per_day[promotion.day][variant_price_key] = promotion.price
	  		end

	  		promo_ids_prices_per_day
	  	end

	  	def save_promotions(promo_params)
	  		self.delete_inactive_promotions(promo_params)

	  		short_variant = self.variants.short_hair.first
	  		long_variant = self.variants.long_hair.first
	  		standard_variant = self.variants.standard.first

	  		promo_params.each do |promo_params|
	  			promo_params.merge!({ stecms_appointment_service_id: (standard_variant.try(:variant_id) || 0), price: self.price })
	  			promo_params[:discount_valid_to] << " 23:59:59" if promo_params[:discount_valid_to].present?

	  			short_promo_id = promo_params.delete(:short_hair_promotion_id)
	  			long_promo_id = promo_params.delete(:long_hair_promotion_id)
	  			standard_promo_id = promo_params.delete(:standard_promotion_id)

	  			should_create_standard_promo = true

	  			if self.promo_variant.eql?('0')
	  				if  short_variant.present?
	  					short_promo = self.promotions.where(id: short_promo_id).first_or_initialize
	  					short_promo.attributes = promo_params.merge({
	  						stecms_appointment_service_id: short_variant.id,
	  						price: short_variant.price
	  					})

	  					short_promo.save
	  				end

	  				if long_variant.present?
	  					long_promo = self.promotions.where(id: long_promo_id).first_or_initialize
	  					long_promo.attributes = promo_params.merge({
	  						stecms_appointment_service_id: long_variant.id,
	  						price: long_variant.price
	  					})

	  					long_promo.save
	  				end
	  			elsif self.promo_variant.eql?('short-hair') && short_variant.present?
	  				short_promo = self.promotions.where(id: short_promo_id).first_or_initialize
	  				short_promo.attributes = promo_params.merge({
	  					stecms_appointment_service_id: short_variant.id,
	  					price: short_variant.price
	  				})

	  				short_promo.save
	  			elsif self.promo_variant.eql?('long-hair') && long_variant.present?
	  				long_promo = self.promotions.where(id: long_promo_id).first_or_initialize
	  				long_promo.attributes = promo_params.merge({
	  					stecms_appointment_service_id: long_variant.id,
	  					price: long_variant.price
	  				})

	  				long_promo.save
	  			else
	  				unless self.variants.empty?
	  					should_create_standard_promo = false
	  					self.promotions.where.not(id: (short_variant || long_variant)).destroy_all
	  				end
	  			end

	  			if should_create_standard_promo
	  				standard_promo = self.promotions.where(id: standard_promo_id).first_or_initialize
	  				standard_promo.attributes = promo_params

	  				standard_promo.save
	  			end
	  		end if promo_params.present?
	  	end

	  	def delete_inactive_promotions(active_promotion_params)
	  		if active_promotion_params.present?
	  			current_active_days = active_promotion_params.map { |param| param[:day] }
	  		else
	  			current_active_days = []
	  		end

	  		if current_active_days.empty?
	  			promotions.destroy_all
	  		else
	  			if promo_variant.eql? 'short-hair'
	  				promotions.inactive(current_active_days, 'folti').destroy_all
	  			elsif promo_variant.eql? 'long-hair'
	  				promotions.inactive(current_active_days, 'corti').destroy_all
	  			else
	  				promotions.inactive(current_active_days, '').destroy_all
	  			end
	  		end
	  	end

	  	def save_variants_from_strings(array_of_string)
	  		if array_of_string.present?
	  			array_of_string.each do |string_combination|
	  				params = string_combination.split('_')

	  				offset = 0

	  				variant =
	  				if params[0].start_with? 'edit'
	  					variant_id = params[0].split('-').last
	  					offset = 1
	  					::StecmsAppointment::Variant.find(variant_id)
	  				else
	  					::StecmsAppointment::Variant.new(
	  						stecms_appointment_service_id: self.id,
	  						variant_type: 1)
	  				end

	  				varian_name = params[0 + offset]

	  				if varian_name.eql?('undefined')
	  					varian_name = ""
	  				end

	  				variant.title = varian_name
	  				variant.duration = params[1 + offset].to_i * 60
	  				variant.price = params[3 + offset].to_f
	  				variant.discount_price = params[4 + offset].to_f

	  				if variant.discount_price > 0
	  					discount_valid_from = params[5 + offset]
	  					discount_valid_to = params[6 + offset]
	  					discount_public_from = params[7 + offset]
	  					discount_public_to = params[8 + offset]

	  					variant.discount_valid_from = discount_public_from.present? ? Time.strptime(discount_public_from, '%d-%m-%Y') : Time.now
	  					variant.discount_valid_to = (discount_valid_to.present? ? Time.strptime(discount_valid_to, '%d-%m-%Y') : (variant.discount_valid_from + 1.week)).end_of_day
	  					variant.discount_public_from = discount_public_from.present? ? Time.strptime(discount_public_from, '%d-%m-%Y') : variant.discount_valid_from
	  					variant.discount_public_to = (discount_public_to.present? ? Time.strptime(discount_public_to, '%d-%m-%Y') : variant.discount_valid_to).end_of_day
	  				end

	  				variant.save
	  			end
	  		end
	  	end

	  	private

	  	def set_required_columns
      # value = self.discount_value || 0
      self.discount_type = '%'

      if self.is_composed
      	total_duration_time = []
      	ids_op = []
      	self.composed_treatments.each do |treatment|
      		total_duration_time << (treatment.children_treatment.duration + (treatment.pause_time_minutes * 60))
      		ids_op << treatment.children_treatment.operators.pluck(:id)
      	end
      	self.operator_ids = ids_op.flatten.uniq
      	self.duration = total_duration_time.sum
      else
      	self.duration = self.duration * 60
      end

      if self.discount_price.present? && !self.discount_price.zero?
      	self.discount_value = 100 - (self.discount_price * 100 / self.price).round
      else
      	self.discount_price = 0
      	self.discount_value = 0
      end

      self.discount_valid_from = self.discount_valid_from.end_of_day if self.discount_valid_from.present?
      self.discount_valid_to = self.discount_valid_to.end_of_day if self.discount_valid_to.present?
    end

  end
end
