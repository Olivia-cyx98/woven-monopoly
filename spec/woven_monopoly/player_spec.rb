# frozen_string_literal: true

RSpec.describe WovenMonopoly::Player do
  subject(:player) { described_class.new(name: 'Peter') }

  describe 'a new player' do
    it 'has a name' do
      expect(player.name).to eq('Peter')
    end

    it 'starts with $16' do
      expect(player.money).to eq(16)
    end

    it 'starts on GO (position 0)' do
      expect(player.position).to eq(0)
    end
  end

  describe '#pay' do
    it 'reduces money by the amount' do
      player.pay(5)
      expect(player.money).to eq(11)
    end
  end

  describe '#receive' do
    it 'increases money by the amount' do
      player.receive(3)
      expect(player.money).to eq(19)
    end
  end

  describe '#bankrupt?' do
    it 'is false with money left' do
      expect(player).not_to be_bankrupt
    end

    it 'is false at exactly $0' do
      player.pay(16)
      expect(player).not_to be_bankrupt
    end

    it 'is true below $0' do
      player.pay(17)
      expect(player).to be_bankrupt
    end
  end
end
