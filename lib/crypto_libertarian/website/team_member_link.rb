# frozen_string_literal: true

module CryptoLibertarian
  module Website
    class TeamMemberLink
      attr_reader :title, :url

      def initialize(title:, url:)
        self.title = title
        self.url   = url
      end

      def inspect
        "#<#{self.class}: title=#{title.inspect} url=#{url.inspect}>"
      end

      alias to_s inspect

      def to_h
        {
          title: title,
          url: url,
        }.freeze
      end

    private

      def title=(value)
        value = String(value).strip.freeze
        raise 'Blank title' if value.empty?

        @title = value
      end

      def url=(value)
        value = String(value).strip.freeze
        raise 'Blank URL' if value.empty?

        @url = value
      end
    end
  end
end
