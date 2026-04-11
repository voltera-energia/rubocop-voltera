# frozen_string_literal: true

require 'rubocop-voltera'
require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.order = :random
  Kernel.srand config.seed
end
