class OpenApplicationPlatform::Network::Bebo < OpenApplicationPlatform::Network
  @api_version      = '1.0'
  @api_host         = 'apps.bebo.com'
  @api_path_rest    = '/restserver.php'
  
  @www_host         = 'bebo.com'
  @www_path_login   = '/SignIn.jsp'
  @www_path_add     = '/add.php'
  @www_path_install = '/c/apps/add'
end
