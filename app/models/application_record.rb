class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.asset_exists?(path)
    if Rails.env.production?
      all_assets = Rails.application.assets_manifest.find_sources(path)
  
      if all_assets
        keys = Rails.application.assets_manifest.assets.keys
  
        if keys.include?(path)
          true
        else
         false
        end
      else
        false
      end
    else
      Rails.application.assets.find_asset(path) != nil
    end
  end

  def give_karma(points)
    self.increment(:karma,points).save
  end
  def take_karma(points)
    self.decrement(:karma,points).save
  end
  def give_fame(points)
    self.increment(:fame,points).save
  end
  def take_fame(points)
    self.decrement(:fame,points).save
  end

end
