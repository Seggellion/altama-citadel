# app/resources/usership_resource.rb
module Api
  module V1
    
    class UsershipResource < JSONAPI::Resource
        attributes :ship_name, :ship_image, :year_purchased, :description, :user_id, 
                  :show_information, :primary, :fleetship, :paint, :created_at, :updated_at, 
                  :ship_serial, :pledge_id, :pledge_name, :pledge_date, :pledge_cost, :lti, 
                  :warbond, :source, :fid, :model, :boost, :health, :topspeed, :dexterity
      
        def self.default_sort
          [{ field: 'created_at', direction: :desc }]
        end
                  

        #default_sort [{field: 'created_at', direction: :desc}]
      
        # Apply filter to only show userships with a source of "starbitizen" or "promotion"
        def self.records(options = {})
          context = options[:context]
          Usership.where(source: ["starbitizen", "promotion"])
        end
      end

end
end