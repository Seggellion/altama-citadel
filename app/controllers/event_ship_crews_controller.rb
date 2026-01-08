class EventShipCrewsController < ApplicationController
  # Include the verification logic (or move it to a Concern if used in multiple controllers)
  
  def create
  @event_ship = EventShip.find(event_ship_crew_params[:event_ship_id])
  rsi_username = event_ship_crew_params[:rsi_username]
  
  # 1. Backend Verification of RSI Handle
  unless verify_rsi_username_exists(rsi_username)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "crew_form_error_#{@event_ship.id}", 
          html: "<div class='alert alert-danger small p-1 mb-2'>RSI Handle '#{rsi_username}' not found.</div>".html_safe
        )
      end
      format.html { redirect_to request.referer, alert: "RSI Handle invalid." }
    end
    return
  end

  # 2. Update User logic
  if current_user.rsi_username != rsi_username
    current_user.update!(rsi_username: rsi_username)
  end

  # 3. Create the Crew Record
  @crew_member = @event_ship.event_ship_crews.new(
    user: current_user, 
    role: event_ship_crew_params[:role]
  )

  if @crew_member.save
    # -------------------------------------------------------------
    # CHANGED: Redirect back to the page they came from (Referer)
    # This acts as a page refresh, showing the "Aboard" state.
    # -------------------------------------------------------------
    redirect_to request.referer || root_path, notice: "Welcome aboard!"
  else
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "crew_form_error_#{@event_ship.id}", 
          html: "<div class='alert alert-warning small p-1 mb-2'>#{@crew_member.errors.full_messages.join(', ')}</div>".html_safe
        )
      end
      format.html { redirect_to request.referer, alert: "Could not join crew." }
    end
  end
end

  # Your existing verification logic
  def verify_username
    rsi_username = params[:rsi_username]
    
    @username_exists = verify_rsi_username_exists(rsi_username)
  
    respond_to do |format|
      format.turbo_stream do
        # We render a partial that likely contains a checkmark or red X
        render turbo_stream: turbo_stream.update("username_verification_result", partial: "codex/verify_username", locals: { valid: @username_exists })
      end
    end
  end

  def destroy
    @crew_member = EventShipCrew.find(params[:id])
    
    # Determine the host (owner) of the ship this crew member is on
    @host = @crew_member.event_ship.usership.user

    # Security Check: Only the Host (or the user themselves) can remove a crew member
    # Logic: "If I am the host OR I am the crew member trying to leave"
    if current_user == @host || current_user == @crew_member.user
      
      @crew_member.destroy
      
      # Determine message based on who performed the action
      msg = (current_user == @host) ? "Crew member removed." : "You have left the ship."
      
      redirect_to request.referer || root_path, notice: msg
    else
      redirect_to request.referer || root_path, alert: "You are not authorized to manage this ship."
    end
  end


  private

    # In your controller or helper method


  def event_ship_crew_params
    params.require(:event_ship_crew).permit(:event_ship_id, :role, :rsi_username)
  end

  def verify_rsi_username_exists(username)
    url = URI.parse("https://robertsspaceindustries.com/en/citizens/#{username}")
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = (url.scheme == "https")
    response = request.request_head(url.path)
    response.code == '200'
  rescue StandardError
    false
  end
end