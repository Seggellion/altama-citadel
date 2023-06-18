Discord::Notifier.setup do |config|
  
 
    config.url = ENV['DISCORD_CLIENT_ID']

    config.username = 'Altama Energy Support'
  
    # Defaults to `false`
    config.wait = true
  end