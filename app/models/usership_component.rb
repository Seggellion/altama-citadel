# app/models/usership_component.rb
class UsershipComponent < ApplicationRecord
    belongs_to :ship_component, foreign_key: 'ship_components_id'
  
    # validations and other model logic
end
  