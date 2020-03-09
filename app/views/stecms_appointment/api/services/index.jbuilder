json.services @services do |service|
  json.title service.title
  json.price service.price
  json.price_today service.show_price.last
  json.preferred_status (service.preferred ? 'favorite' : 'nonFavorite' )
  json.duration_in_minute (service.duration / 60)
  json.service_name service.category.try(:title)
  json.id service.id
  json.s_treatment_id service.id
  json.discount_valid_from service.discount_valid_from
  json.discount_valid_to service.discount_valid_to
  

end