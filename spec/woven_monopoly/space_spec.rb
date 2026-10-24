# frozen_string_literal: true

RSpec.describe WovenMonopoly::Space do
  let(:go) { described_class.new(name: 'GO', type: 'go') }
  let(:property) do
    described_class.new(name: 'The Burvale', type: 'property', price: 1, colour: 'Brown')
  end

  describe '#property?' do
    it 'is true for a property' do
      expect(property).to be_property
    end

    it 'is false for GO' do
      expect(go).not_to be_property
    end
  end

  describe '#owner' do
    it 'starts unowned' do
      expect(property.owner).to be_nil
    end
  end
end
