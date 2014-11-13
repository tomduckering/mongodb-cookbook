mongodb_instance "george" do
  auth true
  port 27018
  dbpath '/var/data/custom-db-path'
  bind_ip '1.2.3.4'
  logpath '/custom/log/path'
  enable_journalling true
  enable_rest true
end