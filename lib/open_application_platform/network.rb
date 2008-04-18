class OpenApplicationPlatform::Network
  class << self
    attr_accessor :api_version, :api_host, :api_path_rest
    attr_accessor :www_host, :www_path_login, :www_path_add, :www_path_install
    
    def to_s
      super.demodulize
    end
    
    def install_url(api_key)
      "http://#{www_host}#{www_path_install}?api_key=#{api_key}"
    end
  end
end
