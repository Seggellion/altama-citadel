class ArticlesController < ApplicationController
  before_action :require_login
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

  if params[:article][:article_location_id] == ""

    if params[:article][:parent_location_id]
      parent = params[:article][:parent_location_id]    
      if system = Location.find_by_id(params[:article][:parent_location_id]).system
      else system = Location.last.id + 1
      end    
      location_type = params[:article][:location_type]
    else
      parent = nil
      system = nil
      location_type = 1
    end  
    Location.create(name: params[:article][:title], parent: parent, location_type: location_type, system: system, image: params[:article][:featured_image])
    @article.update(location_id: Location.last.id)
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
    @all_tasks = Task.all
    @article = Article.find(params[:id])
    # you have to set the location parent ID here.

  
      if @article.update(article_params)

        if article_params[:article_type] == "location"
          location = Location.find_by_name(article_params[:title])
          location.update(parent: params[:article][:parent], location_type: params[:article][:location_type])
          
        end
        task = @all_tasks.find_by(name: "Codex" )
        state_name = "article|" + @article.id.to_s
        task.update(state:state_name)
        redirect_to root_path
        

    end
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
    def article_params
      params.require(:article).permit(:article_type, :featured_image, 
       :featured_media, :introduction, :content, :title, :location_id, :reference_id)

    end
end

