require 'json'

class OpenApplicationPlatform::API::Response
  attr_accessor :value
  
  def initialize(body)
    @body = body
    parse(body)
  end
  
private
  def parse(body)
    @value = JSON.parse(body)
  rescue JSON::ParserError
    @value = body.sub(/^"(.*)"$/, '\1') # Remove leading and trailing double-quotes
  end
end
