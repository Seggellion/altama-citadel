ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Parallel workers get databases rebuilt from schema.rb, which cannot hold SQL functions. Re-apply the Extra Life
  # functions (same files and order as lib/tasks/extra_life_sql.rake) in each worker database.
  parallelize_setup do |_worker|
    conn = ActiveRecord::Base.connection
    if conn.table_exists?(:giveaway_awards)
      Dir[Rails.root.join("db/sql/extra_life_giveaways_v*.sql")].sort.each { |file| conn.execute(File.read(file)) }
    end
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
