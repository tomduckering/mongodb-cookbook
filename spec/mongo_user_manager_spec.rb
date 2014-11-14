require 'rspec'
require 'mongo'
require_relative '../libraries/mongo_user_manager'


describe 'MongoUserManager' do
  context 'create an admin user' do

    let(:mongo_client) { double(Mongo::MongoClient, :db => nil) }
    let(:admin_db) { double(Mongo::DB) }
    let(:target_db) { double(Mongo::DB) }

    it 'calls the mongo client correctly when creating admin user for the first time' do

      options = {:username => 'admin', :password => 'admin', :database => 'admin', :read_only => false, :roles => ['admin_role']}

      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(admin_db).to receive('[]').with('system.users').and_return([])
      expect(admin_db).to receive('command').with({'isMaster' => 1}, {:check_response => false}).and_return({'ok' => 1, 'ismaster' => true})
      expect(admin_db).to receive('add_user').with('admin', 'admin', false, {:roles => ['admin_role']})

      Chef::ResourceDefinitionList::MongoUserManager.create_user(mongo_client, options)
    end

    it 'calls the mongo client correctly when creating a user when there is already an admin user' do

      options = {:username => 'joebloggs',
                 :password => 'password',
                 :database => 'my_data',
                 :read_only => false,
                 :roles => ['normal_role'],
                 :admin_user => 'admin',
                 :admin_password => 'adminpassword'}

      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(mongo_client).to receive('db').with('my_data').and_return(target_db)
      expect(admin_db).to receive('[]').with('system.users').and_raise(Mongo::OperationFailure.new("Database command 'count' failed: unauthorized"))
      expect(admin_db).to receive('authenticate').with('admin', 'adminpassword')
      expect(admin_db).to receive('command').with({'isMaster' => 1}, {:check_response => false}).and_return({'ok' => 1, 'ismaster' => true})
      expect(target_db).to receive('add_user').with('joebloggs', 'password', false, {:roles => ['normal_role']})

      Chef::ResourceDefinitionList::MongoUserManager.create_user(mongo_client, options)
    end

    it 'calls the mongo client correctly when failing to create a user in a node thats not master' do

      options = {:username => 'joebloggs',
                 :password => 'password',
                 :database => 'my_data',
                 :read_only => false,
                 :roles => ['normal_role'],
                 :admin_user => 'admin',
                 :admin_password => 'adminpassword'}

      expect(mongo_client).to receive('db').with('admin').and_return(admin_db)
      expect(mongo_client).to receive('db').with('my_data').and_return(target_db)
      expect(admin_db).to receive('[]').with('system.users').and_raise(Mongo::OperationFailure.new("Database command 'count' failed: unauthorized"))
      expect(admin_db).to receive('authenticate').with('admin', 'adminpassword')
      expect(admin_db).to receive('command').exactly(2).with({'isMaster' => 1}, {:check_response => false}).and_return({'ok' => 1, 'ismaster' => false})
      expect(target_db).to_not receive('add_user')

      Chef::ResourceDefinitionList::MongoUserManager.create_user(mongo_client, options, 2)
    end


  end

end