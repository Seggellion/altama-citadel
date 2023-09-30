# app/models/forum_comment.rb
class ForumComment < ApplicationRecord
  belongs_to :user
  belongs_to :forum_post
  # ... other associations and code
end