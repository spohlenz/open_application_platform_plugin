$LOAD_PATH << File.dirname(__FILE__)

module OpenApplicationPlatform::Rails; end

require 'rails/controller_extensions'
ActionController::Base.send(:include, OpenApplicationPlatform::Rails::ControllerExtensions)

require 'rails/view_extensions'
ActionView::Base.send(:include, OpenApplicationPlatform::Rails::ViewExtensions)

require 'rails/model_extensions'
ActiveRecord::Base.send(:include, OpenApplicationPlatform::Rails::ModelExtensions)
