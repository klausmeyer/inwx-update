require_relative 'config/environment'

logger = if ENV.fetch('VERBOSE', 'false') == 'true'
  Logger.new(STDOUT)
else
  Logger.new('/dev/null')
end

config = Config.new(
  login:    ENV.fetch('LOGIN'),
  password: ENV.fetch('PASSWORD'),
  tan:      ENV.fetch('TAN', nil),
  domain:   ENV.fetch('DOMAIN'),
  type:     ENV.fetch('TYPE'),
  record:   ENV.fetch('RECORD'),
  value:    ENV.fetch('VALUE'),
  logger:   logger
)

App.new(config).run
