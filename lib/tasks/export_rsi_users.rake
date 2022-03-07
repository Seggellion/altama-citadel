namespace :export do
    desc "Export rsi_users" 
    task :export_to_seeds => :environment do
        RsiUser.all.each do |users| 

        puts "RsiUser.create(name: '#{users.name}', title: '#{users.title}', link: '#{users.link}')"
      end 
    end
  end