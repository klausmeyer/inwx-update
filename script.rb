require 'bundler'

require 'dotenv/load'
require 'xmlrpc/client'
require 'inwx/domrobot'

require 'logger'
require 'yaml'

login    = ENV.fetch('LOGIN')
password = ENV.fetch('PASSWORD')
domain   = ENV.fetch('DOMAIN')
type     = ENV.fetch('TYPE')
record   = ENV.fetch('RECORD')
value    = ENV.fetch('VALUE')
logger   = ENV.fetch('VERBOSE', 'false') == 'true' ? Logger.new(STDOUT) : Logger.new('/dev/null')

domrobot = INWX::Domrobot.new('api.domrobot.com')

logger.info '---'
logger.info '--- Login:'

result = domrobot.login(login, password)

logger.info YAML::dump(result)

raise 'Login failed!' if result['code'] != 1000

logger.info '---'
logger.info '--- nameserver.info:'

result = domrobot.call('nameserver', 'info', {
  'domain' => domain,
  'type'   => type,
  'name'   => record
})

logger.info YAML::dump(result)

Array(result.dig('resData', 'record')).each do |entry|
  logger.info '---'
  logger.info '--- nameserver.deleteRecord:'

  result = domrobot.call('nameserver', 'deleteRecord', {
    'id' => entry['id']
  })

  logger.info YAML::dump(result)

  raise 'Deletion failed!' if result['code'] != 1000
end

logger.info '---'
logger.info '--- nameserver.createRecord:'

result = domrobot.call('nameserver', 'createRecord', {
  'domain'  => domain,
  'type'    => type,
  'name'    => record,
  'content' => value
})

logger.info YAML::dump(result)

raise 'Creation failed!' if result['code'] != 1000
