# lib/tasks/remove_duplicate_usernames.rake
namespace :users do
    desc 'Remove duplicate usernames'
    task remove_duplicates: :environment do
      duplicate_usernames = User.group(:username).having("count(*) > 1").pluck(:username)
  
      duplicate_usernames.each do |username|
        # get all users with this username, except the first
        duplicate_users = User.where(username: username).offset(1)
  
        duplicate_users.each do |user|
          # create a new unique username
          new_username = "#{username}1"
          # if the new username already exists, add another "1" to it, and so on
          while User.exists?(username: new_username)
            new_username << "1"
          end
          # update the user with the new username
          user.update(username: new_username)
        end
      end
    end
  end
  