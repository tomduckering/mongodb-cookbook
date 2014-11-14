require_relative 'logger'
require_relative 'helpers'

class Chef::ResourceDefinitionList::MongoReplicasetManager

  require 'json'

  include LogHelper
  include MongoHelpers


  def self.create_replicaset(mongo_client, options)

    MongoHelpers.check(options, [:replicaset_name, :config_document])

    raise "Replicaset name (#{options[:replicaset_name]}) does not match config doc name (#{options[:config_document]['_id']})" if options[:replicaset_name] != options[:config_document]['_id']

    admin_db = mongo_client.db('admin')

    if MongoHelpers.should_we_authenticate?(admin_db)
      LogHelper.info('Authentication is required.')
      MongoHelpers.check(options, [:admin_user, :admin_password])
      LogHelper.info("Authenticating as #{options[:admin_user]} to do replicaset initiation...")
      admin_db.authenticate(options[:admin_user], options[:admin_password])
    end

    replicaset_status_command = MongoHelpers.build_command('replSetGetStatus')

    replicaset_status_result = admin_db.command(replicaset_status_command, :check_response => false)

    if MongoHelpers.successful?(replicaset_status_result)
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

    configure_replicaset_command = MongoHelpers.build_command('replSetInitiate', replicaset_config_doc)

    replicaset_initiate_result = admin_db.command(configure_replicaset_command, :check_response => false)

    if MongoHelpers.successful?(replicaset_initiate_result)
      Chef::Log.info('Successfully configured the replicaset')
    elsif replicaset_initiate_result['errmsg'] =~ /need all members up to initiate/
      Chef::Log.info('Trying to configure replicaset but not all members are up. Make sure they are up and try again.')
    else
      Chef::Log.warn("Could not execute command: '#{configure_replicaset_command}'")
      raise replicaset_initiate_result['errmsg']
    end
  end
end