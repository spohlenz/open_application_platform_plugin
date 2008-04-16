require File.dirname(__FILE__) + '/spec_helper'

describe OpenApplicationPlatform::API do
  before(:each) do
    @network = mock('Network', :api_version => '1.0', :api_host => 'foo.com', :api_path_rest => '/rest.php')
    @api_key = 12345
    @api_secret = 67890
    @session_key = '12345678abcdef'
    @user_id = 1234567
    
    @api = OpenApplicationPlatform::API.new(@network, @api_key, @api_secret, @session_key, @user_id)
  end
  
  it "should be instantiable with api key, secret, session key and user id" do
    OpenApplicationPlatform::API.new(@network, @api_key, @api_secret, @session_key, @user_id)
  end
  
  it "should be able to make API calls" do
    @api.should_receive(:call).with('users.getInfo', { :uids => [1, 2, 3, 4] })
    @api.users_getInfo(:uids => [1, 2, 3, 4])
  end
  
  it "should build api parameters" do
    Time.stub!(:now).and_return(1234.45678)
    @api.send(:apiparams, 'test_fooBar').should == { :method => "test_fooBar",
                                                     :api_key => @api_key,
                                                     :v => '1.0',
                                                     :session_key => @session_key,
                                                     :call_id => "1234.45678",
                                                     :format => 'JSON' }
  end
  
  it "should sign parameters" do
    @api.send(:sign, { 'c' => 4, 'a' => 1 }).should == Digest::MD5.hexdigest('a=1c=467890')
  end
  
  it "should serialize parameters" do
    @api.send(:serialize, { 'c' => 4, 'a' => 1 }).should == "a=1&c=4"
  end
end
