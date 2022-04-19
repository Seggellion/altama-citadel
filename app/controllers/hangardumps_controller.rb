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
    @hangardump = Hangardump.new(hangardump_params)
    if @hangardump.save
      redirect_to hangardumps_path, notice: "The hangardump has been uploaded."
      @url_string = url_for(@hangardump.attachment)
      puts(@url_string)
      
      response = fetch(@url_string)
      puts(response.body)
      data_hash = JSON.parse(response.body)

      #file = Net::HTTP.get_response(URI.parse(@url_string)).body
      #data_hash = JSON.parse(file)
      
      
      
      #json_file = StringIO.new(@url_string)
      #file = json_file.read
      #data_hash = JSON.parse(file)
      puts(JSON.dump(data_hash))
    else
      render "new"
    end
  end

  def destroy
    @hangardump = Hangardump.find(params[:id])
    @hangardump.destroy
      redirect_to hangardumps_path, notice:  "The hangardump has been deleted."
  end

  private
    def hangardump_params
    params.require(:hangardump).permit(:name, :attachment)
  end
end
