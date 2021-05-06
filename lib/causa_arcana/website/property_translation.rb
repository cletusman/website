# frozen_string_literal: true

module CausaArcana
  module Website
    class PropertyTranslation
      attr_reader :locale_to_translation

      def initialize(locale_to_translation)
        self.locale_to_translation = locale_to_translation
        validate!
      end

      def inspect
        "#<#{self.class}:#{locale_to_translation[:en]}>"
      end

      alias to_s inspect

      alias to_h locale_to_translation

      def locales
        locale_to_translation.keys
      end

      def translate_to(locale)
        locale_to_translation[locale] || locale_to_translation[:en]
      end

    private

      def locale_to_translation=(hash)
        @locale_to_translation = Hash(hash).map do |(locale, translation)|
          locale = String(locale).to_sym
          unless I18n.available_locales.include? locale
            raise "Invalid locale: #{locale.inspect}"
          end

          [locale, String(translation).freeze]
        end.to_h.freeze
      end

      def validate!
        return unless locale_to_translation[:en].strip.empty?

        raise 'Translation for locale "en" not found'
      end
    end
  end
end
