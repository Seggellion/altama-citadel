# app/models/ship_component.rb
class ShipComponent < ApplicationRecord
    has_many :usership_components, foreign_key: 'ship_components_id'
  
    validates :component_name, presence: true
    validates :component_type, presence: true
  
    # other logic
  end
  