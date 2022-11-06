class Badge < ApplicationRecord
    has_many :user_badges, :dependent => :destroy
end
