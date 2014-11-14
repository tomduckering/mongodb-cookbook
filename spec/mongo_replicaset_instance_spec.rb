require_relative 'chefspec_helper'

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
