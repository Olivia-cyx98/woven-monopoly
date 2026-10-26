# frozen_string_literal: true

require 'stringio'

RSpec.describe WovenMonopoly::CLI do
  let(:board_path) { fixture('small_board.json') }
  let(:rolls_path) { fixture('rolls.json') }

  def run_cli(*args)
    out = StringIO.new
    err = StringIO.new
    code = described_class.new(args, out: out, err: err).run
    { code: code, out: out.string, err: err.string }
  end

  describe 'with --json' do
    subject(:output) { JSON.parse(run_cli(board_path, rolls_path, '--json')[:out]) }

    it 'reports the winner' do
      expect(output['winners']).to eq(['Peter'])
    end

    it 'reports each player' do
      expect(output['players'])
        .to include('name' => 'Charlotte', 'money' => 14, 'space' => 'Red 1', 'bankrupt' => false)
    end
  end

  describe 'without --json' do
    it 'prints a readable summary' do
      expect(run_cli(board_path, rolls_path)[:out]).to include('Winner: Peter')
    end
  end

  it 'exits with 0 on success' do
    expect(run_cli(board_path, rolls_path)[:code]).to eq(0)
  end

  context 'with missing arguments' do
    it 'exits with 1' do
      expect(run_cli(board_path)[:code]).to eq(1)
    end

    it 'prints the usage' do
      expect(run_cli(board_path)[:err]).to include('Usage')
    end
  end

  context 'with a missing file' do
    it 'prints a clear error' do
      expect(run_cli('nope.json', rolls_path)[:err]).to include('not found')
    end
  end
end
