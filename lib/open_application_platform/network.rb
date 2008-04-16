class OpenApplicationPlatform::Network
  class << self
    attr_accessor :api_version, :api_host, :api_path_rest
    attr_accessor :www_host, :www_path_login, :www_path_add, :www_path_install
  end
end
