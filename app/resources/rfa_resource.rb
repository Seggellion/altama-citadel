class RfaResource < JSONAPI::Resource
    attributes :rsi_username, :ship_name, :location_name, :users_online, :last_message, :status_id
  #  has_many :rfas
  
end
