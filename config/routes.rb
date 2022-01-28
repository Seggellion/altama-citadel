Rails.application.routes.draw do
  resources :event_records
  resources :event_teams
  resources :teams
  resources :events
  resources :ships
  resources :rfas
  resources :control_points
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  # Defines the root path route ("/")
  # root "articles#index"  
  root 'welcome#index'
  get 'desktop', to: 'desktop#index'
  get 'roadside_assistance', to: 'rfas#index'
  get 'conquest', to: 'conquest#index'
  get 'conquest_event', to: 'conquest#show'
  get 'clear_conquest_records', to: 'event_records#clear_control_points'
  get 'stop_conquest', to: 'control_points#stop_conquest'
  get 'conquest_overlay', to: 'conquest#overlay'

end
