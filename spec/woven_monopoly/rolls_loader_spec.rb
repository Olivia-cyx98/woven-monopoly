# frozen_string_literal: true

RSpec.describe WovenMonopoly::RollsLoader do
  describe '.from_file' do
    it 'loads the rolls in order' do
      expect(described_class.from_file(fixture('rolls.json'))).to eq([1, 4, 2])
    end

    it 'raises a clear error when the file is missing' do
      expect { described_class.from_file('missing.json') }
        .to raise_error(WovenMonopoly::InputError, /not found/)
    end

    it 'raises a clear error when the JSON is invalid' do
      expect { described_class.from_file(fixture('invalid.json')) }
        .to raise_error(WovenMonopoly::InputError, /not valid JSON/)
    end

    it 'rejects rolls that are not positive whole numbers' do
      expect { described_class.from_file(fixture('bad_rolls.json')) }
        .to raise_error(WovenMonopoly::InputError, /positive whole numbers/)
    end
  end
end
