class CommodityResource < JSONAPI::Resource
    attributes :name, :location, :buy, :sell, :vice, :updated_at
  
end
