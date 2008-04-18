$LOAD_PATH << File.dirname(__FILE__)

module OpenApplicationPlatform::Rails; end

require 'rails/controller_extensions'
ActionController::Base.send(:include, OpenApplicationPlatform::Rails::ControllerExtensions)
