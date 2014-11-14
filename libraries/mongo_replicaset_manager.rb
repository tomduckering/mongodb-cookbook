require_relative 'logger'

class Chef::ResourceDefinitionList::MongoReplicasetManager

  require 'json'

  include LogHelper

  def self.build_command(command, replica_set_config = nil)
    replica_set_initiate_command = BSON::OrderedHash.new
    replica_set_initiate_command[command] = replica_set_config
    replica_set_initiate_command
  end

  def self.successful?(result)
    return result && result['ok'] && result['ok'] == 1
  end

  def self.create_replicaset(mongo_client, options)
    admin_db = mongo_client.db('admin')

    replicaset_status_command = build_command('replSetGetStatus')

    replicaset_status_result = admin_db.command(replicaset_status_command, :check_response => false)

    if successful?(replicaset_status_result)
      LogHelper.info('There is already a replicaset configured')
      return
    end

    if replicaset_status_result['errmsg'] =~ /should come online shortly/
      LogHelper.info('It looks like your replicaset is coming up.')
      return
    end

    LogHelper.info('Attempting to configure a replicaset...')

    replicaset_config_doc = options[:config_document]

    LogHelper.info(JSON.pretty_generate(replicaset_config_doc))

    configure_replicaset_command = build_command('replSetInitiate', replicaset_config_doc)

    replicaset_initiate_result = admin_db.command(configure_replicaset_command, :check_response => false)

    if successful?(replicaset_initiate_result)
      Chef::Log.info('Sucessfully configured the replicaset')
    elsif replicaset_initiate_result['errmsg'] =~ /need all members up to initiate/
      Chef::Log.info('Trying to configure replicaset but not all members are up. Make sure they are up and try again.')
    else
      Chef::Log.warn("Could not execute command: '#{configure_replicaset_command}'")
      raise replicaset_initiate_result['errmsg']
    end
  end
end