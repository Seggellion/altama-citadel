class OnlineResource < JSONAPI::Resource
    immutable
    attributes :rsi_username
    model_name 'User'

    filter :online_status, default: 'fuelling'
end
