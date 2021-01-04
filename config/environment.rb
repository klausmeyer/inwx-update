app_env = ENV['APP_ENV'] || 'development'

require 'bundler'
Bundler.require(:default, app_env.to_sym)

require 'logger'
require 'yaml'

require_relative '../lib/app'
require_relative '../lib/config'
