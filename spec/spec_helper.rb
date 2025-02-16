# frozen_string_literal: true

require "rubocop-packaging"
require "rubocop/rspec/support"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true

  # for running specs tagged with :focus
  # config.filter_run_when_matching :focus

  config.order = :random
  Kernel.srand config.seed
end
