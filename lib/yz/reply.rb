module Yz
  class Reply
    FIELDS = %w(status body).map(&:freeze).freeze

    def initialize(reply_strings)
      @reply_strings = reply_strings

      @protocol_string = @reply_strings[0]

      @protocol_parts = @protocol_string.strip.split(/ +/)
    end


    Yz::Protocol::PARTS.each_with_index do |part, i|
      define_method("protocol_#{part}") do
        @protocol_parts[i]
      end
    end

    FIELDS.each do |field|
      define_method(field) do
        object[field]
      end
    end

    def object
      JSON.parse(@reply_strings[1])
    end
  end
end
