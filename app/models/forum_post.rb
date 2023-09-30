class ForumPost < ApplicationRecord
    belongs_to :user
    belongs_to :forum_category
    # ... other associations and code
  end