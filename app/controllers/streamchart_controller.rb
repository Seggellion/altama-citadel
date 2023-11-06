class StreamchartController < ApplicationController
    # before_action :authenticate_user!
    # before_action :not_logged_in
    
    def payout
        @trade_session = TradeSession.find_by_id(5)
        @trade_session = TradeSession.find_by_id(params[:format])
        @trade_runs = TradeRun.where(trade_session_id: @trade_session)
        @session_users =  @trade_runs.map(&:username)
        @user_payout = @session_users.map do |username|
            user_trade_runs = @trade_runs.select { |trade_run| trade_run.username == username }
            user_total_payout = user_trade_runs.inject(0) { |sum, trade_run| sum + trade_run.payout }
            user_total_payout
          end
        render "trade123/streamchart"
    end
    
    def milkrun_profits
      trade_session_id = params[:trade_session_id]
      render json: MilkRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
    end

    def star_bitizen_runs_data
      profits = StarBitizenRun.all.joins(:user).group('users.username').sum(:profit)
      runs = StarBitizenRun.all.joins(:user).group('users.username').count
      render json: { profits: profits, runs: runs }
    end

    def star_bitizen_race_data
      # Group and count StarBitizenRaceUser records by user
      race_users_by_user = StarBitizenRaceUser.includes(:user)
                                              .group('users.username')
                                              .count

      # Prepare data for chart - user races
      user_races_data = race_users_by_user.map do |username, count|
        {
          username: username,
          race_count: count
        }
      end

      # Group and count StarBitizenRaceUser records by ship
      race_users_by_ship = StarBitizenRaceUser.group(:ship).count

      # Prepare data for chart - ship races
      ship_races_data = race_users_by_ship.map do |ship, count|
        {
          ship: ship,
          race_count: count
        }
      end

      render json: {
        user_races: user_races_data,
        ship_races: ship_races_data
      }
    end
    
    def star_bitizen_twitch_data
      user = User.find_by(twitch_id: params[:twitch_id])
      
      # Fetch all runs for the Twitch channel
      runs = StarBitizenRun.where(twitch_channel: user.twitch_id)
    
      # Group runs by username for the first chart (if needed)
      grouped_runs = runs.joins(:user).group('users.username').count
      profits = runs.joins(:user).group('users.username').sum(:profit)
    
      
  # Ensure that you're joining the commodities table when you want to group by commodity name
  commodity_runs = runs.joins(:commodity).group('commodities.name')
  commodity_grouped_runs = commodity_runs.count
  commodity_profits = commodity_runs.sum(:profit)

  # Prepare the commodities data for the chart
  commodities_details = commodity_grouped_runs.map do |commodity_name, count|
    {
      name: commodity_name,
      runs_count: count,
      total_profit: commodity_profits[commodity_name] || 0
    }
  end
    
      # Render the JSON response with data for both charts
      render json: {
        # Data for the first chart
        profits: profits,
        runs: grouped_runs,
        # Data for the second chart
        commodities: commodities_details
      }
    end
    
    

  
    def traderun_profits
         
      trade_session_id = params[:trade_session_id]
      render json: TradeRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
    end

    def star_bitizen

    end

    def star_bitizen_twitch
      @user = User.find_by(twitch_username: params[:twitch_username])      

    end
  
    
    end