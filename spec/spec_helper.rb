require "bundler/setup"
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
require "port_scanner"
require_relative 'helpers/fixture_loader'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include FixtureLoaderHelper
end
