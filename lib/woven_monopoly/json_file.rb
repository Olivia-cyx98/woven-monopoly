# frozen_string_literal: true

require 'json'

module WovenMonopoly
  # Reads and parses a JSON file, turning file and JSON errors into InputError.
  module JsonFile
    def self.read(path, label)
      JSON.parse(File.read(path))
    rescue Errno::ENOENT
      raise InputError, "#{label} not found: #{path}"
    rescue SystemCallError
      raise InputError, "#{label} could not be read: #{path}"
    rescue JSON::ParserError
      raise InputError, "#{label} is not valid JSON: #{path}"
    end
  end
end
