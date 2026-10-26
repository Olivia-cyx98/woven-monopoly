# frozen_string_literal: true

RSpec.describe WovenMonopoly::Formatters::TextFormatter do
  subject(:output) { described_class.render(result) }

  let(:result) { WovenMonopoly::Result.new(players: players, board: test_board) }

  def player(name, money)
    WovenMonopoly::Player.new(name: name, money: money)
  end

  context 'with one winner' do
    let(:players) { [player('Peter', 17), player('Billy', -4), player('Charlotte', 0)] }

    it 'names the winner' do
      expect(output).to start_with('Winner: Peter')
    end

    it 'shows the money and space of a player who still has money' do
      expect(output).to match(/^Peter\s+\$17\s+GO$/)
    end

    it 'marks a bankrupt player, with the minus sign before the dollar sign' do
      expect(output).to match(/^Billy\s+-\$4 \(bankrupt\)\s+GO$/)
    end

    it 'does not mark a player with exactly $0 as bankrupt' do
      expect(output).to match(/^Charlotte\s+\$0\s+GO$/)
    end
  end

  context 'when the result marks a player bankrupt' do
    let(:result) do
      instance_double(WovenMonopoly::Result, winners: [], to_h: {
                        winners: [], players: [{ name: 'Peter', money: 0, space: 'GO', bankrupt: true }]
                      })
    end

    it 'follows the result rather than deciding from the money itself' do
      expect(output).to match(/^Peter\s+\$0 \(bankrupt\)\s+GO$/)
    end
  end

  context 'with a tie' do
    let(:players) { [player('Peter', 16), player('Billy', 16)] }

    it 'names every tied winner' do
      expect(output).to start_with('Winners (tie): Peter, Billy')
    end
  end
end
