# frozen_string_literal: true

RSpec.describe WovenMonopoly::Board do
  subject(:board) { described_class.new(spaces) }

  let(:spaces) { test_spaces }

  it 'knows its size' do
    expect(board.size).to eq(4)
  end

  it 'finds a space by position' do
    expect(board.space_at(3).name).to eq('Red 1')
  end

  it 'refuses an empty board' do
    expect { described_class.new([]) }.to raise_error(ArgumentError)
  end

  describe '#move' do
    it 'moves forward without passing GO' do
      expect(board.move(0, 2)).to have_attributes(position: 2, times_passed_go: 0)
    end

    it 'wraps around and passes GO' do
      expect(board.move(3, 2)).to have_attributes(position: 1, times_passed_go: 1)
    end

    it 'counts landing exactly on GO as passing it' do
      expect(board.move(2, 2)).to have_attributes(position: 0, times_passed_go: 1)
    end

    it 'counts every lap when one roll goes round the board more than once' do
      expect(board.move(3, 6)).to have_attributes(position: 1, times_passed_go: 2)
    end
  end

  describe '#colour_group' do
    it 'returns every property of that colour' do
      expect(board.colour_group('Brown').map(&:name)).to eq(['Brown 1', 'Brown 2'])
    end

    it 'works for a group of one' do
      expect(board.colour_group('Red').size).to eq(1)
    end
  end
end
