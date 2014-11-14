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

  def MongoHelpers.check(options,required_options)
    required_options.each do |required_option|
      raise "Missing option #{required_option}" unless options.include?(required_option)
    end
  end

  def MongoHelpers.build_command(command, replica_set_config = nil)
    replica_set_initiate_command = BSON::OrderedHash.new
    replica_set_initiate_command[command] = replica_set_config
    replica_set_initiate_command
  end


  def MongoHelpers.can_we_create_users?(admin_db)
    ismaster_command = build_command('isMaster',1)
    ismaster_result = admin_db.command(ismaster_command,:check_response => false)

    ismaster_result['ok'] == 1 and ismaster_result['ismaster'] == true
  end
end