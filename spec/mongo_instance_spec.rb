require_relative 'chefspec_helper'

describe 'mongodb::basic_instance' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['platform'] = 'redhat'
    end.converge(described_recipe)
  end

  it 'installs mongodb server' do
    expect(chef_run).to install_package('mongo-10gen-server')
  end

  it 'sets up the log directory' do
    expect(chef_run).to create_directory('/var/log/mongodb-bungle')
  end

  init_script = '/etc/init.d/mongodb-bungle'
  it 'sets up the init script' do
    expect(chef_run).to render_file(init_script)
  end

  sysconfig = '/etc/sysconfig/mongodb-bungle'
  it 'sets up the config file' do
    expect(chef_run).to render_file(sysconfig)
  end

  it 'sets up the db path directory' do
    expect(chef_run).to create_directory('/var/lib/mongodb-bungle')
  end

  it 'enables the service' do
    expect(chef_run).to enable_service('mongodb-bungle')
  end

  it 'starts the service' do
    expect(chef_run).to start_service('mongodb-bungle')
  end

  it 'sets journalling to be off in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--nojournal')
  end

  it 'sets DBPATH environment variable in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('DBPATH="/var/lib/mongodb-bungle"')
  end

  it 'sets forking to on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--fork')
  end

  it 'notifies mongo service to restart when the config file changes' do
    resource = chef_run.template(sysconfig)
    expect(resource).to notify('service[mongodb-bungle]').to(:restart).immediately
  end

  it 'notifies mongo service to restart when the init file changes' do
    resource = chef_run.template(init_script)
    expect(resource).to notify('service[mongodb-bungle]').to(:restart).delayed
  end

  it 'installs the mongo gem' do
    expect(chef_run).to install_chef_gem('mongo')
  end

  it 'installs the bson gem' do
    expect(chef_run).to install_chef_gem('bson')
  end

  it 'sets up the init script with reference to the sysconfig file' do
    expect(chef_run).to render_file(init_script).with_content("SYSCONFIG=\"#{sysconfig}\"")
  end

  it 'sets up the init script with reference to the service user' do
    expect(chef_run).to render_file(init_script).with_content("MONGO_USER=mongod")
  end
end





