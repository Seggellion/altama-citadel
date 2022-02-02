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

end
