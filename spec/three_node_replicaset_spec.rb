require_relative 'chefspec_helper'

describe 'mongodb::three_node_replicaset' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'sets up a service for the good instance' do
    expect(chef_run).to enable_service('mongodb-good')
  end

  it 'sets up a service for the ugly instance' do
    expect(chef_run).to enable_service('mongodb-bad')
  end

  it 'sets up a service for the ugly instance' do
    expect(chef_run).to enable_service('mongodb-ugly')
  end
end