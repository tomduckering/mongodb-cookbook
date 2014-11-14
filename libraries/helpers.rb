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
end