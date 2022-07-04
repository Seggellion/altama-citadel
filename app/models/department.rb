class Department < ApplicationRecord
  belongs_to :guildstone
  has_many :positions

  
end