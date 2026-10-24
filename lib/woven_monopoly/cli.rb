# frozen_string_literal: true

module WovenMonopoly
  # Reads command-line arguments, plays the game and prints the result.
  class CLI
    USAGE = 'Usage: bin/woven_monopoly BOARD_FILE ROLLS_FILE [--json]'
    JSON_FLAG = '--json'

    def initialize(argv, out: $stdout, err: $stderr)
      @json = argv.include?(JSON_FLAG)
      @paths = argv - [JSON_FLAG]
      @out = out
      @err = err
    end

    def run
      return fail_with(USAGE) unless paths.size == 2

      out.puts(formatter.render(play_game))
      0
    rescue InputError => e
      fail_with("Error: #{e.message}")
    end

    private

    attr_reader :json, :paths, :out, :err

    def formatter
      json ? Formatters::JsonFormatter : Formatters::TextFormatter
    end

    def fail_with(message)
      err.puts(message)
      1
    end

    def play_game
      board_path, rolls_path = paths
      board = BoardLoader.from_file(board_path)
      rolls = RollsLoader.from_file(rolls_path)
      Game.new(board: board, rolls: rolls).play.result
    end
  end
end
