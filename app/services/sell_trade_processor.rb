class SellTradeProcessor
    def initialize(sell_commodity, current_run)
      @sell_commodity = sell_commodity
      @current_run = current_run
    end
  
    def process
      
      return { total_sold: '30000 ERROR' }.to_json unless @sell_commodity.present? && @current_run.present?
   
      if valid_sell_conditions?
        process_sell_trade
      else
        { total_sold: 'invalid' }.to_json
      end
    end
  
    private
  
    def valid_sell_conditions?
      @sell_commodity.present? && @current_run.present?
    end
  
    def process_sell_trade
      total_units = @current_run.scu
      buy_commodity = @current_run.commodity
      capital = buy_commodity.sell * total_units
      total_profit = (@sell_commodity.buy.to_i * total_units) - capital
      total_sold = @sell_commodity.buy.to_i * total_units
  
      update_current_run(total_profit)
      { total_sold: total_sold }.to_json
    end
  
    def update_current_run(profit)
      @current_run.update(profit: profit)
    end
  end
  