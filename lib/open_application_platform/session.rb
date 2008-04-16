class OpenApplicationPlatform::Session
  class UnactivatedSessionError < StandardError; end
  
  attr_accessor :api_key, :api_secret, :network
  attr_accessor :session_key, :user_id
  
  def initialize(api_key, api_secret, network=OpenApplicationPlatform::Network::Facebook)
    @api_key = api_key
    @api_secret = api_secret
    @network = network
  end
  
  def activate(session_key, user_id=nil)
    @api = nil
    @session_key = session_key
    @user_id = user_id ? user_id : api.user_id
  end
  
  def ready?
    @session_key
  end
  
  def api
    raise UnactivatedSessionError unless ready?
    @api ||= OpenApplicationPlatform::API.new(network, api_key, api_secret, session_key, user_id)
  end
end
