require_relative 'logger.rb'

class Chef::ResourceDefinitionList::MongoUserManager

  include LogHelper

  def self.should_we_authenticate?(admin_db)
    begin
      return false if admin_db['system.users'].count() == 0
    rescue Mongo::OperationFailure => exception
      return exception.to_s =~ /unauthorized/
    rescue Exception => general_exception
      raise Exception, ['We encountered an exception that we cannot handle', general_exception]
    end
  end

  def self.check(options,required_options)
    required_options.each do |required_option|
      raise "Missing option #{required_option}" unless options.include?(required_option)
    end
  end

  def self.create_user(mongo_client,options)
    require 'mongo'
    check(options,[:username,:password,:database,:roles])

    admin_db = mongo_client.db('admin')
    target_db = options[:database] == 'admin' ? admin_db : mongo_client.db(options[:database])

    if should_we_authenticate?(admin_db)
      check(options,[:admin_user,:admin_password])
      LogHelper.info("Authenticating as #{options[:admin_user]} to do user creation...")
      admin_db.authenticate(options[:admin_user], options[:admin_password])
    else
      LogHelper.info('It seems like this database has no users yet - skipping initial authentication')
    end

    LogHelper.info("Creating user: #{options[:username]}, read_only: #{options[:read_only]}, roles: #{options[:roles].to_s} in database: #{options[:database]}")
    target_db.add_user(options[:username], options[:password], options[:read_only], :roles => options[:roles])

  end

end