class Ship < ApplicationRecord
    belongs_to :manufacturer
    has_one_attached :topdown_image
end
