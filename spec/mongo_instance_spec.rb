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

  it 'sets up the init script' do
    expect(chef_run).to render_file('/etc/init.d/mongodb-bungle')
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
    resource = chef_run.template('/etc/init.d/mongodb-bungle')
    expect(resource).to notify('service[mongodb-bungle]').to(:restart).delayed
  end

  it 'installs the mongo gem' do
    expect(chef_run).to install_chef_gem('mongo')
  end

  it 'installs the bson gem' do
    expect(chef_run).to install_chef_gem('bson')
  end
end

describe 'mongodb::auth_instance' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'turns auth on in the config file' do
    expect(chef_run).to render_file('/etc/sysconfig/mongodb-zippy').with_content(/--auth/)
  end
end

describe 'mongodb::custom_instance' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  sysconfig = '/etc/sysconfig/mongodb-george'
  it 'turns auth on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--auth')
  end

  it 'sets custom port in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--port 27018')
  end

  it 'sets custom dbpath in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--dbpath /var/data/custom-db-path')
  end

  it 'sets the bind ip address in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--bind_ip 1.2.3.4')
  end

  it 'sets the log path in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--logpath /custom/log/path')
  end

  it 'sets journalling option on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--journal')
  end

  it 'sets the rest option on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--rest')
  end
end

describe "mongodb::replicaset_instance" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'sets the replSet option in the config file' do
    expect(chef_run).to render_file('/etc/sysconfig/mongodb-rod').with_content('--replSet zippo')
  end

  it 'sets the keyFile option in the config file' do
    expect(chef_run).to render_file('/etc/sysconfig/mongodb-rod').with_content('--keyFile /etc/mongodb-rod/keyFile')
  end

  it 'sets the content of the keyFile' do
    expect(chef_run).to render_file('/etc/mongodb-rod/keyFile').with_content('HoracedontbenaughtyandpassGeoffreythebookOhImsorryGeoffreybutsometimesHoraceisverynaughtyIllpassyouthestorybook')
  end



end
