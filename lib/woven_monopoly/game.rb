# frozen_string_literal: true

module WovenMonopoly
  # Plays the game: takes turns in order until someone is bankrupt
  # or the rolls run out.
  class Game
    PLAYER_NAMES = %w[Peter Billy Charlotte Sweedal].freeze

    attr_reader :board, :players

    def initialize(board:, rolls:, players: default_players, rules: Rules.new(board))
      @board = board
      @rolls = rolls
      @players = players
      @rules = rules
    end

    def play
      rolls.each_with_index do |roll, turn|
        player = players[turn % players.size]
        take_turn(player, roll)
        break if player.bankrupt?
      end
      self
    end

    private

    attr_reader :rolls, :rules

    def default_players
      PLAYER_NAMES.map { |name| Player.new(name: name) }
    end

    def take_turn(player, roll)
      move = board.move(player.position, roll)
      player.position = move.position
      rules.pass_go(player) if move.passed_go
      rules.land(player, board.space_at(move.position))
    end
  end
end
