module Yz
  class Client
    def initialize(options = {})
      # stringify symbol keys
      @options = options.map { |k,v| {k.is_a?(Symbol) ? k.to_s : k => v} }.inject({}, &:update)
    end

    def request(request)
      client_socket.send_string('zy 0.0 json', ZMQ::SNDMORE)
      client_socket.send_string(JSON.generate(request))
      reply_strings = []
      more = true
      while more
        reply_message = ZMQ::Message.create || raise(ServerError, "failed to create message (errno = #{ZMQ::Util.errno})")
        recv_rc = client_socket.recvmsg(reply_message)
        reply_strings << reply_message.copy_out_string
        reply_message.close
        more = client_socket.more_parts?
      end
      reply_strings
    end

    private
    def client_socket
      @client_socket ||= begin
        Yz.zmq_context.socket(ZMQ::REQ).tap do |client_socket|
          if @options['server_public_key'] || @options['client_public_key'] || @options['client_private_key']
            client_socket.setsockopt(ZMQ::CURVE_SERVERKEY, @options['server_public_key'])
            client_socket.setsockopt(ZMQ::CURVE_PUBLICKEY, @options['client_public_key'])
            client_socket.setsockopt(ZMQ::CURVE_SECRETKEY, @options['client_private_key'])
          end
          client_socket.connect(@options['connect'])
        end
      end
    end
  end
end
