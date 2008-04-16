require File.dirname(__FILE__) + '/spec_helper'

describe "Networks" do
  setup do
    @networks = [ OpenApplicationPlatform::Network::Facebook,
                  OpenApplicationPlatform::Network::Bebo ]
    @methods = [ :api_version, :api_host, :api_path_rest,
                 :www_host, :www_path_login, :www_path_add, :www_path_install ]
  end
  
  it "should implement all required methods" do
    @networks.each do |network|
      @methods.each do |method|
        network.should respond_to(method)
        network.send(method).should_not be_nil
      end
    end
  end
end
