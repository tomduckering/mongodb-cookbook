require 'rspec'
require 'mongo'
require_relative '../libraries/mongo_replicaset_manager'


describe 'MongoReplicasetManager' do
  context 'create a replica set with no auth' do

    let(:mongo_client) { double(Mongo::MongoClient, :db => nil) }
    let(:admin_db) { double(Mongo::DB) }
    replicaset_config_document = {
        '_id' => 'replicasetname',
        'members' => [
            {'_id' => 0, 'host' => 'localhost:27017', "priority" => 1 },
            {'_id' => 1, 'host' => 'localhost:27018', "priority" => 0, "votes" => 0 },
            {'_id' => 2, 'host' => 'localhost:27019', "priority" => 0, "votes" => 0 },
        ]
    }

    options = {:replicaset_name => 'replicasetname',
               :config_document => replicaset_config_document}

    it 'calls the mongo client correctly when creating a new replicaset' do

      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 0,'errmsg'=>''})
      expect(admin_db).to receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false}).and_return({'ok' => 1,'errmsg'=>''})

      Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options)
    end

    it 'calls the mongo client correctly when creating a replicaset when it is already starting' do
      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 3,'errmsg'=>'should come online shortly'})
      expect(admin_db).to_not receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false})

      Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options)
    end

    it 'calls the mongo client correctly when creating a replicaset when there is already one configured' do
      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 1,'errmsg'=>''})
      expect(admin_db).to_not receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false})

      Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options)
    end

    it 'calls the mongo client correctly when creating a replicaset when the other nodes are not yet avaiable' do
      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 0,'errmsg'=>''})
      expect(admin_db).to receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false}).and_return({'ok' => 3,'errmsg' => 'need all members up to initiate'})

      Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options)
    end

    it 'raises an exception when there are problems initiating the replicaset' do
      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 0,'errmsg'=>''})
      expect(admin_db).to receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false}).and_return({'ok' => 3,'errmsg' => 'some bad error'})

      expect{ Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options) }.to raise_error()
    end
  end

  context 'create a replica set with auth on' do

    let(:mongo_client) { double(Mongo::MongoClient, :db => nil) }
    let(:admin_db) { double(Mongo::DB) }
    replicaset_config_document = {
        '_id' => 'replicasetname',
        'members' => [
            {'_id' => 0, 'host' => 'localhost:27017', "priority" => 1 },
            {'_id' => 1, 'host' => 'localhost:27018', "priority" => 0, "votes" => 0 },
            {'_id' => 2, 'host' => 'localhost:27019', "priority" => 0, "votes" => 0 },
        ]
    }

    options = {:replicaset_name => 'replicasetname',
               :config_document => replicaset_config_document,
               :admin_user      => 'admin',
               :admin_password  => 'adminpassword'}

    it 'calls the mongo client correctly when creating a new replicaset' do

      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_raise(Mongo::OperationFailure.new("Database command 'count' failed: unauthorized"))
      expect(admin_db).to receive('authenticate').with('admin','adminpassword')
      expect(admin_db).to receive('command').with({"replSetGetStatus"=>nil}, {:check_response=>false}).and_return({'ok' => 0,'errmsg'=>''})
      expect(admin_db).to receive('command').with({"replSetInitiate" => replicaset_config_document},{:check_response=>false}).and_return({'ok' => 1,'errmsg'=>''})

      Chef::ResourceDefinitionList::MongoReplicasetManager.create_replicaset(mongo_client, options)
    end
  end
end