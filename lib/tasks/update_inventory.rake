namespace :commodity do
    desc "Update inventory for each commodity"
    task update_inventory: :environment do
        CommodityConstants::REFRESH_PER_MINUTE_MAPPING.each do |name, refresh_rate|
            Commodity.where(name: name).update_all(refreshPerMinute: refresh_rate)
        end
        
      CommodityConstants::MAX_INVENTORY_MAPPING.each do |name, max_inventory|
        Commodity.where(name: name).update_all(maxInventory: max_inventory)
      end
    end
  end
  