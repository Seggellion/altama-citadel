class TradeSession < ApplicationRecord
    belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
has_many :trade_runs

    def total_profit
        profit = TradeRun.where(trade_session_id: self.id).sum(:profit)
        profit.to_s(:delimited)
    end

    def total_scu
        TradeRun.where(trade_session_id: self.id).sum(:scu)
    end

    def all_users
        # Let's say you have a list of usernames from `trade_runs` 
unique_usernames = trade_runs.pluck(:username).uniq

# Now you can find all users with those usernames
users = User.where(username: unique_usernames)

users
    end

end