Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  constraints subdomain: "sos" do
    get "/" => "web#roadside_assistance"
   end


  resources :departments
  resources :positions
  resources :rules
  resources :user_position_histories
  resources :user_positions
  resources :votes
  resources :position_nominations
  resources :org_roles
  resources :guildstones
  resources :locations
  resources :tasks
  resources :userships
  resources :manufacturers
  resources :event_records
  resources :event_teams
  resources :teams
  resources :events
  resources :ships
  resources :rfas
  resources :reviews
  resources :rfa_products
  resources :commodities
  resources :rewards
  resources :control_points
  resources :badges
  


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", sessions: 'users/sessions' }
  # Defines the root path route ("/")
   
  root 'welcome#index', :constraints => { :subdomain => "ctd" }
  get 'desktop', to: 'desktop#index', :constraints => { :subdomain => "ctd" }
  get 'bootup', to: 'desktop#bootup', :constraints => { :subdomain => "ctd" }
  # get 'rfas', to: 'rfas#index'
  get 'conquest', to: 'conquest#index', :constraints => { :subdomain => "ctd" }

  resource :conquest do
    get 'staff', to: 'conquest#staff', :constraints => { :subdomain => "ctd" }
    get 'staff_edit', to: 'conquest#staff_edit', :constraints => { :subdomain => "ctd" }
  end

  post 'staff_code', to: 'conquest#staff_code',  as: :staff_code, :constraints => { :subdomain => "ctd" }

  get 'conquest_event', to: 'conquest#show', :constraints => { :subdomain => "ctd" }
  get 'clear_conquest_records', to: 'event_records#clear_control_points'
  get 'stop_conquest', to: 'control_points#stop_conquest', :constraints => { :subdomain => "ctd" }
  get 'capture_conquest', to: 'control_points#capture_conquest', :constraints => { :subdomain => "ctd" }
  get 'conquest_overlay', to: 'conquest#overlay'
  get 'cargo_manifest', to: 'cargo_manifest#welcome', :constraints => { :subdomain => "ctd" }
  get 'website_manager', to: 'website_manager#welcome'
  get 'my_hangar', to: 'my_hangar#index'
  get 'my_hangar_add', to: 'my_hangar#add'
  get 'my_badges', to: 'badges#index'
  get 'my_badges', to: 'badges#index'

  get 'my_hangar_view', to: 'my_hangar#view'
  get 'users', to: 'desktop#users'
  get 'roadside_assistance', to: 'web#roadside_assistance'
  get 'current_review', to: 'web#current_review'
  get 'rfa_location', to: 'web#show'
  get 'ship_view', to: 'desktop#ship_view_switch'
  get 'select_ship', to: 'desktop#index', :constraints => { :subdomain => "ctd" }
  get 'apply_role', to: 'guildstones#apply_role'
  get 'vote', to: 'guildstones#vote'
  get 'start_guildstone', to:'tasks#start_guildstone'
  get 'rsi_user_list', to: 'desktop#rsi_user_list'
  get 'all_user_list', to: 'tasks#state_all_users'
  get 'root_user_list', to: 'tasks#state_root_users'
  get 'discord_user_list', to: 'tasks#state_discord_users'
  get 'state_positions', to: 'tasks#state_positions'
  get 'properties', to: 'tasks#properties'
  get 'profile', to: 'tasks#profile'
  get 'rsi_activate', to: 'tasks#rsi_activate'
  get 'bsod', to: 'desktop#bsod'
  get 'close_position_window', to: 'tasks#close_position_window'
  
  post 'api_discord_users', to: 'users#discord_populate', as: :discord_populate
  post 'authenticate', to: 'users#auth', as: :auth
  post 'verify', to: 'users#verify', as: :verify
  post 'activate', to: 'users#activate', as: :activate
  
  
end
