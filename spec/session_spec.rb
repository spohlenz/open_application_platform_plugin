require File.dirname(__FILE__) + '/spec_helper'

describe OpenApplicationPlatform::Session do
  before(:each) do
    @api_key = '1234'
    @api_secret = '6789'
    @facebook = OpenApplicationPlatform::Network::Facebook
    @bebo = OpenApplicationPlatform::Network::Bebo
  end
  
  it "should be instantiable" do
    OpenApplicationPlatform::Session.new(@api_key, @api_secret)
  end
  
  it "should be instantiable with network" do
    OpenApplicationPlatform::Session.new(@api_key, @api_secret, @bebo)
  end
  
  it "should set the api key" do
    s = OpenApplicationPlatform::Session.new(@api_key, @api_secret)
    s.api_key.should == @api_key
    s.api_secret.should == @api_secret
  end
  
  it "should set the network to Facebook by default" do
    s = OpenApplicationPlatform::Session.new(@api_key, @api_secret)
    s.network.should == @facebook
  end
  
  it "should set a custom network if provided" do
    s = OpenApplicationPlatform::Session.new(@api_key, @api_secret, @bebo)
    s.network.should == @bebo
  end
end


describe "An unactivated Session" do
  before(:each) do
    @session = OpenApplicationPlatform::Session.new('1234', '5678')
    @session_key = 'abcdef12345678'
    @user_id = 12345678
  end
  
  it "should not be ready" do
    @session.should_not be_ready
  end
  
  it "should be activateable with a session key" do
    @api = mock('API Proxy', :user_id => @user_id)
    @session.should_receive(:api).and_return(@api)
    
    @session.activate(@session_key)
    @session.session_key.should == @session_key
    @session.user_id.should == @user_id
  end
  
  it "should be activateable with a session key and user id" do
    @session.activate(@session_key, @user_id)
    @session.user_id.should == @user_id
  end
  
  it "should not return an API proxy" do
    lambda { @session.api }.should raise_error(OpenApplicationPlatform::Session::UnactivatedSessionError)
  end
end


describe "An activated Session" do
  before(:each) do
    @network = mock('Network')
    @session = OpenApplicationPlatform::Session.new('1234', '5678', @network)
    @session.activate('abcdef12345678', 12345678)
  end
  
  it "should be ready" do
    @session.should be_ready
  end
  
  it "should return an API proxy" do
    @session.api.should be_an_instance_of(OpenApplicationPlatform::API)
  end
end
