# frozen_string_literal: true

module WovenMonopoly
  # Reads a rolls JSON file: a list of dice rolls used in turn order.
  module RollsLoader
    def self.from_file(path)
      rolls = JsonFile.read(path, 'Rolls file')
      validate!(rolls, path)
      rolls
    end

    def self.validate!(rolls, path)
      valid = rolls.is_a?(Array) && rolls.all? { |roll| roll.is_a?(Integer) && roll.positive? }
      return if valid

      raise InputError, "Rolls file must be a list of positive whole numbers: #{path}"
    end
  end
end
