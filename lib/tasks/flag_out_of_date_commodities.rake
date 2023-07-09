# lib/tasks/flag_out_of_date_commodities.rake
namespace :commodities do
  desc 'Flag out of date commodities'
  task :flag_out_of_date_commodities => :environment do
    begin
      out_of_date_commodities = Commodity.where('updated_at < ?', 3.months.ago)

      out_of_date_commodities.each do |commodity|
        commodity.update(out_of_date: true)
      end

    rescue Exception => e
      Rails.logger.error("Something went wrong: #{e.message}")
      # You can also log the full backtrace
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
