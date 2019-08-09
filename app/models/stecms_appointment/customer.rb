module StecmsAppointment
  class Customer < ActiveRecord::Base

    def self.search_customers(term)
      salon_customers = select('id, name, cell')
      .where("name LIKE :term OR cell LIKE :term",
        { term: "%#{term}%"})

      salon_customers.map do |customer|
        customer.convert_to_hashes
      end
    end

    
    def convert_to_hashes
      {
        id: self.id,
        label: self.name.titleize,
        value: self.name.titleize,
        contact_number: self.cell
      }
    end

  end
end
