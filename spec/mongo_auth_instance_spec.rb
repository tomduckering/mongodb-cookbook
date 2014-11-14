require_relative 'chefspec_helper'

describe 'mongodb::auth_instance' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'turns auth on in the config file' do
    expect(chef_run).to render_file('/etc/sysconfig/mongodb-zippy').with_content(/--auth/)
  end
end