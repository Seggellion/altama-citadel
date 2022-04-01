class Reward < ApplicationRecord
    
def self.apply(selector)
  #  reward = Reward.where("lower(title) = ?", selector.downcase).first
  reward = Reward.where(Reward.arel_table[:title].matches(selector)).first
  unless reward.nil?
    p reward.amount.truncate()
  else
    p 'nocode'
  end
end

end
