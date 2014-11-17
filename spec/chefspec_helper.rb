require 'chefspec'

RSpec.configure do |config|
  config.log_level = :info
  config.before(:each) do
    stub_command("chkconfig --list mongod").and_return(0)
  end
end

ChefSpec::Coverage.start!

