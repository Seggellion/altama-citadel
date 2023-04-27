class Commodity < ApplicationRecord


  def self.buy_by_location(location)
    commodity_list = Commodity.where(location: location).where('buy > ?', 0).order(name: :desc)
    commodity_list
  end

    def self.sell_by_location(location)
      commodity_list = Commodity.where(location: location).where('sell > ?', 0).order(name: :desc)
      commodity_list
    end

    def self.find_sell_locations(title)
      commodity_list = Commodity.where(name: title).where('sell > ?', 0).order(location: :desc)
      commodity_list
    end

    def self.find_buy_locations(title)
      commodity_list = Commodity.where(name: title).where('buy > ?', 0).order(location: :desc)
      commodity_list
    end

    def selling_price_discounted(rfa)

    
      #  product_commodity_price = RfaProduct.find_by(rfa_id: rfa.id, commodity_id: commodity.id)
        
       # if product_commodity_price && product_commodity_price.selling_price > 0
            commodity_price = self.price
            user_discounts = rfa.user.discounts * 0.01
          
            price = commodity_price - (commodity_price * user_discounts)
          price.round(4) 
      #  elsif product_commodity_price
      #      product_commodity_price.selling_price
      #  end
        
    end


end