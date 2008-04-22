class OpenApplicationPlatform::API
  attr_accessor :network, :api_key, :api_secret, :session_key, :user_id
  
  def initialize(network, api_key, api_secret, session_key, user_id=nil)
    @network = network
    @api_key = api_key
    @api_secret = api_secret
    @session_key = session_key
    @user_id = user_id ? user_id : users_getLoggedInUser.value
  end
  
  def method_missing(method, *args, &block)
    if method.to_s =~ /\w+_\w+/ # API call
      call(method.to_s.sub(/_/, '.'), *args)
    else
      super
    end
  end
  
private
  def logger
    RAILS_DEFAULT_LOGGER
  end

  def call(method, params={})
    logger.info("#{network} API call: #{method}")
    
    params = params.merge(apiparams(method))
    params.each { |k, v| params[k] = v.join(',') if v.is_a?(Array) }
    params[:sig] = sign(params)
    
    result = post(params).body
    
    logger.info("#{network} API response: #{result}")
    Response.new(result)
  end
  
  def apiparams(method)
    returning({}) do |p|
      p[:method] = method
      p[:api_key] = api_key
      p[:v] = network.api_version
      p[:session_key] = session_key
      p[:call_id] = Time.now.to_f.to_s
      p[:format] = 'JSON'
    end
  end
  
  def sign(params)
    query = params.map { |k, v| "#{k}=#{v}" }.sort.join
    Digest::MD5.hexdigest("#{query}#{api_secret}")
  end
  
  def post(params)
    Net::HTTP.new(network.api_host, 80).start do |http|
      http.post(network.api_path_rest, serialize(params))
    end
  end
  
  def serialize(params)
    params.map { |k, v| "#{k}=#{v}" }.join('&')
  end
end
