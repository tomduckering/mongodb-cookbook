module MongoHelpers
  def MongoHelpers.should_we_authenticate?(admin_db)
    begin
      return false if admin_db['system.users'].count() == 0
    rescue Mongo::OperationFailure => exception
      return exception.to_s =~ /unauthorized/
    rescue Exception => general_exception
      raise Exception, ['We encountered an exception that we cannot handle', general_exception]
    end
  end

  def MongoHelpers.successful?(result)
    return result && result['ok'] && result['ok'] == 1
  end

  def MongoHelpers.check(options, required_options)
    required_options.each do |required_option|
      raise "Missing option #{required_option}" unless options.include?(required_option)
    end
  end

  def MongoHelpers.build_command(command, replica_set_config = nil)
    require 'json'

    if replica_set_config
      #something in the BSON ordered hash mutates the object, and chef is not happy with that.
      #We do a "clone" of the object to avoid that...
      arg = JSON.parse({'args' => replica_set_config}.to_json)['args']
    else
      arg = nil
    end

    replica_set_initiate_command = BSON::OrderedHash.new
    replica_set_initiate_command[command] = arg
    replica_set_initiate_command
  end

  def MongoHelpers.can_we_create_users?(admin_db, try_times)
    ismaster_command = build_command('isMaster', 1)
    for i in 1..try_times do
      ismaster_result = admin_db.command(ismaster_command, :check_response => false)
      if successful?(ismaster_result) and ismaster_result['ismaster'] == true
        return true
      end
      sleep 0.5
    end
    return false
  end
end
