# frozen_string_literal: true

RSpec.describe WovenMonopoly::Formatters::JsonFormatter do
  subject(:parsed) { JSON.parse(described_class.render(result)) }

  let(:players) do
    [
      WovenMonopoly::Player.new(name: 'Peter', money: 17, position: 1),
      WovenMonopoly::Player.new(name: 'Billy', money: 17)
    ]
  end
  let(:result) { WovenMonopoly::Result.new(players: players, board: test_board) }

  it 'reports the winners as a list, so ties fit' do
    expect(parsed['winners']).to eq(%w[Peter Billy])
  end

  it 'reports each player with their money and the name of their space' do
    expect(parsed['players'].first).to eq('name' => 'Peter', 'money' => 17, 'space' => 'Brown 1', 'bankrupt' => false)
  end
end
