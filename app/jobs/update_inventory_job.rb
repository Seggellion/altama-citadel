class UpdateInventoryJob < ApplicationJob
    queue_as :default
  
    INVENTORY_INCREASE = 10
  
    def perform(*args)
      Commodity.find_each do |commodity|
        
        begin
          if commodity.refreshPerMinute > 0
            increase_amount = INVENTORY_INCREASE * commodity.refreshPerMinute
            new_inventory = [commodity.inventory + increase_amount, commodity.maxInventory].min
            commodity.update!(inventory: new_inventory)
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Validation failed for Commodity ID: #{commodity.id}, Name: #{commodity.name}, Location: #{commodity.location}. Error: #{e.message}")
        end        
      end
    end
  end
  