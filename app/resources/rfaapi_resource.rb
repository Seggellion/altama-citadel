class RfaapiResource < JSONAPI::Resource
    attributes :rsi_username, :ship_name, :location_name, :users_online, :last_message, :status_id, :updated_at, :rfa_products,
     :accepted_time, :status_change_time, :prescheduled_date,  :supplier_rating, :supplier_rating_comment, :commodities_requested
     model_name 'Rfa'
    #  has_many :rfas

end
