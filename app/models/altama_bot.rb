class AltamaBot < ApplicationRecord
  
def start
  binding.break
    run
end

def stop
  stop
end

    private

    def run
    
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
    end

    def stop
binding.break

    end
    
    end