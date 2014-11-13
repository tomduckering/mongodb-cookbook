mongodb_instance 'zippy' do
  auth true
end

mongodb_user 'admin' do
  host 'localhost'
  port 27017
  database 'admin'
  password 'admin'
  roles ['admin_role']
end

mongodb_user 'joebloggs' do
  host 'localhost'
  port 27017
  database 'mep'
  roles ['read']
  admin_user 'admin'
  admin_password 'admin'
end