# frozen_string_literal: true

module CausaArcana
  module Website
    class DownloadsItem
      ATTRIBUTES = %w[text url].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(options)
        options = Hash(options.dup)

        ATTRIBUTES.each do |key|
          send "#{key}=", options.delete(key)
        end

        return if options.empty?

        raise "Invalid options: #{options.keys.inspect}"
      end

    private

      def text=(value)
        @text = String(value).freeze
      end

      def url=(value)
        @url = String(value).freeze
      end
    end
  end
end
