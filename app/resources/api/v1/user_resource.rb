# app/resources/api/v1/user_resource.rb
module Api
    module V1
      class UserResource < JSONAPI::Resource
        attributes :twitch_username  # and other attributes you may want to expose
        has_many :userships
      end
    end
  end
  