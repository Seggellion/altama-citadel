Rails.application.routes.draw do
  resources :non_confidences
  resources :rule_proposals
  resources :categories
  mount ActionCable.server => "/cable"

  constraints subdomain: "sos" do
    get "/" => "web#roadside_assistance"
   end


  resources :departments
  resources :positions
  resources :rules
  resources :user_position_histories
  resources :user_positions
  #resources :votes
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
  resources :categories
  resources :rule_proposals


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
  get 'start_my_hangar', to: 'tasks#start_my_hangar'
  get 'my_hangar_import', to: 'hangardump#index'
  get 'my_hangar_add', to: 'my_hangar#add'
  get 'my_hangar_manage', to: 'my_hangar#manage'
  get 'my_hangar_all_fleet', to: 'my_hangar#all_fleet'
  get 'my_hangar_destroy', to: 'my_hangar#clear_ships'
  get 'my_badges', to: 'badges#index'

  get 'my_hangar_view', to: 'my_hangar#view'
  get 'fleet_view', to: 'my_hangar#fleet_view'
  get 'users', to: 'desktop#users'
  get 'roadside_assistance', to: 'web#roadside_assistance'
  get 'current_review', to: 'web#current_review'
  get 'rfa_location', to: 'web#show'
  get 'ship_view', to: 'desktop#ship_view_switch'
  get 'select_ship', to: 'desktop#index', :constraints => { :subdomain => "ctd" }
  get 'apply_role', to: 'guildstones#apply_role'
  #get 'vote', to: 'guildstones#vote'
  get 'killall', to:'tasks#killall'
  get 'start_guildstone', to:'tasks#start_guildstone'
  get 'guildstone_start_asl', to: 'guildstones#guildstone_start_asl'
  get 'guildstone_org_chart', to: 'guildstones#open_org_chart'
  get 'start_rfa_manager', to: 'tasks#start_rfa_manager'
  get 'start_location_manager', to:'tasks#start_location_manager'
  get 'start_ship_manager', to:'tasks#start_ship_manager'
  get 'rsi_user_list', to: 'desktop#rsi_user_list'
  get 'all_user_list', to: 'tasks#state_all_users'
  get 'root_user_list', to: 'tasks#state_root_users'
  get 'discord_user_list', to: 'tasks#state_discord_users'
  get 'state_positions', to: 'tasks#state_positions'
  get 'all_state_positions', to: 'tasks#all_state_positions'
  get 'state_user_positions', to: 'tasks#state_user_positions'
  get 'initiate_ship_modal', to: 'tasks#state_ship_modal'
  get 'state_rules', to: 'tasks#state_rules'
  get 'filter_state', to: 'tasks#filter_state'
  get 'state_location_wizard', to: 'tasks#state_location_wizard'
  get 'state_asl_message', to: 'tasks#state_asl_message'
  get 'state_modals', to: 'tasks#state_modals'
  get 'next_message', to: 'tasks#state_asl_message_next'
  get 'prev_message', to: 'tasks#state_asl_message_prev'
  get 'state_location_edit', to: 'tasks#state_location_edit'
  get 'close_state_window', to: 'tasks#close_state_window'
  get 'close_rules_window', to: 'tasks#close_rules_window'
  get 'close_user_position_window', to: 'tasks#close_user_position_window'
  get 'properties', to: 'tasks#properties'
  get 'profile', to: 'tasks#profile'
  get 'help', to: 'tasks#help'
  get 'rsi_activate', to: 'tasks#rsi_activate'
  get 'bsod', to: 'desktop#bsod'
  get 'close_position_window', to: 'tasks#close_position_window'
  
  get 'vote', to: 'guildstones#vote'
  get 'unvote', to: 'guildstones#unvote'
  get 'accept_nomination', to: 'position_nominations#accept'
  get 'reject_nomination', to: 'position_nominations#reject'
  post 'api_discord_users', to: 'users#discord_populate', as: :discord_populate
  post 'authenticate', to: 'users#auth', as: :auth
  post 'verify', to: 'users#verify', as: :verify
  post 'hangardump', to: 'hangardumps#create', as: :hangardump
  post 'activate', to: 'users#activate', as: :activate
  
  
end
