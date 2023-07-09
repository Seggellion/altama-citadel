# lib/tasks/flag_out_of_date_commodities.rake
namespace :commodities do
    desc 'Flag out of date commodities'
    task flag_out_of_date_commodities: :environment do
      out_of_date_commodities = Commodity.where('updated_at < ?', 3.months.ago)

      out_of_date_commodities.each do |commodity|
        commodity.update(out_of_date: true)
      end
    end
end

  