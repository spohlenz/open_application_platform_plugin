require File.dirname(__FILE__) + '/spec_helper'

describe ActionController::Base do
  it "should mix-in Rails::ControllerExtensions" do
    ActionController::Base.included_modules.should include(OpenApplicationPlatform::Rails::ControllerExtensions)
  end
end

describe "Rails::ControllerExtensions" do

end
