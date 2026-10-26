# frozen_string_literal: true

module WovenMonopoly
  # The ring of spaces players move around. GO is the first space.
  class Board
    Move = Struct.new(:position, :times_passed_go, keyword_init: true)

    attr_reader :spaces

    def initialize(spaces)
      raise ArgumentError, 'Board must have at least one space' if spaces.empty?

      @spaces = spaces
    end

    def size
      spaces.size
    end

    def space_at(position)
      spaces.fetch(position)
    end

    # A roll bigger than the board goes round more than once, passing GO each lap.
    def move(from, roll)
      total = from + roll
      Move.new(position: total % size, times_passed_go: total / size)
    end

    def colour_group(colour)
      spaces.select { |space| space.property? && space.colour == colour }
    end
  end
end
