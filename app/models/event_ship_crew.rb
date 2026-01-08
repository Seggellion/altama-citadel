class EventShipCrew < ApplicationRecord
  belongs_to :user
  belongs_to :event_ship

  # Optional: Restrict specific roles
  ROLES = %w[Pilot Co-Pilot Payload-Specialist Engineer Technician Passenger].freeze

  validates :role, inclusion: { in: ROLES }, allow_nil: true
  validates :user_id, uniqueness: { scope: :event_ship_id, message: "is already crew on this ship" }
end