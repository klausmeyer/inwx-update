class App
  Error        = Class.new(RuntimeError)
  LoginError   = Class.new(Error)
  CleanupError = Class.new(Error)
  UpdateError  = Class.new(Error)

  def initialize(config)
    self.config = config
  end

  def run
    login
    cleanup
    update

    true
  end

  private

  attr_accessor :config

  def login
    config.logger.info '---'
    config.logger.info '--- Login:'

    result = domrobot.login(config.login, config.password)

    config.logger.info YAML.dump(result)

    raise LoginError if result['code'] != 1000
  end

  def cleanup
    config.logger.info '---'
    config.logger.info '--- nameserver.info:'

    result = domrobot.call('nameserver', 'info', {
      'domain' => config.domain,
      'type'   => config.type,
      'name'   => config.record
    })

    config.logger.info YAML.dump(result)

    Array(result.dig('resData', 'record')).each do |entry|
      config.logger.info '---'
      config.logger.info '--- nameserver.deleteRecord:'

      result = domrobot.call('nameserver', 'deleteRecord', {
        'id' => entry['id']
      })

      config.logger.info YAML.dump(result)

      raise CleanupError if result['code'] != 1000
    end
  end

  def update
    config.logger.info '---'
    config.logger.info '--- nameserver.createRecord:'

    result = domrobot.call('nameserver', 'createRecord', {
      'domain'  => config.domain,
      'type'    => config.type,
      'name'    => config.record,
      'content' => config.value
    })

    config.logger.info YAML.dump(result)

    raise UpdateError if result['code'] != 1000
  end

  def domrobot
    @domrobot ||= INWX::Domrobot.new('api.domrobot.com')
  end
end
