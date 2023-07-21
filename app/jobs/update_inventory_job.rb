class UpdateInventoryJob < ApplicationJob
    queue_as :default
  
    INVENTORY_INCREASE = 10
  
    def perform(*args)
      Commodity.find_each do |commodity|
        
        if commodity.refreshPerMinute > 0
            
        increase_amount = INVENTORY_INCREASE * commodity.refreshPerMinute
        
        new_inventory = [commodity.inventory + increase_amount, commodity.maxInventory].min
        
        commodity.update!(inventory: new_inventory)
        end
      end
    end
  end
  