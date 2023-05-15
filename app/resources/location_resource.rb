class LocationResource < JSONAPI::Resource
    attributes :name, :location_type, :parent, :ammenities_fuel, :ammenities_repair, :ammenities_rearm
  
  
end
