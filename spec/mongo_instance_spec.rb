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
    expect(chef_run).to render_file(sysconfig).with_content('--journal')
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

  it 'removes the original init script for mongo because we place customised versions' do
    expect(chef_run).to delete_file('/etc/init.d/mongod')
  end

  it 'removes the chkconfig for the original mongod service because we don\'t want it to start up ever!!' do
    expect(chef_run).to run_execute('chkconfig --del mongod')
  end

  it 'creates rsyslog file' do
    expect(chef_run).to render_file('/etc/rsyslog.d/mongodb.conf')
  end

  it 'rsyslog config file notifies rsyslog to restart' do
    collectd_config_file = chef_run.template('/etc/rsyslog.d/mongodb.conf')
    expect(collectd_config_file).to notify('service[rsyslog]').to(:restart).immediately
  end

  it 'creates logrotate file' do
    expect(chef_run).to render_file('/etc/logrotate.d/mongodb.conf')
  end


end





