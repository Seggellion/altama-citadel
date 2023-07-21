require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  REFRESH_INTERVAL = 5.minutes

  every(REFRESH_INTERVAL, 'commodity.inventory.refresh') do
    UpdateInventoryJob.perform_later
  end
end
