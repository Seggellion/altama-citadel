class Location < ApplicationRecord

has_one_attached :image
has_one_attached :starfarer_image



#has_one :article, foreign_key: "article", primary_key: "name"


def star
     Location.where("system = id")
end

def has_children?
  return true if Location.where(parent: self.id).count > 0
end

def sublocations
     Location.where(parent: self.id).where.not(location_type: 3)
end
def moonchildren
     Location.where(parent: self.id)
end

def type
     case self.location_type
     when 0
       "Sector"
     when 1
       "Star"
     when 2
       "Planet"
     when 3
       "Moon"
     when 4
       "Space Station"
     when 5
       "Surface Outpost"
     when 6
       "Point of interest"
      when 7
        "Orbital marker"
     end
 end

 def moons
     Location.where(parent: self.id, location_type: 3)
end

def self.all_planets
     Location.where(location_type:2)
end

def planets
     Location.where(parent: self.id, location_type: 2)
end

def get_moon
  Location.find_by(id: self.parent, location_type: 3)
end

def get_planet
  Location.find_by(id: self.parent, location_type: 2)
end

def get_parent
  Location.find_by(id:self.parent)
end

  def find_planet
    if self.location_type > 2
    parent = self.get_parent 
    if parent.location_type == 2
      parent
    else
        grandparent = parent.get_parent
        if grandparent.location_type == 2
          grandparent
        end
      end
    elsif self.location_type == 2
      self
    else
      "Location is star"
    end
  end

def full_name
  name = self.name
  planet = self.find_planet.name  
  star = self.find_planet.get_parent.name
  if name == planet
    p  planet + ' ' + star
  else
    p name + ' ' + planet + ' ' + star
  end
  
end
# If location is at Lathan it's ID 
#
#



end
