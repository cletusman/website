# frozen_string_literal: true

module CryptoLibertarian
  module Website
    class Team
      attr_reader :members

      def initialize(members)
        self.members = members
        validate!
      end

    private

      def members=(array)
        @members = Array(array).map do |item|
          item = Hash(item).transform_keys { |key| String(key).to_sym }
          TeamMember.new(**item)
        end.freeze
      end

      def validate!
        ids = members.map(&:id)
        raise 'Non unique IDs' if ids != ids.uniq
      end
    end
  end
end
