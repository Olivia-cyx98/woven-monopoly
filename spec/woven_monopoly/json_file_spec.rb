# frozen_string_literal: true

RSpec.describe WovenMonopoly::JsonFile do
  describe '.read' do
    it 'parses the file' do
      expect(described_class.read(fixture('rolls.json'), 'Rolls file')).to eq([1, 4, 2])
    end

    it 'names the file in the error when it is missing' do
      expect { described_class.read('missing.json', 'Rolls file') }
        .to raise_error(WovenMonopoly::InputError, 'Rolls file not found: missing.json')
    end

    it 'raises a clear error when the JSON is invalid' do
      expect { described_class.read(fixture('invalid.json'), 'Rolls file') }
        .to raise_error(WovenMonopoly::InputError, /not valid JSON/)
    end

    it 'raises a clear error when the path is a folder' do
      expect { described_class.read(__dir__, 'Board file') }
        .to raise_error(WovenMonopoly::InputError, /Board file could not be read/)
    end
  end
end
