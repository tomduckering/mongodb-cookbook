

action :create do
  require 'mongo'
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