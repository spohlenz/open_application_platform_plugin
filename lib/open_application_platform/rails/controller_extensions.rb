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
  
  def logged_in?
    params['fb_sig_user']
  end
  
  def in_canvas?
    params['fb_sig_in_canvas'] == '1'
  end
  
  def is_ajax?
    params['fb_sig_is_ajax'] == '1'
  end
  
  def in_new_facebook?
    params['fb_sig_in_new_facebook'] == '1'
  end
  
  def current_network_param
    params['fb_sig_network'] || 'Facebook'
  end
  
  def current_network
    "OpenApplicationPlatform::Network::#{current_network_param}".constantize
  end
  
  
  # api_key, api_secret and app_name may be overridden in your controller
  
  def api_key
    network_options[:api_key]
  end
  
  def api_secret
    network_options[:api_secret]
  end
  
  def app_name
    network_options[:app_name]
  end
  
  
  # Before filters
  
  def ensure_application_installed
    redirect_to current_network.install_url(api_key) unless application_added?
  end
  
  def ensure_user_logged_in
    redirect_to current_network.login_url(api_key) unless logged_in?
  end
  
  def set_request_format
    request.format = :fbml if in_canvas? || is_ajax?
  end
  
  module ClassMethods
    def require_platform_login(options={})
      before_filter :ensure_user_logged_in, options
    end
    
    def skip_platform_login(options={})
      skip_before_filter :ensure_user_logged_in, options
    end
    
    def require_platform_install(options={})
      before_filter :ensure_application_installed, options
    end
    
    def skip_platform_install(options={})
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
      url.gsub!(/^\//, "/#{app_name}/") if in_canvas? && url !~ /\/#{app_name}/
    end
  end
  
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      
      alias_method_chain :redirect_to, :canvas_support
      alias_method_chain :url_for, :canvas_support
      
      before_filter :set_request_format
      
      helper_method :in_canvas?, :application_added?, :app_name
    end
  end
  
private
  def initialize_platform_session
    if logged_in?
      session = OpenApplicationPlatform::Session.new(api_key, api_secret, current_network)
      session.activate(params['fb_sig_session_key'], params['fb_sig_user'])
      session
    end
  end
  
  def network_options
    OPEN_APPLICATION_PLATFORM[current_network.to_s]
  end
end
