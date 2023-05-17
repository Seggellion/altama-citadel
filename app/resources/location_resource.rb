class LocationResource < JSONAPI::Resource
    attributes :name, :location_type, :parent, :ammenities_fuel, :ammenities_repair, :ammenities_rearm, :trade_terminal
  

    def location_type
        @model.location_type
      end
    
      def parent
        @model.parent
      end
    
      def fuel_service
        @model.fuel_service
      end
    
      def repair_service
        @model.repair_service
      end
    
      def rearm_service
        @model.rearm_service
      end
    
      def trade_terminal
        @model.trade_terminal
      end
  
end
