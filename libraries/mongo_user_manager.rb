require_relative 'logger.rb'
require_relative 'helpers'

class Chef::ResourceDefinitionList::MongoUserManager

  include LogHelper
  include MongoHelpers


  def self.create_user(mongo_client, options, try_times = 40)
    require 'mongo'
    MongoHelpers.check(options, [:username, :password, :database, :roles])

    admin_db = mongo_client.db('admin')
    target_db = options[:database] == 'admin' ? admin_db : mongo_client.db(options[:database])

    if MongoHelpers.should_we_authenticate?(admin_db)
      LogHelper.info('Authentication is required.')
      MongoHelpers.check(options, [:admin_user, :admin_password])
      LogHelper.info("Authenticating as #{options[:admin_user]} to do user creation...")
      admin_db.authenticate(options[:admin_user], options[:admin_password])
    else
      LogHelper.info('It seems like this database has no users yet - skipping initial authentication')
    end

    if MongoHelpers.can_we_create_users?(admin_db, try_times)
      LogHelper.info("Creating user: #{options[:username]}, read_only: #{options[:read_only]}, roles: #{options[:roles].to_s} in database: #{options[:database]}")
      target_db.add_user(options[:username], options[:password], options[:read_only], :roles => options[:roles])
    else
      LogHelper.warn("Failed to create #{options[:username]} - we can't create users on this instance because it's not a master (i.e. standalone instance or primary in a replicaset)")
    end
  end

end