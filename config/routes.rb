Rails.application.routes.draw do
  get 'hangardumps/index'
  get 'hangardumps/new'
  get 'hangardumps/create'
  get 'hangardumps/destroy'
  mount ActionCable.server => "/cable"

  constraints subdomain: "sos" do
    get "/" => "web#roadside_assistance"
   end

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
  resources :hangardumps, only: [:index, :new, :create, :destroy]


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", sessions: 'users/sessions' }
  # Defines the root path route ("/")
   
  root 'welcome#index'
  get 'desktop', to: 'desktop#index'
  get 'bootup', to: 'desktop#bootup'
  # get 'rfas', to: 'rfas#index'
  get 'conquest', to: 'conquest#index'
  get 'conquest_event', to: 'conquest#show'
  get 'clear_conquest_records', to: 'event_records#clear_control_points'
  get 'stop_conquest', to: 'control_points#stop_conquest'
  get 'capture_conquest', to: 'control_points#capture_conquest'
  get 'conquest_overlay', to: 'conquest#overlay'
  get 'cargo_manifest', to: 'cargo_manifest#welcome'
  get 'website_manager', to: 'website_manager#welcome'
  get 'my_hangar', to: 'my_hangar#index'
  get 'my_hangar_import', to: 'hangardump#index'
  get 'my_hangar_add', to: 'my_hangar#add'
  get 'my_badges', to: 'badges#index'
  get 'all_badges', to: 'badges#all_badges'
  get 'my_hangar_view', to: 'my_hangar#view'
  get 'users', to: 'desktop#users'
  get 'roadside_assistance', to: 'web#roadside_assistance'
  get 'current_review', to: 'web#current_review'
  get 'rfa_location', to: 'web#show'
  get 'ship_view', to: 'desktop#ship_view_switch'
  get 'select_ship', to: 'desktop#index'
  get 'apply_role', to: 'guildstones#apply_role'
  get 'vote', to: 'guildstones#vote'
  get 'rsi_user_list', to: 'desktop#rsi_user_list'
  get 'properties', to: 'tasks#properties'
  get 'profile', to: 'tasks#profile'

  post 'authenticate', to: 'users#auth', as: :auth
  post 'verify', to: 'users#verify', as: :verify
  
end
