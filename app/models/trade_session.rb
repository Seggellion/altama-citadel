class TradeSession < ApplicationRecord
    belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
has_many :trade_runs
has_many :milk_runs
    def total_profit
        trade_run_profit = TradeRun.where(trade_session_id: self.id).sum(:profit)
        milk_run_profit = MilkRun.where(trade_session_id: self.id).sum(:profit)
        profit = trade_run_profit + milk_run_profit
        profit.to_s(:delimited)
    end

    def total_scu
        TradeRun.where(trade_session_id: self.id).sum(:scu)
    end

def milk_run_profit
    profit = MilkRun.where(trade_session_id: self.id).sum(:profit)
    profit.to_s(:delimited)
end

def trade_run_profit
    profit = TradeRun.where(trade_session_id: self.id).sum(:profit)
    profit.to_s(:delimited)
end

    def all_users
        # Let's say you have a list of usernames from `trade_runs` 
        
unique_usernames_trade_runs = trade_runs.pluck(:username).uniq
unique_user_ids_milk_runs = milk_runs.pluck(:user_id).uniq
unique_usernames_milk_runs = User.where(id: unique_user_ids_milk_runs).pluck(:username)
unique_usernames = (unique_usernames_trade_runs + unique_usernames_milk_runs).uniq

# Now you can find all users with those usernames
users = User.where(username: unique_usernames)

users
    end

end