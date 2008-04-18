module OpenApplicationPlatform::Rails::ControllerExtensions
  def platform_session
    @platform_session ||= initialize_platform_session
  end
  
  def platform_request?
    params.has_key?('fb_sig')
  end
  
  def application_added?
    params['fb_sig_added'] == '1'
  end
  
  def in_canvas?
    params['fb_sig_in_canvas'] == '1'
  end
  
  def current_network_param
    params['fb_sig_network'] || 'Facebook'
  end
  
  def current_network
    "OpenApplicationPlatform::Network::#{current_network_param}".constantize
  end
  
  
  # api_key, api_secret and canvas_path may be overridden in your controller
  
  def api_key
    network_options[:api_key]
  end
  
  def api_secret
    network_options[:api_secret]
  end
  
  def canvas_path
    network_options[:canvas_path]
  end
  
  
  # Before filters
  
  def ensure_application_installed
    unless application_added?
      redirect_to current_network.install_url(api_key)
    end
  end
  
  def set_request_format
    request.format = :fbml if in_canvas?
  end
  
  module ClassMethods
    def require_platform_install(*actions)
      options = actions.extract_options!
      before_filter :ensure_application_installed, options
    end
    
    def skip_platform_install(*actions)
      options = actions.extract_options!
      skip_before_filter :ensure_application_installed, options
    end
  end
  
  
  # Method extensions
  
  def redirect_to_with_canvas_support(*args)
    if in_canvas?
      render :text => "<fb:redirect url=\"#{url_for(*args)}\" />"
    else
      redirect_to_without_canvas_support(*args)
    end
  end
  
  def url_for_with_canvas_support(*args)
    returning url_for_without_canvas_support(*args) do |url|
      url.gsub!(/^\//, canvas_path) if in_canvas?
    end
  end
  
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      
      alias_method_chain :redirect_to, :canvas_support
      alias_method_chain :url_for, :canvas_support
      
      before_filter :set_request_format
      
      helper_method :in_canvas?
    end
  end
  
private
  def initialize_platform_session
    if application_added?
      session = OpenApplicationPlatform::Session.new(api_key, api_secret, current_network)
      session.activate(params['fb_sig_session_key'], params['fb_sig_user'])
      session
    end
  end
  
  def network_options
    OPEN_APPLICATION_PLATFORM[current_network.to_s]
  end
end
