# frozen_string_literal: true

module CausaArcana
  module Website
    class TeamMember
      ID_RE = /\A[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*\z/

      attr_reader :id, :first_name, :last_name, :description, :links

      def initialize(id:, first_name:, last_name:, description:, links:)
        self.id          = id
        self.first_name  = first_name
        self.last_name   = last_name
        self.description = description
        self.links       = links
      end

      def inspect
        "#<#{self.class}:#{id}>"
      end

      alias to_s inspect

      def to_h
        {
          id: id,
          first_name: first_name,
          last_name: last_name,
          description: description,
          links: links,
        }.freeze
      end

      def full_name
        @full_name ||= PropertyTranslation.new(
          **(first_name.locales + last_name.locales).uniq.map do |locale|
            [
              locale,
              "#{first_name.translate_to(locale)} #{last_name.translate_to(locale)}",
            ]
          end.to_h,
        )
      end

    private

      def id=(value)
        value = String(value).to_sym
        raise "Invalid ID: #{value}" unless ID_RE.match? value

        @id = value
      end

      def first_name=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @first_name = PropertyTranslation.new(**hash)
      end

      def last_name=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @last_name = PropertyTranslation.new(**hash)
      end

      def description=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @description = PropertyTranslation.new(**hash)
      end

      def links=(array)
        @links = Array(array).map do |item|
          item = Hash(item).transform_keys { |key| String(key).to_sym }
          TeamMemberLink.new(**item)
        end.freeze
      end
    end
  end
end
