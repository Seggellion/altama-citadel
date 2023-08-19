
class UserSkill < ApplicationRecord
    # Associations
    belongs_to :user
    
    # Validations
    validates :skill_name, presence: true, uniqueness: { scope: :user_id }
    validates :value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end