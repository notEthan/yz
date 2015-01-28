module Yz
  class Reply
    def initialize(reply_strings)
      @reply_strings = reply_strings

      @protocol_string = @reply_strings[0]

      @protocol_parts = @protocol_string.strip.split(/ +/)
    end

    PROTOCOL_PARTS = ['name', 'version', 'format'].map(&:freeze).freeze

    PROTOCOL_PARTS.each_with_index do |part, i|
      define_method("protocol_#{part}") do
        @protocol_parts[i]
      end
    end

    def object
      JSON.parse(@reply_strings[1])
    end
  end
end
