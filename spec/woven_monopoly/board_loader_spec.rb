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

    it 'raises a clear error when the board is not a list' do
      expect { described_class.from_file(fixture('board_not_a_list.json')) }
        .to raise_error(WovenMonopoly::InputError, /non-empty list of spaces/)
    end

    it 'raises a clear error when the board is empty' do
      expect { described_class.from_file(fixture('empty_board.json')) }
        .to raise_error(WovenMonopoly::InputError, /non-empty list of spaces/)
    end

    it 'raises a clear error when a space has no name' do
      expect { described_class.from_file(fixture('board_missing_name.json')) }
        .to raise_error(WovenMonopoly::InputError, /space 1 needs a name and a type/)
    end

    it 'raises a clear error naming a property that has no price' do
      expect { described_class.from_file(fixture('board_missing_price.json')) }
        .to raise_error(WovenMonopoly::InputError, /space 2 \(Brown 1\) needs a whole-number price and a colour/)
    end

    it 'raises a clear error when the board does not start with GO' do
      expect { described_class.from_file(fixture('board_without_go_first.json')) }
        .to raise_error(WovenMonopoly::InputError, /must start with GO/)
    end
  end
end
