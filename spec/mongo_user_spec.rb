require_relative 'chefspec_helper'

describe 'mongodb::auth_with_users_instance' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['user']).converge(described_recipe) }

  it 'should create a user' do
    expect(chef_run).to create_mongodb_user('admin')
  end
end