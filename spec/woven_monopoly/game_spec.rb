# frozen_string_literal: true

RSpec.describe WovenMonopoly::Game do
  let(:board) do
    WovenMonopoly::Board.new(
      [
        WovenMonopoly::Space.new(name: 'GO', type: 'go'),
        WovenMonopoly::Space.new(name: 'Brown 1', type: 'property', price: 1, colour: 'Brown'),
        WovenMonopoly::Space.new(name: 'Brown 2', type: 'property', price: 1, colour: 'Brown'),
        WovenMonopoly::Space.new(name: 'Red 1', type: 'property', price: 2, colour: 'Red')
      ]
    )
  end

  def play(rolls, **options)
    described_class.new(board: board, rolls: rolls, **options).play
  end

  def find_player(game, name)
    game.players.find { |p| p.name == name }
  end

  it 'starts with the four players in turn order' do
    game = described_class.new(board: board, rolls: [])
    expect(game.players.map(&:name)).to eq(%w[Peter Billy Charlotte Sweedal])
  end

  it 'moves each player in turn' do
    game = play([1, 2, 3, 1])
    expect(game.players.map(&:position)).to eq([1, 2, 3, 1])
  end

  it 'buys the property a player lands on' do
    play([3])
    expect(board.space_at(3).owner.name).to eq('Peter')
  end

  it 'pays $1 for landing on GO' do
    game = play([4])
    expect(find_player(game, 'Peter').money).to eq(17)
  end

  it 'uses every roll when nobody goes bankrupt' do
    game = play([1, 1, 1, 1, 1])
    expect(find_player(game, 'Peter').position).to eq(2)
  end

  context 'when a player goes bankrupt' do
    let(:players) do
      [
        WovenMonopoly::Player.new(name: 'Peter', money: 1),
        WovenMonopoly::Player.new(name: 'Billy')
      ]
    end

    it 'stops the game immediately' do
      game = play([3, 1], players: players)
      expect(find_player(game, 'Billy').position).to eq(0)
    end
  end

  it 'reports the result of the game' do
    game = play([4])
    expect(game.result.winners).to eq(['Peter'])
  end
end
