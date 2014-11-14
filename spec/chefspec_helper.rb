require 'chefspec'

RSpec.configure do |config|
  config.log_level = :info
end

ChefSpec::Coverage.start!