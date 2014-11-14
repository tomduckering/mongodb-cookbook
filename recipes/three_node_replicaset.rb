instance_names = %w(good bad ugly)

instance_names.each_with_index do |instance_name,index|
  mongodb_instance instance_name do
    port 27017 + index
  end
end

config =  {
    '_id' => 'wildwest',
    'members' => [
        {'_id' => 0, 'host' => 'localhost:27017', "priority" => 1 },
        {'_id' => 1, 'host' => 'localhost:27018', "priority" => 0, "votes" => 0 },
        {'_id' => 2, 'host' => 'localhost:27019', "priority" => 0, "votes" => 0 },
    ]
}

mongodb_replicaset 'wildwest' do
  config_document config
  host 'localhost'
  port 27017
end