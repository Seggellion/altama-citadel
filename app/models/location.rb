class Location < ApplicationRecord

has_one_attached :image
has_one_attached :starfarer_image


def star
     Location.where("system = id")
end

end
