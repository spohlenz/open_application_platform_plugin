require 'json'

class OpenApplicationPlatform::API::Response
  ERROR_TYPES = {
    1   => 'Unknown',
    2   => 'ServiceUnavailable',
    3   => 'UnknownMethod',
    4   => 'MaxRequests',
    5   => 'DisallowedRemoteAddress',
    100 => 'InvalidParameter',
    101 => 'InvalidAPIKey',
    102 => 'InvalidSessionKey',
    103 => 'InvalidCallID',
    104 => 'InvalidSignature',
    110 => 'InvalidUserID',
    330 => 'InvalidMarkup',
  }
  
  class APIError < StandardError; end
  
  ERROR_TYPES.each do |code, error|
    class_eval <<-EOF
      class #{error}Error < APIError; end
    EOF
  end
  
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
    
    if @value.is_a?(Hash) && @value['error_code']
      raise error_class(@value['error_code']), body
    end
  rescue JSON::ParserError
    # Not JSON - remove leading and trailing double-quotes
    @value = body.sub(/^"(.*)"$/, '\1')
  end
  
  def error_class(code)
    "#{self.class.to_s}::#{ERROR_TYPES[code]}Error".constantize
  end
end
