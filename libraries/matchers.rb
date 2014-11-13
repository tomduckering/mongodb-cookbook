if defined?(ChefSpec)
  def create_mongodb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('mongodb_user', :create, resource_name)
  end
end