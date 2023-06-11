class ArticlesController < ApplicationController
  #before_action :require_login, except: [:update ] 
  before_action :set_article, only: %i[ show edit destroy ]
  before_action :task_manager
   

  # GET /Articles or /Articles.json
  def index
    @articles = Article.all
    @article = Article.new
    @altama_users = User.where.not(org_title: [nil, ""])
    
  end

  # GET /Articles/1 or /Articles/1.json




  # GET /Articles/new
  def new
    @article = Article.new
  end

  # GET /Articles/1/edit
  def edit
  end

  # POST /Articles or /Articles.json
  def create

    @article = Article.new(article_params)
    @article.update(user_id: current_user.id)

if  params[:article][:article_type] == "lore"

elsif params[:article][:article_type] == "dossier"
  
  if current_user.id == params[:article][:user_reference_id].to_i
    @article.update(reference_id: current_user.id)

  end
elsif params[:article][:article_type] == "location"

  if params[:article][:location] == ""

    if params[:article][:parent_location_id]
      
      parent = params[:article][:parent_location_id]

      if system = Location.find_by_name(params[:article][:parent_location_id]).system
      else system = "Stanton"
      end          
      location_type = params[:article][:location_type]
    else
      parent = nil
      system = nil
      location_type = "star"
    end 
    
    Location.create(name: params[:article][:title], parent: parent, location_type: location_type, system: system, image: params[:article][:featured_image])
    @article.update(location: Location.last.name)
  end
end

#article_params = article_params.merge(author_id: current_user.id)
#article_params[:author_id] = current_user.id
    


@all_tasks = Task.all

    respond_to do |format|
      if @article.save

        
      task = @all_tasks.find_by(name: "Codex" )
      
         state_name = "article|" + Article.last.id.to_s

         task.update(state:state_name)
         redirect_to root_path

      end
    end
  end

  # PATCH/PUT /Articles/1 or /Articles/1.json
  def update
    @article = Article.find(params[:id])    
    if @article.article_type == "location"
      
      location_type = params.dig(:article, :location, :location_type)
      location_type ||= "point of interest"

      @location = Location.find_by_name(params[:article][:title])
      @article.update(
        title: params[:article][:title],
        article_type: params[:article][:article_type],
        user_id: @current_user.id,
        featured_image: params[:article][:featured_image],
        featured_media: params[:article][:featured_media],
        introduction: params[:article][:introduction],
        content: params[:article][:content],
        last_updated: Time.now,
        location: @location.name
      )
      unless params.dig(:article, :location, :parent).nil?
        @location.update(
          location_type: location_type,
          parent: params.dig(:article, :location, :parent),
          trade_port: params.dig(:article, :location, :trade_terminal),
          image: params.dig(:article, :featured_image),
          ammenities_fuel: params.dig(:article, :location, :ammenities_fuel),
          ammenities_repair: params.dig(:article, :location, :ammenities_repair),
          ammenities_rearm: params.dig(:article, :location, :ammenities_rearm),
          trade_terminal: params.dig(:article, :location, :trade_terminal)
        )
      end      
      @location.save
    else
      @article.location = nil
      @article.update(article_params)
    end

    
      @article.save
      redirect_to root_path
  end

  # DELETE /Articles/1 or /Articles/1.json
  def destroy
    
    @article.destroy
    task = @all_tasks.find_by(name: "Codex" )
    random_article = Article.order("RANDOM()").first
    state_name = "article|" + random_article.id.to_s
  

    respond_to do |format|
      task.update(state:state_name)
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.

    def update_location
      location = Location.find_by_name(article_params[:title])      
      location.update(
        parent: params[:location][:parent], 
        location_type: params[:location][:location_type],
        ammenities_fuel: params[:location][:ammenities_fuel],
        ammenities_rearm: params[:location][:ammenities_rearm],
        ammenities_repair: params[:location][:ammenities_repair], 
        trade_terminal: params[:location][:trade_terminal]
      )
    end
    
    def update_task_state
      task = @all_tasks.find_by(name: "Codex" )
      state_name = "article|" + @article.id.to_s
      task.update(state:state_name)
    end

    def article_params

       params.require(:article).permit(:article_type, :featured_image, :featured_media, :introduction, 
       :content, :title, :reference_id, location_attributes: [:id, :parent, :location_type, :ammenities_fuel, :ammenities_repair, :ammenities_rearm, :trade_terminal])

    end



    
    def location_params
      params.require(:location).permit(:parent, :location_type, :ammenities_fuel, 
      :ammenities_rearm, :ammenities_repair, :trade_terminal)
      
    end

end

