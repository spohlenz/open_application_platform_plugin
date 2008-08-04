class OpenApplicationPlatform::Network::Facebook < OpenApplicationPlatform::Network
  @api_version      = '1.0'
  @api_host         = 'api.new.facebook.com'
  @api_path_rest    = '/restserver.php'
  
  @www_host         = 'www.facebook.com'
  @www_path_login   = '/login.php'
  @www_path_add     = '/add.php'
  @www_path_install = '/install.php'
end
