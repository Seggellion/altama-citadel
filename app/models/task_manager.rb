class TaskManager < ApplicationRecord
    belongs_to :user
    has_many :tasks
    validates :user_id, uniqueness: true

end
