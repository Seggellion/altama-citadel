class ResponseSerializer < ActiveModel::Serializers::JSON
    attributes :id, :rsi_username, :status
  end