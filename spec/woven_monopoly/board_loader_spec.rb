# frozen_string_literal: true

RSpec.describe WovenMonopoly::BoardLoader do
  describe '.from_file' do
    subject(:board) { described_class.from_file(fixture('small_board.json')) }

    it 'loads every space' do
      expect(board.spaces.map(&:name)).to eq(['GO', 'Brown 1', 'Red 1'])
    end

    it 'loads property details' do
      expect(board.space_at(2)).to have_attributes(price: 2, colour: 'Red', type: 'property')
    end

    it 'raises a clear error when the file is missing' do
      expect { described_class.from_file('missing.json') }
        .to raise_error(WovenMonopoly::InputError, /not found/)
    end

    it 'raises a clear error when the JSON is invalid' do
      expect { described_class.from_file(fixture('invalid.json')) }
        .to raise_error(WovenMonopoly::InputError, /not valid JSON/)
    end
  end
end
