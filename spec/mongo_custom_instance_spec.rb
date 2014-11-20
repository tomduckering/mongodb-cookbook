require_relative 'chefspec_helper'

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

  it 'sets the log to use syslog facilities' do
    expect(chef_run).to render_file(sysconfig).with_content('--syslog')
  end

  it 'sets journalling option on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--journal')
  end

  it 'sets the rest option on in the config file' do
    expect(chef_run).to render_file(sysconfig).with_content('--rest')
  end
end