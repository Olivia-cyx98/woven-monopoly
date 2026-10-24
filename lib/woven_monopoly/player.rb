# frozen_string_literal: true

module WovenMonopoly
  # A player in the game: tracks their money and where they are on the board.
  class Player
    STARTING_MONEY = 16

    attr_reader :name, :money
    attr_accessor :position

    def initialize(name:, money: STARTING_MONEY, position: 0)
      @name = name
      @money = money
      @position = position
    end

    def pay(amount)
      @money -= amount
    end

    def receive(amount)
      @money += amount
    end

    def bankrupt?
      money.negative?
    end
  end
end
