# frozen_string_literal: true

module WovenMonopoly
  # The outcome of a game: who won, and where everyone finished.
  class Result
    attr_reader :players, :board

    def initialize(players:, board:)
      @players = players
      @board = board
    end

    def winners
      solvent = players.reject(&:bankrupt?)
      top_money = solvent.map(&:money).max
      solvent.select { |player| player.money == top_money }.map(&:name)
    end

    def to_h
      { winners: winners, players: players.map { |player| summary(player) } }
    end

    private

    def summary(player)
      {
        name: player.name,
        money: player.money,
        space: board.space_at(player.position).name,
        bankrupt: player.bankrupt?
      }
    end
  end
end
