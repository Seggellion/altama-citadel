class TradeSessionsController < ApplicationController
    before_action :task_manager

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

TradeSession.create(session_date: datetime, owner_id: current_user.username)
open_state = "trade123|trade_run-#{TradeSession.last.id}"
@current_task = @task_manager.tasks.last
@current_task.update(state:open_state)


            redirect_to root_path
    end

end