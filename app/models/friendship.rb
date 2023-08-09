class Friendship < ApplicationRecord
    belongs_to :user
    belongs_to :friend, class_name: 'User'
  
    validates :status, presence: true, inclusion: { in: ['pending', 'accepted', 'declined'] }
    
    scope :pending, -> { where(status: 'pending') }
    scope :accepted, -> { where(status: 'accepted') }
    scope :declined, -> { where(status: 'declined') }
  end
  