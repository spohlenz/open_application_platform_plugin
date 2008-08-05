class OpenApplicationPlatform::Configuration
  def self.for(network, environment)
    options[network.to_s.downcase][environment]
  end
  
private
  def self.options
    @options ||= HashWithIndifferentAccess.new(load_config)
  end

  def self.load_config
    @config ||= YAML.load(File.read(RAILS_ROOT + '/config/platform.yml'))
  end
end
