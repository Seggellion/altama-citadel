class TradeSessionsController < ApplicationController
    before_action :task_manager, except: [:milk_runs, :trade_runs]
    before_action :set_trade_session
    #skip_before_action :require_login, only: [:milk_runs, :trade_runs]

    def milk_runs
      #@user = User.find_by_username(params[:username])
      @cargo_ships = Ship.where("scu > ?", 1).order(model: :asc)
      @all_locations = Location.all.order(name: :asc)
      @all_locations_parent_grouped = @all_locations.order(parent: :asc)
      @all_commodities = Commodity.all.order(name: :asc)
      @milk_run = MilkRun.new
      # You can handle the situation if the user doesn't exist as you want.
      @user = User.where('lower(username) = lower(?)', params[:username]).first
      @tradeports = Location.where(trade_terminal: true).order('parent ASC')
      if @trade_session&.session_users
        session_usernames = @trade_session.session_users.split(',')
        normalized_session_usernames = session_usernames.map { |username| username.strip.downcase }
    
        # Check if params[:username] is included in the list
        unless normalized_session_usernames.include?(params[:username].strip.downcase)
          # If the username is not included in the session_users, redirect to the error page
          redirect_to bsod_path, alert: "User not part of the trade session."
          return
        end
      else
        # Handle the situation when there's no @trade_session or @trade_session.session_users
        redirect_to bsod_path, alert: "Invalid trade session or session users not defined."
        return
      end

    end

    def trade_runs
      @tradeports = Location.where(trade_terminal: true).order('parent ASC')
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
open_state = "trade123|trade_session-#{TradeSession.last.id}"
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
              # using 'find_by' to avoid unwanted matches
              user = User.find_by("lower(username) = ?", username) 
            
              if user.nil?
                # create a new user with provider and password if user does not exist
                user = User.create!(username: username, provider: 'trade123', password: SecureRandom.hex(10))
              elsif user.provider.blank?
                # update provider and password if they are not set (either nil or empty string)
                user.update!(provider: 'trade123', password: SecureRandom.hex(10))
              end
            
              user
            end
            

          updated_usernames = users.map(&:username).join(',')
          if @trade_session.update(session_users: updated_usernames)
            redirect_to root_path
        else
            error = "Failed to update TradeSession: " + @trade_session.errors.full_messages.join(', ')
            task = Task.where(task_manager_id: @task_manager.id).where("state LIKE ?", "%trade123%").first
            task.memo(memo_type: "error", memo_text:error)
            redirect_to root_path
        end
    else
        redirect_to root_path
    end

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