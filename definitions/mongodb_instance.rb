define :mongodb_instance,
       :port => 27017,
       :dbpath => nil,
       :bind_ip => nil,
       :logpath => nil,
       :enable_journalling => false,
       :enable_rest => false,
       :replicaset_name => nil,
       :shared_key => "CHANGETHISKEY",
       :auth => false do

  if params[:name] == "mongodb"
    instance_name = params[:name]
  else
    instance_name = 'mongodb-' + params[:name]
  end

  service_user = 'mongod'
  service_group = 'mongod'

  params[:dbpath] ||= "/var/lib/#{instance_name}"
  params[:logpath] ||= "/var/log/#{instance_name}"

  gems = { "bson" => "1.11.1", "mongo" => "1.11.1"}

  gems.each do |gem_name,gem_version|
    cookbook_file "#{Chef::Config.file_cache_path}/#{gem_name}-#{gem_version}.gem" do
      source "#{gem_name}-#{gem_version}.gem"
      cookbook 'mongodb'
    end.run_action(:create)

    # install the mongo ruby gem at compile time to make it globally available
    chef_gem gem_name do
      version gem_version
      source "#{Chef::Config.file_cache_path}/#{gem_name}-#{gem_version}.gem"
    end
  end

  package 'mongo-10gen-server' do
    action :install
  end

  directory "/var/log/#{instance_name}" do
    action :create
    owner service_user
    group service_group
    mode 0755
  end

  directory params[:dbpath] do
    action :create
    owner service_user
    group service_group
    mode 0755
  end

  key_file = nil
  if params[:replicaset_name] and params[:auth]
    directory "/etc/#{instance_name}" do
      action :create
      owner service_user
      group service_group
      mode 0700
    end

    file "/etc/#{instance_name}/keyFile" do
      action :create
      content params[:shared_key]
      owner service_user
      group service_group
      mode 0600
    end

    key_file = "/etc/#{instance_name}/keyFile"
  end

  template "/etc/init.d/#{instance_name}" do
    action :create
    source 'mongodb.init.erb'
    cookbook 'mongodb'
    owner 'root'
    group 'root'
    mode 0755
    notifies :restart, "service[#{instance_name}]"
    variables ({ :instance_name => instance_name,
                  :service_user => service_user
              })
  end

  template "/etc/sysconfig/#{instance_name}" do
    action :create
    source 'mongodb.sysconfig.erb'
    cookbook 'mongodb'
    owner 'root'
    group 'root'
    mode 0755
    variables ({
        :auth => params[:auth],
        :port => params[:port],
        :dbpath => params[:dbpath],
        :bind_ip => params[:bind_ip],
        :logpath => params[:logpath],
        :enable_journalling => params[:enable_journalling],
        :replicaset_name => params[:replicaset_name],
        :enable_rest => params[:enable_rest],
        :key_file => key_file
    })
    notifies :restart, "service[#{instance_name}]", :immediately
  end



  service instance_name do
    supports :status => true, :restart => true
    action [:enable, :start]
  end

end