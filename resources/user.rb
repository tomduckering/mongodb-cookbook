actions :create
default_action :create

attribute :username, :name_attribute => true, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :database, :kind_of => String, :required => true
attribute :roles, :kind_of => Array, :required => true
attribute :is_admin, :kind_of => [TrueClass, FalseClass], :default => false
attribute :admin_user, :kind_of => String
attribute :admin_password, :kind_of => String
attribute :read_only, :kind_of => [TrueClass, FalseClass], :default => false
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 27017