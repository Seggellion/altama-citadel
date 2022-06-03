class Usership < ApplicationRecord
    belongs_to :user
    belongs_to :ship
    has_one_attached :attachment
    include ActiveModel::Serializers::JSON
end
