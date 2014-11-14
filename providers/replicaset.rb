action :create do
  require 'mongo'
  mongo_client = Mongo::MongoClient.new(@new_resource.host, @new_resource.port, :connect_timeout => 15, :slave_ok => true)

  options = {
      :replicaset_name  => @new_resource.name,
      :config_document  => @new_resource.config_document,
      :admin_user       => @new_resource.admin_user,
      :admin_password   => @new_resource.admin_password
  }

  Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client,options)
end