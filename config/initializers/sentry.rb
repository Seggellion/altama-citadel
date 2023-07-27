Sentry.init do |config|
    config.dsn = 'https://38d55201ae9e48bd9d82938bd4ccc8dd@o4505593255493632.ingest.sentry.io/4505593255493632'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
    # To activate performance monitoring, set one of these options.
    # We recommend adjusting the value in production:
    config.traces_sample_rate = 1.0
    # or
    config.traces_sampler = lambda do |context|
      true
    end
  end