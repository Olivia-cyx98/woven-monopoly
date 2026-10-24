# frozen_string_literal: true

require 'json'

module WovenMonopoly
  # Reads a board JSON file and builds a Board from it.
  module BoardLoader
    def self.from_file(path)
      data = JSON.parse(File.read(path))
      Board.new(data.map { |entry| build_space(entry) })
    rescue Errno::ENOENT
      raise InputError, "Board file not found: #{path}"
    rescue JSON::ParserError
      raise InputError, "Board file is not valid JSON: #{path}"
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
