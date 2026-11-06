# A Rails user explicitly authorised to operate one event (review donations, assign accounts, confirm status).
class ExtraLifeEventOperator < ApplicationRecord
  belongs_to :extra_life_event
  belongs_to :user
  belongs_to :granted_by, class_name: "User", foreign_key: :granted_by_user_id, optional: true

  validates :user_id, uniqueness: { scope: :extra_life_event_id }
end
