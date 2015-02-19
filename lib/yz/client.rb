module Yz
  class Client
    class Error < Yz::Error
    end

    def initialize(options = {})
      # stringify symbol keys
      @options = options.map { |k,v| {k.is_a?(Symbol) ? k.to_s : k => v} }.inject({}, &:update)
    end

    def request(object)
      request = Request.new(object)
      request.request_strings.each_with_index do |request_s, i|
        flags = i < request.request_strings.size - 1 ? ZMQ::SNDMORE : 0
        send_rc = client_socket.send_string(request_s, flags)
        raise(Client::Error, "client socket failed to send (errno = #{ZMQ::Util.errno})") if send_rc < 0
      end
      reply_strings = []
      more = true
      while more
        reply_message = ZMQ::Message.create || raise(ServerError, "failed to create message (errno = #{ZMQ::Util.errno})")
        recv_rc = client_socket.recvmsg(reply_message)
        raise(Client::Error, "client socket failed to recv (errno = #{ZMQ::Util.errno})") if recv_rc < 0
        reply_strings << reply_message.copy_out_string
        reply_message.close
        more = client_socket.more_parts?
      end
      Reply.new(reply_strings)
    end

    ACTIONS = %w(create read update delete index rpc).map(&:freeze).freeze
    ACTIONS.each do |action|
      define_method(action) do |resource, params = {}|
        request({resource: resource, action: action, params: params})
      end
    end

    private
    def client_socket
      @client_socket ||= begin
        Yz.zmq_context.socket(ZMQ::REQ).tap do |client_socket|
          raise(Client::Error, "failed to create client socket") unless client_socket
          if @options['server_public_key'] || @options['client_public_key'] || @options['client_private_key']
            rc = client_socket.setsockopt(ZMQ::CURVE_SERVERKEY, @options['server_public_key'])
            raise(Client::Error, "failed to set client socket server_public_key (errno = #{ZMQ::Util.errno})") if rc < 0
            rc = client_socket.setsockopt(ZMQ::CURVE_PUBLICKEY, @options['client_public_key'])
            raise(Client::Error, "failed to set client socket client_public_key (errno = #{ZMQ::Util.errno})") if rc < 0
            rc = client_socket.setsockopt(ZMQ::CURVE_SECRETKEY, @options['client_private_key'])
            raise(Client::Error, "failed to set client socket client_private_key (errno = #{ZMQ::Util.errno})") if rc < 0
          end
          connect_rc = client_socket.connect(@options['connect'])
          raise(Client::Error, "failed to connect client socket to #{@options['connect']} (errno = #{ZMQ::Util.errno})") if connect_rc < 0
        end
      end
    end
  end
end
