actions :create
default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :config_document, :kind_of => Hash, :required => true
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 27017