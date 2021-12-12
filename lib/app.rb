class App
  Error = Class.new(RuntimeError)

  def initialize(config)
    self.config = config
  end

  def run
    login
    unlock
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

    raise Error, 'Failed in nameserver.login call' if result['code'] != 1000
  end

  def unlock
    return if config.tan.nil?

    config.logger.info '---'
    config.logger.info '--- Unlock:'

    result = domrobot.call('account', 'unlock', {
      'tan' => config.tan
    })

    config.logger.info YAML.dump(result)

    raise Error, 'Failed in account.unlock call' if result['code'] != 1000
  end

  def cleanup
    result = call('info', {
      'domain' => config.domain,
      'type'   => config.type,
      'name'   => config.record
    })

    Array(result.dig('resData', 'record')).each do |entry|
      call('deleteRecord', 'id' => entry['id'])
    end
  end

  def update
    call('createRecord', {
      'domain'  => config.domain,
      'type'    => config.type,
      'name'    => config.record,
      'content' => config.value
    })
  end

  def call(method, params)
    config.logger.info '---'
    config.logger.info "--- nameserver.#{method}:"

    result = domrobot.call('nameserver', method, params)

    config.logger.info YAML.dump(result)

    raise Error, "Failed in nameserver.#{method} call" if result['code'] != 1000

    result
  end

  def domrobot
    @domrobot ||= INWX::Domrobot.new('api.domrobot.com')
  end
end
