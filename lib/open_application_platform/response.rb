require 'json'

class OpenApplicationPlatform::API::Response
  attr_accessor :value
  
  def initialize(body)
    @body = body
    parse(body)
  end
  
  def method_missing(method)
    if @value.respond_to?(method)
      @value.send(method)
    else
      super
    end
  end
  
private
  def parse(body)
    @value = JSON.parse(body)
  rescue JSON::ParserError
    @value = body.sub(/^"(.*)"$/, '\1') # Remove leading and trailing double-quotes
  end
end
