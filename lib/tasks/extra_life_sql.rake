# schema.rb cannot represent SQL functions. Re-apply the Extra Life giveaway functions after any schema load so
# development and test databases built with db:schema:load / db:test:prepare match migrated databases.
namespace :db do
  desc "Apply db/sql/extra_life_giveaways_v*.sql (CREATE OR REPLACE, idempotent)"
  task extra_life_sql: :load_config do
    Dir[Rails.root.join("db/sql/extra_life_giveaways_v*.sql")].sort.each do |file|
      ActiveRecord::Base.connection.execute(File.read(file))
    end
  end
end

%w[db:schema:load db:test:load_schema db:test:prepare].each do |name|
  next unless Rake::Task.task_defined?(name)

  Rake::Task[name].enhance do
    if name.start_with?("db:test")
      ActiveRecord::Base.establish_connection(:test)
    end
    Rake::Task["db:extra_life_sql"].reenable
    Rake::Task["db:extra_life_sql"].invoke
  end
end
