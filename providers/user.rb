require 'mongo'


def should_we_authenticate?(admin_db)
  begin
    admin_db['system.users'].count() == 0
  rescue Mongo::OperationFailure => exception
    return false if exception.msg =~ /unauthorized/
  rescue Exception => general_exception
    raise ['We encountered an exception that we cannot handle', general_exception]
  end

end

action :create do
  mongo_client = Mongo::MongoClient.new(@new_resource.host, @new_resource.port, :connect_timeout => 15, :slave_ok => true)
  MongoUserManager.create_user( mongo_client,
                                {
                                   :username       => @new_resource.username,
                                   :password       => @new_resource.password,
                                   :database       => @new_resource.database,
                                   :roles          => @new_resource.roles,
                                   :read_only      => @new_resource.read_only,
                                   :admin_user     => @new_resource.admin_user,
                                   :admin_password => @new_resource.admin_password
                               })
end