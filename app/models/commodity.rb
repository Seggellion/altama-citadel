class Commodity < ApplicationRecord
  include PgSearch::Model
  validates :name, uniqueness: { scope: :location }

  # validates :updated_at, uniqueness: true
  pg_search_scope :search_by_name_and_location,
                  against: [:name, :location],
                  using: {
                    tsearch: { prefix: true },
                    trigram: { threshold: 0.9 }
                  }
                  #has_many :milk_runs
                  has_many :milk_runs, class_name: 'MilkRun', foreign_key: 'buy_commodity_id'
    
    has_many :commodity_stubs, dependent: :delete_all

          def self.buy_by_location(location)
            commodity_list = Commodity.where(location: location)
                                      .where('buy > ?', 0)
                                      .order(updated_at: :desc)
            commodity_list = Commodity.find_by_sql("
              SELECT DISTINCT ON (name) *
              FROM (#{commodity_list.to_sql}) AS commodities
              ORDER BY name, updated_at DESC
            ")
            commodity_list
          end
                  

          def self.sell_by_location(location)
            commodity_list = Commodity.where(location: location)
                                      .where('sell > ?', 0)
                                      .order(updated_at: :desc)
            commodity_list = Commodity.find_by_sql("
              SELECT DISTINCT ON (name) *
              FROM (#{commodity_list.to_sql}) AS commodities
              ORDER BY name, updated_at DESC
            ")
            commodity_list
          end
          

    def self.create_or_find_by_name_location_and_timestamp(name, sell_price, buy_price, refresh_per_minute, max_inventory, location, timestamp, vice)
      commodity = find_by(name: name, location: location, updated_at: timestamp)
  
      unless commodity
        commodity = create(name: name, sell: sell_price, buy: buy_price, refreshPerMinute: refresh_per_minute, maxInventory: max_inventory, location: location, updated_at: timestamp, vice: vice)
      end
  
      commodity
    end

    def self.is_vice(commodity)
      commodities = ["widow", "altruciatoxin", "slam", "revenant tree pollen", "maze", "neon", "glow", "e'tam", "freeze", "distilled spirits", "stims", "thrust"]
      commodities.include?(commodity.downcase)
    end

    def self.find_sell_locations(title)
      commodity_list = Commodity.where(name: title)
                                .where('sell > ?', 0)
                                .order(sell: :desc)
                        commodity_list = Commodity.find_by_sql("
                        SELECT *
                        FROM (#{commodity_list.to_sql}) AS commodities
                        ORDER BY commodities.sell DESC, commodities.location DESC
                        ")
      commodity_list
    end
    
    def self.find_buy_locations(title)
      commodity_list = Commodity.where(name: title)
        .where('buy > ?', 0)
        .order(buy: :asc)
      commodity_list = Commodity.find_by_sql("
      SELECT *
      FROM (#{commodity_list.to_sql}) AS commodities
      ORDER BY commodities.buy DESC, commodities.location DESC
      ")
      commodity_list
    end
    
    
    

    def selling_price_discounted(rfa)

    
      #  product_commodity_price = RfaProduct.find_by(rfa_id: rfa.id, commodity_id: commodity.id)
        
       # if product_commodity_price && product_commodity_price.selling_price > 0
            commodity_price = self.sell
            user_discounts = rfa.user.discounts * 0.01
          
            price = commodity_price - (commodity_price * user_discounts)
          price.round(4) 
      #  elsif product_commodity_price
      #      product_commodity_price.selling_price
      #  end
        
    end


end