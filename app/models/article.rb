class Article < ApplicationRecord
    belongs_to :user
    has_one_attached :featured_image
    TYPES = ['lore','location', 'event', 'vehicle',  'dossier']
  
    def location_system
      if self.location
          location = Location.find_by_name(self.location)
          if location && !location.system.nil?
              return location.system
          end
      end
  end
    

  def location_type
    if self.location
        location = Location.find_by_name(self.location)
        if location && !location.location_type.nil?
            return location.location_type
        end
    end
end
  
      def location_parent
        if self.location
          location =  Location.find_by_name(self.location)
          unless location.nil?
            return location.parent unless location.parent.nil?
          end
        end
      end

    def role_name
      role
    end

    def self.find_title(article_id)
        
        Article.find_by_id(article_id).title
    end
end
