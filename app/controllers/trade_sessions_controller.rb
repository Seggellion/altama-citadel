class TradeSessionsController < ApplicationController
    before_action :task_manager
    before_action :set_trade_session
    #skip_before_action :require_login, only: [:milk_runs, :trade_runs]

    def milk_runs
      @user = User.find_by_username(params[:username])
      @cargo_ships = Ship.where("scu > ?", 1).order(model: :asc)
      @all_locations = Location.all.order(name: :asc)
      @all_locations_parent_grouped = @all_locations.order(parent: :asc)
      @all_commodities = Commodity.all.order(name: :asc)
      @milk_run = MilkRun.new
      # You can handle the situation if the user doesn't exist as you want.
      @user = User.where('lower(username) = lower(?)', params[:username]).first


        session_usernames = @trade_session.session_users.split(',')
        
        # Normalize the usernames (strip whitespace and downcase)
        normalized_session_usernames = session_usernames.map { |username| username.strip.downcase }

        # Check if params[:username] is included in the list
        unless normalized_session_usernames.include?(params[:username].strip.downcase)
          # If the username is not included in the session_users, redirect to the error page
          redirect_to bsod_path, alert: "User not part of the trade session."
        end

    end

    def trade_runs
      @cargo_ships = Ship.where("scu > ?", 1).order(model: :asc)
      @user = User.find_by_username(params[:username])
      @all_locations = Location.all.order(name: :asc)
      @all_locations_parent_grouped = @all_locations.order(parent: :asc)
      @all_commodities = Commodity.all.order(name: :asc)
      @trade_run = TradeRun.new
      # You can handle the situation if the user doesn't exist as you want.
      render_404 if @user.nil?
    end

    def create        
        date = Date.parse(params[:trade_session][:session_date])

        now = Time.now

        datetime = DateTime.new(
          date.year,
          date.month,
          date.day,
          now.hour,
          now.min,
          now.sec,
          now.strftime('%z')
        )

TradeSession.create(session_date: datetime, owner_id: current_user.id)
open_state = "trade123|trade_run-#{TradeSession.last.id}"
@current_task = @task_manager.tasks.last
@current_task.update(state:open_state)


            redirect_to root_path
    end


    def update
      

        if @trade_session.session_users != trade_session_params[:session_users]
            # Split the input string by commas to get an array of usernames
          input_usernames = trade_session_params[:session_users].split(',')

          # Normalize the usernames (strip whitespace and downcase)
          normalized_input_usernames = input_usernames.map { |username| username.strip.downcase }

          # Find or create users
          users = normalized_input_usernames.map do |username|
            user = User.where("lower(username) LIKE ?", "%#{username}%").first_or_create(username: username)
            user.update(provider: 'trade123', password:SecureRandom.hex(10) ) if user.provider == ''

            user
          end

          updated_usernames = users.map(&:username).join(',')
            @trade_session.update(session_users: updated_usernames)

        end

byebug
        redirect_to root_path
        
      end
    

  private

  def set_trade_session
    @trade_session = if params[:id].present?
      TradeSession.find_by(id: params[:id])
    end

    # Use the last TradeSession if @trade_session is nil
    @trade_session ||= TradeSession.last
  end

    def trade_session_params
      params.require(:trade_session).permit(:user_id, :session_users)
    end

end