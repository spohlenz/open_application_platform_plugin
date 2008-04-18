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
  
  
  # api_key and api_secret may be overridden in your controller
  
  def api_key
    network_keys[:api_key]
  end
  
  def api_secret
    network_keys[:api_secret]
  end
  
  def network_keys
    ApplicationController::API_KEYS[current_network.to_s]
  end
  
  def redirect_to_with_canvas_support(*args)
    if in_canvas?
      render :text => "<fb:redirect url=\"#{url_for(*args)}\" />"
    else
      redirect_to_without_canvas_support(*args)
    end
  end
  
  def ensure_application_installed
    unless application_added?
      redirect_to current_network.install_url(api_key)
    end
  end
  
  module ClassMethods
    def require_platform_install(*actions)
      options = actions.extract_options!
      before_filter :ensure_application_installed, options
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:alias_method_chain, :redirect_to, :canvas_support)
    base.send(:before_filter, :set_request_format)
  end
  
  def set_request_format
    request.format = :fbml if in_canvas?
  end
  
private
  def initialize_platform_session
    if application_added?
      @platform_session = OpenApplicationPlatform::Session.new(api_key, api_secret, current_network)
      @platform_session.activate(params['fb_sig_session_key'], params['fb_sig_user'])
      @platform_session
    end
  end
end
