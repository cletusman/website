# frozen_string_literal: true

module CryptoLibertarian
  module Website
    class LibraryItem
      ID_RE = /\A[a-z][a-z0-9]*(-[a-z][a-z0-9]*)*\z/.freeze
      IMG_EXT_RE = /\A[a-z0-9]+\z/.freeze
      LANGUAGES = %i[en ru].freeze
      ISBN_RE = /\A\d+\z/.freeze

      ATTRIBUTES = %w[
        id img_ext language title isbn13 isbn10 authors edition binding
        publisher year month description downloads
      ].freeze

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

      def id=(value)
        value = String(value).freeze
        raise "Invalid value: #{value.inspect}" unless value.match? ID_RE

        @id = value
      end

      def img_ext=(value)
        return @img_ext = nil if value.blank?

        value = String(value).freeze
        raise "Invalid value: #{value.inspect}" unless value.match? IMG_EXT_RE

        @img_ext = value
      end

      def language=(value)
        value = String(value).to_sym
        raise "Invalid value: #{value.inspect}" unless LANGUAGES.include? value

        @language = value
      end

      def title=(value)
        @title = String(value).freeze
      end

      def isbn13=(value)
        return @isbn13 = nil if value.blank?

        value = String(value).freeze
        raise "Invalid value: #{value.inspect}" unless value.match? ISBN_RE

        @isbn13 = value
      end

      def isbn10=(value)
        return @isbn10 = nil if value.blank?

        value = String(value).freeze
        raise "Invalid value: #{value.inspect}" unless value.match? ISBN_RE

        @isbn10 = value
      end

      def authors=(value)
        @authors = String(value).freeze
      end

      def edition=(value)
        return @edition = nil if value.blank?

        value = Integer(value)
        raise "Invalid value: #{value.inspect}" unless value.positive?

        @edition = value
      end

      def binding=(value)
        return @binding = nil if value.blank?

        @binding = String(value).freeze
      end

      def publisher=(value)
        return @publisher = nil if value.blank?

        @publisher = String(value).freeze
      end

      def year=(value)
        return @year = nil if value.blank?

        @year = Integer(value)
      end

      def month=(value)
        return @month = nil if value.blank?

        value = Integer(value)
        raise "Invalid value: #{value.inspect}" unless value >= 1 && value <= 12

        @month = value
      end

      def description=(value)
        @description = String(value).freeze
      end

      def downloads=(value)
        @downloads = Array(value).map { |item| Download.new item }.freeze
      end

      class Download
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
end
