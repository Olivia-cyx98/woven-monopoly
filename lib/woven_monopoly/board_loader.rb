# frozen_string_literal: true

require 'json'

module WovenMonopoly
  # Reads a board JSON file and builds a Board from it.
  module BoardLoader
    def self.from_file(path)
      data = JsonFile.read(path, 'Board file')
      validate!(data, path)
      Board.new(data.map { |entry| build_space(entry) })
    end

    def self.build_space(entry)
      Space.new(
        name: entry.fetch('name'),
        type: entry.fetch('type'),
        price: entry['price'],
        colour: entry['colour']
      )
    end

    def self.validate!(data, path)
      raise InputError, "Board file must be a non-empty list of spaces: #{path}" unless data.is_a?(Array) && data.any?

      data.each.with_index(1) do |entry, number|
        problem = space_problem(entry)
        raise InputError, "Board file #{space_label(entry, number)} #{problem}: #{path}" if problem
      end
      raise InputError, "Board file must start with GO: #{path}" unless data.first['type'] == 'go'
    end

    def self.space_problem(entry)
      return 'is not an object' unless entry.is_a?(Hash)
      return 'needs a name and a type' unless entry['name'].is_a?(String) && entry['type'].is_a?(String)

      'needs a whole-number price and a colour' if entry['type'] == 'property' && !valid_property?(entry)
    end

    def self.valid_property?(entry)
      price = entry['price']
      price.is_a?(Integer) && !price.negative? && entry['colour'].is_a?(String)
    end

    def self.space_label(entry, number)
      entry.is_a?(Hash) && entry['name'] ? "space #{number} (#{entry['name']})" : "space #{number}"
    end
  end
end
