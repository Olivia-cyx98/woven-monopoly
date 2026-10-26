# frozen_string_literal: true

module WovenMonopoly
  # What happens when a player passes GO or lands on a space.
  class Rules
    GO_BONUS = 1
    FULL_SET_RENT_MULTIPLIER = 2

    def initialize(board)
      @board = board
    end

    def pass_go(player, times = 1)
      player.receive(GO_BONUS * times)
    end

    def land(player, space)
      return unless space.property?

      if space.owner.nil?
        buy(player, space)
      elsif space.owner != player
        pay_rent(player, space)
      end
    end

    def rent_for(space)
      full_set?(space) ? space.price * FULL_SET_RENT_MULTIPLIER : space.price
    end

    private

    attr_reader :board

    def buy(player, space)
      player.pay(space.price)
      space.owner = player
    end

    def pay_rent(player, space)
      rent = rent_for(space)
      player.pay(rent)
      space.owner.receive(rent)
    end

    def full_set?(space)
      board.colour_group(space.colour).all? { |s| s.owner == space.owner }
    end
  end
end
