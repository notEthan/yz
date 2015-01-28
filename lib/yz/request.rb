module Yz
  class Request
    def initialize(object)
      @object = object
    end

    def protocol_string
      [Protocol::NAME, Protocol::VERSION, Protocol::FORMAT].join(' ')
    end

    def request_strings
      @request_strings ||= [protocol_string, JSON.generate(@object)]
    end
  end
end
