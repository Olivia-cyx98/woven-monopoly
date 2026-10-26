# frozen_string_literal: true

require 'json'

module WovenMonopoly
  # Reads a board JSON file and builds a Board from it.
  module BoardLoader
    def self.from_file(path)
      data = JsonFile.read(path, 'Board file')
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
  end
end
