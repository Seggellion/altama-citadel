class Article < ApplicationRecord
    belongs_to :user
    has_one_attached :featured_image

    def location_system
        if self.location            
           location =  Location.find_by_name(self.location)           
             unless location.system.nil?
                 location.system
             end
        end
      end
    

      def location_type
        if self.location        
            location =  Location.find_by_name(self.location)
            
              unless location.location_type.nil?
                
                  location.location_type
              end
         end
      end
  
  def location_parent
    if self.location
        
       location =  Location.find_by_name(self.location)
       
         unless location.parent.nil?
             location.parent
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
