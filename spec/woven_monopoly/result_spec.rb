# frozen_string_literal: true

RSpec.describe WovenMonopoly::Result do
  subject(:result) { described_class.new(players: players, board: board) }

  let(:board) do
    WovenMonopoly::Board.new(
      [
        WovenMonopoly::Space.new(name: 'GO', type: 'go'),
        WovenMonopoly::Space.new(name: 'Brown 1', type: 'property', price: 1, colour: 'Brown')
      ]
    )
  end

  def player(name, money, position = 0)
    WovenMonopoly::Player.new(name: name, money: money, position: position)
  end

  context 'with one richest player' do
    let(:players) { [player('Peter', 20), player('Billy', 12)] }

    it 'has a single winner' do
      expect(result.winners).to eq(['Peter'])
    end
  end

  context 'with a tie for the most money' do
    let(:players) { [player('Peter', 18), player('Billy', 18), player('Charlotte', 5)] }

    it 'lists every tied player in turn order' do
      expect(result.winners).to eq(%w[Peter Billy])
    end
  end

  context 'with a bankrupt player' do
    let(:players) { [player('Peter', -3), player('Billy', 2)] }

    it 'never makes the bankrupt player a winner' do
      expect(result.winners).to eq(['Billy'])
    end
  end

  describe '#to_h' do
    let(:players) { [player('Peter', 20, 1), player('Billy', 12, 0)] }
    let(:expected) do
      {
        winners: ['Peter'],
        players: [
          { name: 'Peter', money: 20, space: 'Brown 1' },
          { name: 'Billy', money: 12, space: 'GO' }
        ]
      }
    end

    it 'reports winners, money and the name of each final space' do
      expect(result.to_h).to eq(expected)
    end
  end
end
