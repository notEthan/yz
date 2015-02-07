module Yz
  class Request
    def initialize(object)
      @object = object
    end

    def protocol_string
      Yz::Protocol::STRING
    end

    def request_strings
      @request_strings ||= [protocol_string, JSON.generate(@object)]
    end
  end
end
