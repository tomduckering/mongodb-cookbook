require_relative 'chefspec_helper'

describe 'mongodb::many_instances' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'should not create instance named after a' do
    expect(chef_run).not_to enable_service('mongodb-a')
  end

  it 'should not create instance named after b' do
    expect(chef_run).not_to enable_service('mongodb-b')
  end

  it 'should create a service named after the instance name value' do
    expect(chef_run).to enable_service('mongodb-name')
  end

end
