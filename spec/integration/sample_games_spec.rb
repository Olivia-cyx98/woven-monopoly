# frozen_string_literal: true

require 'json'
require 'open3'

RSpec.describe 'Playing the sample games' do
  def play(rolls_file)
    root = File.expand_path('../..', __dir__)
    stdout, status = Open3.capture2(
      File.join(root, 'bin/woven_monopoly'),
      File.join(root, 'board.json'),
      File.join(root, rolls_file),
      '--json'
    )
    raise 'bin/woven_monopoly failed' unless status.success?

    JSON.parse(stdout)
  end

  describe 'rolls_1.json' do
    subject(:result) { play('rolls_1.json') }

    let(:expected_players) do
      [
        { 'name' => 'Peter', 'money' => 40, 'space' => 'Massizim', 'bankrupt' => false },
        { 'name' => 'Billy', 'money' => 14, 'space' => 'GO', 'bankrupt' => false },
        { 'name' => 'Charlotte', 'money' => -1, 'space' => 'Gami Chicken', 'bankrupt' => true },
        { 'name' => 'Sweedal', 'money' => 1, 'space' => 'Gami Chicken', 'bankrupt' => false }
      ]
    end

    it 'reports the winner' do
      expect(result['winners']).to eq(['Peter'])
    end

    it 'reports every player' do
      expect(result['players']).to eq(expected_players)
    end
  end

  describe 'rolls_2.json' do
    subject(:result) { play('rolls_2.json') }

    let(:expected_players) do
      [
        { 'name' => 'Peter', 'money' => 5, 'space' => 'Lanzhou Beef Noodle', 'bankrupt' => false },
        { 'name' => 'Billy', 'money' => 20, 'space' => 'Fast Kebabs', 'bankrupt' => false },
        { 'name' => 'Charlotte', 'money' => 31, 'space' => 'GO', 'bankrupt' => false },
        { 'name' => 'Sweedal', 'money' => -2, 'space' => 'Massizim', 'bankrupt' => true }
      ]
    end

    it 'reports the winner' do
      expect(result['winners']).to eq(['Charlotte'])
    end

    it 'reports every player' do
      expect(result['players']).to eq(expected_players)
    end
  end

  describe 'rolls_3.json (hand-designed)' do
    subject(:result) { play('rolls_3.json') }

    let(:expected_players) do
      [
        { 'name' => 'Peter', 'money' => 40, 'space' => 'GO', 'bankrupt' => false },
        { 'name' => 'Billy', 'money' => -4, 'space' => 'Massizim', 'bankrupt' => true },
        { 'name' => 'Charlotte', 'money' => 2, 'space' => 'Gami Chicken', 'bankrupt' => false },
        { 'name' => 'Sweedal', 'money' => 8, 'space' => 'Massizim', 'bankrupt' => false }
      ]
    end

    it 'reports the winner' do
      expect(result['winners']).to eq(['Peter'])
    end

    it 'reports every player' do
      expect(result['players']).to eq(expected_players)
    end
  end
end
