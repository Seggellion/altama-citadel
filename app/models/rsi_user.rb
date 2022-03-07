
class RsiUser < ApplicationRecord
  class << self

def authenticate(rsi_name)
rsi_auth(rsi_name)
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


    def rsi_auth(rsi_name)
      url = "https://robertsspaceindustries.com/citizens/`#{rsi_name}`"
      doc =  Nokogiri::HTML(URI.open(URL).read)
      doc.css('a.membercard').each do |row|
        name = row.css('span.name').text
        title = row.css('span.rank').text
        link = row.css('td.tod').text
  
  
        RsiUser.create(name: name, title: title, link: link)
       # RsiUser.new(name, title, link)
     
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


      parser =  Nokogiri::HTML.parse(browser.html)
    parser.css('a.membercard').each do |row|
      name = row.css('span.name').text
      title = row.css('span.rank').text
      link = row.css('td.tod').text


unless name.blank?
      RsiUser.create(name: name, title: title, link: link)
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
