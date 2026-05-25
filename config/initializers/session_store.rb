# config/initializers/session_store.rb
if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_altama_energy_session', domain: '.altama.energy'
else
  Rails.application.config.session_store :cookie_store, key: '_altama_energy_session'
end