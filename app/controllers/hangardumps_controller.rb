class HangardumpsController < ApplicationController
  require 'json'
  require 'net/http'
  require 'uri' 

  def index
    @hangardumps = Hangardump.all
  end

  def new
    @hangardump = Hangardump.new
  end

  def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  
    url = URI.parse(uri_str)
    req = Net::HTTP::Get.new(url.path, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
    response = Net::HTTP.start(url.host, url.port, use_ssl: false) { |http| http.request(req) }
    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end


  def create
    del = "delete from public.userships where user_id = " + current_user.id.to_s
    delresult = ActiveRecord::Base.connection.execute(del)

    data_hash = JSON.parse(File.read(params[:attachment].tempfile))

    data_hash.each do |key, value|
      ##puts (key)
      
      ship_hash = JSON.parse(JSON.dump(key))
      
      ship_hash.each do |k, v|
        #create and save new usership        
        if k == "name"
          
          @name = v          
        elsif k == "ship_name"
          @ship_name = v
        elsif k == "ship_serial"
          @shipserial = v
        elsif k == "pledge_id"
          @pledgeid = v
        elsif k == "pledge_name"
          @pledgename = v
        elsif k == "pledge_date"
          d = Date.parse(v)
          d.next_year(930)
          @pledgedate = d.strftime("%Y-%m-%d")
        elsif k == "lti"
          if (v)
            @lti = true
          else
            @lti = false
          end
        elsif k == "warbond"
          if (v)
            @warbond = true
          else
            @warbond = false
          end
        elsif k == "manufacturer_code"
          @manufacturer_code = v
        end
        #puts(k, v) # this is working - so now use these values to update the db for each ship
      end
      puts('hi')
      
   #  query = "SELECT id FROM public.ships where model = '" + @name + "' OR alt_ship_name = '" + @name + "'"
    #  puts(query)
   #   res = ActiveRecord::Base.connection.execute(query)
   #   puts('res.cmd_tuples: ' + res.cmd_tuples.to_s)
   #   if res.cmd_tuples > 0
    #    ship_id = res.getvalue(0,0);
   #     puts('ship id is: ' + res.getvalue(0,0).to_s )
   #     puts('current_user.id: ' + current_user.id.to_s)

   @model = key["name"]
   @ship_model = Ship.where("model ILIKE ?", "%#{@model}%").first

   @model.split(" ").each do |word|
    @ship_model = Ship.where("model ILIKE ?", "%#{word}%").first
    break if @ship_model  # If we find a match, we stop searching
  end
  
  unless @ship_model
    byebug
  end
   
   raise 'No Ship model found' unless @ship_model
   
   u = Usership.new(
     user_id: current_user.id, 
     ship_name: @ship_name, 
     model: @ship_model.model, 
     ship_serial: @shipserial, 
     pledge_id: @pledgeid, 
     pledge_name: @pledgename, 
     pledge_date: @pledgedate, 
     lti: @lti, 
     warbond: @warbond, 
     source: 'imported'
   )
   
   u.save!
   #   end
      #u.save!
    end
    
    #json_file = StringIO.new(@url_string)
    #file = json_file.read
    #data_hash = JSON.parse(file)
    #puts(JSON.dump(data_hash))

    redirect_to my_hangar_view_path
  end

  def destroy
    @hangardump = Hangardump.find(params[:id])
    @hangardump.destroy
      redirect_to hangardumps_path, notice:  "The hangardump has been deleted."
  end

  #private
  #  def hangardump_params
  #  params.require(:hangardump).permit(:name, :attachment)
  #end
  def usership_params
    #params.require(:usership).permit(:ship_name, :year_purchased, :description, :ship_id, :user_id, :paint, :primary)
    params.require(:usership).permit(:user_id, :ship_name, :ship_serial, :pledge_id, :pledge_name, :pledge_date, :lti, :warbond)
=begin
    params.require(:ship).permit(
      :model,
      :manufacturer_id,
      :scu,
      :crew,
      :length,
      :beam,
      :height,
      :msrp,
      :year_introduced,
      :ship_image_primary,
      :ship_image_secondary,
      :image_topdown,
      :hyd_fuel_capacity,
      :qnt_fuel_capacity,
      :liquid_storage_capacity,
      :mass,
      :vehicle_type,
      :career,
      :role,
      :size,
      :hp,
      :speed,
      :afterburner_speed,
      :ifcs_pitch_max,
      :ifcs_yaw_max,
      :ifcs_roll_max,
      :shield_face_type,
      :armor_physical_dmg_reduction,
      :armor_energy_dmg_reduction,
      :armor_distortion_dmg_reduction,
      :armor_em_signal_reduction,
      :armor_ir_signal_reduction,
      :armor_cs_signal_reduction,
      :capacitor_crew_load,
      :capacitor_crew_regen,
      :capacitor_turret_load,
      :capacitor_turret_regen)
=end      
  end  
end