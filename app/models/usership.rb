class Usership < ApplicationRecord
    belongs_to :user
    belongs_to :ship
    #validates :name, :attachment, presence: true # Make sure the owner's name is present.
    has_one_attached :attachment
    include ActiveModel::Serializers::JSON

end
