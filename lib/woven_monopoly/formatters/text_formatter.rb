# frozen_string_literal: true

module WovenMonopoly
  module Formatters
    # Prints the result as a short, readable table.
    module TextFormatter
      def self.render(result)
        rows = result.to_h[:players].map { |player| row(player) }
        [winner_line(result.winners), '', *rows].join("\n")
      end

      def self.winner_line(winners)
        case winners.size
        when 0 then 'No winner'
        when 1 then "Winner: #{winners.first}"
        else "Winners (tie): #{winners.join(', ')}"
        end
      end

      # Bankruptcy comes from the result, so the rule lives only in Player.
      def self.format_money(player)
        money = player[:money]
        amount = money.negative? ? "-$#{money.abs}" : "$#{money}"
        player[:bankrupt] ? "#{amount} (bankrupt)" : amount
      end

      def self.row(player)
        format('%<name>-10s %<money>-14s  %<space>s',
               name: player[:name], money: format_money(player), space: player[:space])
      end
    end
  end
end
