namespace :users do
  desc 'Remove duplicate usernames'
  task remove_duplicates: :environment do
    duplicate_usernames = User.select('LOWER(username)').group('LOWER(username)').having("count(*) > 1").pluck('LOWER(username)')

    duplicate_usernames.each do |username|
      # get all users with this username, ordered by created_at
      duplicate_users = User.where("LOWER(username) = ?", username.downcase).order(created_at: :asc)
  
      # transfer AEC from the newest record to the oldest
      duplicate_users.last.aec = duplicate_users.first.aec
  
      # destroy the newest record
      duplicate_users.last.destroy
    end
  end
end
