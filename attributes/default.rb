
default['mongodb']['admin'] = {
    'username' => 'THISISACRAZYDEFAULTWHICHMUSTBECHANGED',
    'password' => 'THISISACRAZYDEFAULTWHICHMUSTBECHANGED',
    'roles' => %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin),
    'database' => 'admin'
}