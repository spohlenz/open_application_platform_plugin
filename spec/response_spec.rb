require File.dirname(__FILE__) + '/spec_helper'

describe "An API response" do
  setup do
    @body = '"1240077"'
  end
  
  it "should be instantiable with a body" do
    OpenApplicationPlatform::API::Response.new(@body)
  end
end


describe "An API response to users_getLoggedInUser" do
  setup do
    @body = '"1240077"'
    @response = OpenApplicationPlatform::API::Response.new(@body)
  end
  
  it "should parse and produce a value" do
    @response.value.should == '1240077'
  end
end


describe "An API response to friends_get" do
  setup do
    @body = "[222333,1240079]"
    @response = OpenApplicationPlatform::API::Response.new(@body)
  end
  
  it "should parse and produce a value" do
    @response.value.should == [222333, 1240079]
  end
end
