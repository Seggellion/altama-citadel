Rails.application.routes.draw do
  jsonapi_resources :rfaapi
  jsonapi_resources :location
  jsonapi_resources :commodity
  jsonapi_resources :online

  resources :non_confidences
  resources :rule_proposals
  resources :categories

  resources :trade_runs do
    patch :update_traderun_location, on: :member
  end
  resources :milk_runs
  resources :bots do
    resources :giveaways, only: [:new, :create, :show]
    patch 'toggle_online', on: :member
  end
  resources :trade_sessions
  
  mount ActionCable.server => "/cable"

  constraints subdomain: "sos" do
    get "/" => "web#roadside_assistance"
   end

  resources :articles
  resources :departments do
    resources :users, only: :index
  end



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
  resources :event_users
  resources :event_series
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
  resources :user_badges
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
  post 'shipments/json_request', to: 'shipments#json_request'
  post 'exchange/json_request', to: 'acu_exchange#json_request'
  post 'star_bitizen/json_request', to: 'star_bitizen#json_request'

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
  get 'my_hangar_all_fleet_remove', to: 'my_hangar#all_fleet_remove'
  get 'my_hangar_destroy', to: 'my_hangar#clear_ships'
  get 'my_badges', to: 'badges#my_badges'
  get 'clear_memos', to: 'tasks#clear_memos'
  get 'my_hangar_view', to: 'my_hangar#view'
  get 'fleet_view', to: 'my_hangar#fleet_view'
  get 'users', to: 'desktop#users'
  get 'all_users', to: 'users#all_users'
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
  get 'guildstone_all_applications', to: 'guildstones#all_applications'
  get 'guildstone_all_nominations', to: 'guildstones#all_nominations'
  
  get 'start_rfa_manager', to: 'tasks#start_rfa_manager'
  get 'rfas_online', to: 'rfas#online'
  get 'start_shell', to: 'tasks#start_shell'
  get 'start_codex', to: 'tasks#start_codex'
  get 'start_bot_manager', to: 'tasks#start_bot_manager'
  get 'start_asl', to: 'tasks#start_asl'
  get 'codex_timeline', to: 'codex#timeline'
  get 'codex_article', to: 'codex#article'
  get 'codex_data_processor', to: 'codex#codex_data_processor'
  get 'codex_create_article', to: 'codex#create_article'
  get 'codex_edit_article', to: 'codex#edit_article'
  get 'codex_show_article', to: 'codex#show_article'
  get 'codex_back_article', to: 'codex#back_article'
  get 'codex_find_article', to: 'codex#find_article'
  get 'codex_dossier', to: 'codex#create_dossier'
  get 'close_find_window', to: 'codex#close_find_window'
  get 'close_codex_window', to: 'codex#close_codex_window'
  get 'join_event', to: 'event_users#join'
  get 'leave_event', to: 'event_users#leave'
  get 'open_event', to: 'events#open_event'
  get 'command', to: 'shell#command_entry'
  get 'acu_command', to: 'shell#acu_command_entry'
  get 'traderun_command', to: 'shell#traderun_command_entry'
  get 'start_location_manager', to:'tasks#start_location_manager'
  get 'start_ship_manager', to:'tasks#start_ship_manager'
  get 'rsi_user_list', to: 'desktop#rsi_user_list'
  get 'all_user_list', to: 'tasks#state_all_users'
  get 'root_user_list', to: 'tasks#state_root_users'
  get 'twitch_user_list', to: 'tasks#state_twitch_users'
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
  get 'state_location_subitem', to:'tasks#state_location_subitem'
  get 'state_location_mainitem', to:'tasks#state_location_mainitem'
  get 'close_state_window', to: 'tasks#close_state_window'
  get 'close_last_window', to: 'tasks#close_last_window'
  get 'close_rules_window', to: 'tasks#close_rules_window'
  get 'close_user_position_window', to: 'tasks#close_user_position_window'
  get 'properties', to: 'tasks#properties'
  get 'profile', to: 'tasks#profile'
  get 'help', to: 'tasks#help'
  get 'rsi_activate', to: 'tasks#rsi_activate'
  get 'sync_altama', to: 'tasks#sync_altama'
  get 'bsod', to: 'desktop#bsod'
  get 'close_position_window', to: 'tasks#close_position_window'
  get 'taskbar_button', to: 'tasks#taskbar_button'
  get 'populate_commodity', to: 'codex#populate_commodity'
  get 'destroy_commodity', to: 'codex#destroy_all_commodity'
  get 'destroy_milk_run', to: 'milk_runs#destroy'
  get 'populate_locations', to: 'codex#populate_locations'
  get 'payout_streamchart', to: 'streamchart#payout'
  get 'milkruns_streamchart', to: 'streamchart#milk_run_profits'
  get 'traderuns_streamchart', to: 'streamchart#trade_run_profits'
  
  get 'milkrun_profits', to: 'streamchart#milkrun_profits'
  get 'traderun_profits', to: 'streamchart#traderun_profits'

  get 'traderun/:username', to: 'trade_sessions#trade_runs', as: :traderun
  get 'milkrun/:username', to: 'trade_sessions#milk_runs', as: :milkrun

  
  get 'commodities_by_location', to: 'commodities#commodities_by_location'
  post 'deactivate_commodities', to: 'commodities#deactivate_commodities'

  get 'vote', to: 'guildstones#vote'
  get 'unvote', to: 'guildstones#unvote'
  get 'accept_nomination', to: 'position_nominations#accept'
  get 'reject_nomination', to: 'position_nominations#reject'
  post 'api_discord_users', to: 'users#discord_populate', as: :discord_populate
  post 'authenticate', to: 'users#auth', as: :auth
  post 'verify', to: 'users#verify', as: :verify
  post 'hangardump', to: 'hangardumps#create', as: :hangardump
  post 'activate', to: 'users#activate', as: :activate
  post 'vim_command', to: 'vim#vim_command'
  
end
