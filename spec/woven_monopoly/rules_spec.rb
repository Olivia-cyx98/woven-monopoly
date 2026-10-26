# frozen_string_literal: true

RSpec.describe WovenMonopoly::Rules do
  subject(:rules) { described_class.new(board) }

  let(:board) { test_board }
  let(:peter) { WovenMonopoly::Player.new(name: 'Peter') }
  let(:billy) { WovenMonopoly::Player.new(name: 'Billy') }

  def space(name)
    board.spaces.find { |s| s.name == name }
  end

  describe '#pass_go' do
    it 'gives the player $1' do
      rules.pass_go(peter)
      expect(peter.money).to eq(17)
    end

    it 'gives $1 for each time the player passes GO' do
      rules.pass_go(peter, 2)
      expect(peter.money).to eq(18)
    end
  end

  describe '#land' do
    context 'when landing on GO' do
      it 'does nothing' do
        rules.land(peter, space('GO'))
        expect(peter.money).to eq(16)
      end
    end

    context 'when the property is unowned' do
      before { rules.land(peter, space('Red 1')) }

      it 'makes the player the owner' do
        expect(space('Red 1').owner).to eq(peter)
      end

      it 'charges the price' do
        expect(peter.money).to eq(14)
      end
    end

    context 'when the player cannot afford the property' do
      let(:broke) { WovenMonopoly::Player.new(name: 'Broke', money: 1) }

      it 'still buys it and goes into debt' do
        rules.land(broke, space('Red 1'))
        expect(broke.money).to eq(-1)
      end
    end

    context 'when the player owns the property' do
      it 'does nothing' do
        space('Red 1').owner = peter
        rules.land(peter, space('Red 1'))
        expect(peter.money).to eq(16)
      end
    end

    context 'when another player owns the property' do
      before do
        space('Brown 1').owner = peter
        rules.land(billy, space('Brown 1'))
      end

      it 'charges the rent' do
        expect(billy.money).to eq(15)
      end

      it 'pays the owner' do
        expect(peter.money).to eq(17)
      end
    end

    context 'when the owner has the full colour set' do
      before do
        space('Brown 1').owner = peter
        space('Brown 2').owner = peter
        rules.land(billy, space('Brown 1'))
      end

      it 'charges double rent' do
        expect(billy.money).to eq(14)
      end

      it 'pays the owner double' do
        expect(peter.money).to eq(18)
      end
    end
  end

  describe '#rent_for' do
    it 'is the price when the colour set is split between owners' do
      space('Brown 1').owner = peter
      space('Brown 2').owner = billy
      expect(rules.rent_for(space('Brown 1'))).to eq(1)
    end

    it 'doubles for a colour group of one' do
      space('Red 1').owner = peter
      expect(rules.rent_for(space('Red 1'))).to eq(4)
    end
  end
end
