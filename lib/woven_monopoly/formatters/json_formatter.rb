# frozen_string_literal: true

require 'json'

module WovenMonopoly
  module Formatters
    # Prints the result as JSON in the shape the brief asks for.
    module JsonFormatter
      def self.render(result)
        JSON.pretty_generate(result.to_h)
      end
    end
  end
end
