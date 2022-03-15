# frozen_string_literal: true

# This simple bot responds to every "Ping!" message with a "Pong!"
require 'rails'
require 'discordrb'
require 'dotenv-rails'

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#
# If you don't yet have a token to put in here, you will need to create a bot account here:
#   https://discord.com/developers/applications
# If you're wondering about what redirect URIs and RPC origins, you can ignore those for now. If that doesn't satisfy
# you, look here: https://github.com/discordrb/discordrb/wiki/Redirect-URIs-and-RPC-origins
# After creating the bot, simply copy the token (*not* the OAuth2 secret) and put it into the
# respective place.
#bot = Discordrb::Bot.new token: 'OTE4MDI2NjgzODIxNDkwMTc2.YbBQ-Q.N-0inQHG75K01ywC1ssodWbpfzI'

# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
# puts "This bot's invite URL is #{bot.invite_url}."
#puts 'Click on it to invite it to your server.'

# This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
# The code inside it will be executed, and a "Pong!" response will be sent to the channel.
#bot.message(content: 'Ping!') do |event|
#  event.respond 'Pong!'
#end

  token = ENV['GOOGLE_APPLICATION_CREDENTIALS'] 
  bot_cmd = Discordrb::Commands::CommandBot.new token: token, prefix: '!'
  bot_cmd.command(:update) do |event, *args|
    # This simply sends the bot's invite URL, without any specific permissions,
    # to the channel.
    # username = event.message.content.partition(':').last
    # uid = username[3..-1]

    data = event.message.content.split(',')
    uid = data[1]
    status = data[2].to_s
    #uid = uid.chomp('>')
    puts uid
    #user = await client.get_user_info(uid)
    user = bot_cmd.user(uid)
    message = %W{#{user.username}}
    user.pm('Hey ' + user.username + ' It looks like your status is now set to: ' + status )
    #await client.send_message(me, "Hello!")

    #event.bot.invite_url
  end

  bot_cmd.command(:exit, help_available: false) do |event|
    # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
    # able to shut your bot down whenever they wanted.
    
  
    bot.send_message(event.channel.id, 'Bot is shutting down')
    exit
  end


  

#bot.users.fetch('Seggellion').then(dm => {
#    dm.send('Hello World')
#})

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot_cmd.run