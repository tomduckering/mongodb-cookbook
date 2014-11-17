instance_names = %w(good bad ugly)

replicaset_name = nil
#replicaset_name = 'wildwest'

instance_names.each_with_index do |instance_name, index|
  mongodb_instance instance_name do
    port 27017 + index
    replicaset_name replicaset_name
    auth true
  end
end

config = {
    '_id' => 'wildwest',
    'members' => [
        {'_id' => 0, 'host' => 'localhost:27017', 'priority' => 1},
        {'_id' => 1, 'host' => 'localhost:27018', 'priority' => 0, 'votes' => 0},
        {'_id' => 2, 'host' => 'localhost:27019', 'priority' => 0, 'votes' => 0},
    ]
}

mongodb_user 'admin' do
  password 'adminpassword'
  database 'admin'
  roles %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin)
  admin_user 'admin'
  admin_password 'adminpassword'
  host 'localhost'
  port 27017
end

mongodb_replicaset replicaset_name do
  config_document config
  host 'localhost'
  port 27017
  admin_user 'admin'
  admin_password 'adminpassword'
  only_if { replicaset_name }
  instance_names.each do |instance|
    notifies :restart, "service[mongodb-#{instance}]", :immediately
  end
end