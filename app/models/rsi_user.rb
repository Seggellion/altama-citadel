
class RsiUser < ApplicationRecord
  class << self

def authenticate(hash, user, rsi_name)
  
rsi_auth(hash, user, rsi_name)
end

    def write  
      load_with_watir
     # food_trucks
    end

    private

    URL = "https://robertsspaceindustries.com/orgs/ALTAMA/members"

    def food_trucks
      @@food_trucks ||= load_from_document
    end


    def rsi_auth(hash, user, rsi_name)
      profile_url = "https://robertsspaceindustries.com/citizens/#{rsi_name}"
      doc =  Nokogiri::HTML(URI.open(profile_url).read)
      user = User.find_by_id(user)    
      
      hash_match = doc.search(".bio .value:contains('#{hash}')").first

      handle_name = doc.css('strong.value')[2].text
      
      if handle_name == rsi_name && hash_match

        rsi_user = RsiUser.find_by(username: rsi_name)
        discord_user = DiscordUser.find_by(username: user.username)
        user_error = nil
        if rsi_user && discord_user
        case rsi_user.title
        when 'Board Member'
          user_type = 10
          if discord_user.role != 'Board Member'
            user_error = 'Role Mismatch'
          end
        when 'Executive'
          user_type = 15
          if discord_user.role != 'Executive'
            user_error = 'Role Mismatch'
          end
        when 'Partner'
          user_type = 20
          if discord_user.role != 'Partner'
            user_error = 'Role Mismatch'
          end
        when 'Flight Crew'
          user_type = 25
          if discord_user.role != 'Flight Crew'
            user_error = 'Role Mismatch'
          end
        when 'Worker-Owner'
          user_type = 30
          if discord_user.role != 'Worker Owner'
            user_error = 'Role Mismatch'
          end
        when 'Member-Owner'
          user_type = 42
          if discord_user.role != 'Member Owner'
            user_error = 'Role Mismatch'
          end
        else
          rsi_user.title = 'Plus'
          user_type = 100
          if discord_user.role != 'Altama Plus'
            user_error = 'Role Mismatch'
          end
        end
      else
        return
      end
        user.update(rsi_verify: true, rsi_username: rsi_name, 
        user_type: user_type, error: user_error, org_title: rsi_user.title)
       
# check of the Discord profile role is correct
# if not show error


      else
        return false

      end
  
    end


    # no idea what this is
    def wait_for_content(browser, selector)
      html_doc = Nokogiri::HTML.parse(browser.html)

      return if (html_doc.css(selector).first)

      sleep(5)

      # May want to have a limit here so it doesn't spin forever
     # redo
    end


    def load_with_watir
      RsiUser.destroy_all
       # browser = Watir::Browser.start URL

       browser = Watir::Browser.new :chrome, headless:true
       browser.goto(URL)
      #browser = Watir::Browser.new(:chrome)
      
      #browser.members-data
      # document.getElementById('members-data').style.height ='0px';
      browser.ul(id: 'members-data').wait_until(&:present?)
      target = browser.lis(class: 'member-item').last
      target.scroll.to
      sleep 2
      script = <<-JAVASCRIPT
      var membercards = document.getElementsByClassName('member-item');
      var css = '.member-item { border: 1px solid red; height:0px !important; width:0px !important;}',
      container = document.getElementById('members-data'),
      style = document.createElement('style');
      style.type = 'text/css';
      style.appendChild(document.createTextNode(css));


      container.style.height ='0px';
      container.appendChild(style);

      for (let i = 0; i <= membercards.length; i++) {
        if (typeof membercards[i] !== 'undefined' ){
        membercards[i].style.width ='0px';
        membercards[i].style.height ='0px';
        membercards[i].style.border ='1px solid red'
        }
      }
    JAVASCRIPT
    
    sleep 2
       browser.execute_script script
       
       sleep 1
       target2 = browser.div(:id => 'organization')
       target2.scroll.to

       sleep 1
       target3 = browser.lis(:class => 'member-item').last
       target3.scroll.to
       
       sleep 1
       target2 = browser.div(:id => 'organization')
       target2.scroll.to

       sleep 1
       target3 = browser.lis(:class => 'member-item').last
       target3.scroll.to

       sleep 1
       target2 = browser.div(:id => 'organization')
       target2.scroll.to

       sleep 1
       target3 = browser.lis(:class => 'member-item').last
       target3.scroll.to


      parser =  Nokogiri::HTML.parse(browser.html)
    parser.css('a.membercard').each do |row|
      name = row.css('span.nick').text
      title = row.css('span.rank').text
      link = row.css('td.tod').text


unless name.blank?
      RsiUser.create(username: name, title: title, link: link)
end
     # RsiUser.new(name, title, link)
     
    end

     # b.select_list(:id => 'entry_1').wait_until_present
     # b.text_field(:id => 'entry_0').when_present.set 'your name'
    #  b.button(:value => 'Submit').click
    #  b.button(:value => 'Submit').wait_while_present
     # Watir::Wait.until { b.text.include? 'Thank you' }


# if b._css('.membercard .name').text == "Seggellion"

    end


    def load_from_document
        result = []

        
        style = doc.styles

        style['height'] = '0px'
        style['color']  = nil
        doc.styles = style

        doc.css('a.membercard').each do |row|
          name = row.css('span.name').text
          title = row.css('span.rank').text
          link = row.css('td.tod').text
  
  
          RsiUser.create(name: name, title: title, link: link)
         # RsiUser.new(name, title, link)
          
        end
  
        result
      end

    def doc
      Nokogiri::HTML(URI.open(URL).read)
    end
  end
end
