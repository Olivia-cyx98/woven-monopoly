# frozen_string_literal: true

module WovenMonopoly
  # One square on the board: either GO or a property that can be owned.
  class Space
    attr_reader :name, :type, :price, :colour
    attr_accessor :owner

    def initialize(name:, type:, price: nil, colour: nil)
      @name = name
      @type = type
      @price = price
      @colour = colour
      @owner = nil
    end

    def property?
      type == 'property'
    end
  end
end
