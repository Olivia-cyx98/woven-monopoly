# frozen_string_literal: true

# A fresh four-space board for each spec, so one test's purchases never leak into another.
module TestBoard
  def test_spaces
    [
      WovenMonopoly::Space.new(name: 'GO', type: 'go'),
      WovenMonopoly::Space.new(name: 'Brown 1', type: 'property', price: 1, colour: 'Brown'),
      WovenMonopoly::Space.new(name: 'Brown 2', type: 'property', price: 1, colour: 'Brown'),
      WovenMonopoly::Space.new(name: 'Red 1', type: 'property', price: 2, colour: 'Red')
    ]
  end

  def test_board
    WovenMonopoly::Board.new(test_spaces)
  end
end
