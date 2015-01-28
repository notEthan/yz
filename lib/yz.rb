require 'yz/version'

require 'ffi-rzmq'
require 'json'

module Yz
  module Protocol
    NAME = 'zy'
    VERSION = '0.0'
    FORMAT = 'json'
  end

  class Error < StandardError
  end

  class << self
    def zmq_context
      @zmq_context ||= begin
        ZMQ::Context.new
      end
    end

    def zmq_context=(zmq_context)
      if @zmq_context
        raise Yz::Error, "zmq_context is already set"
      else
        @zmq_context = zmq_context
      end
    end
  end

  autoload :Client, 'yz/client'
  autoload :Request, 'yz/request'
  autoload :Reply, 'yz/reply'
end
