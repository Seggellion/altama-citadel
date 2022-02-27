class Ship < ApplicationRecord
    belongs_to :manufacturer
    has_one_attached :image_topdown
end
