# Woven Monopoly

```bash
bin/woven_monopoly board.json rolls_1.json --json
```

A command-line program that plays Woven Monopoly, a version of Monopoly where
the dice rolls are fixed in advance, so every game is deterministic.

## Requirements

- Ruby 3.1 (the exact version is in `.ruby-version`). The code avoids Ruby 3.2+
  features, so it should also run on JRuby.
- Bundler, for the tests and linter only. The program itself needs no gems.

`.ruby-version` pins 3.1.7 for version managers like rbenv. If you have a
different Ruby installed, rbenv will refuse to run inside this folder; choose
your version for one command with `RBENV_VERSION=<version>`, or delete
`.ruby-version`. I developed and tested on Ruby 3.1.7, and also checked that the
program runs on macOS's built-in Ruby 2.6.

## Setup

```bash
bundle install
```

The only gems are RSpec and RuboCop, used for testing and linting. The program
itself uses only Ruby's standard library.

## Running

```bash
# Human-readable summary
bin/woven_monopoly board.json rolls_1.json

# JSON output
bin/woven_monopoly board.json rolls_1.json --json
```

The first argument is the board file and the second is the rolls file. The
`--json` flag can go anywhere in the argument list.

If the arguments are wrong or a file can't be read, the program prints a short
error to standard error and exits with code 1. On success it exits with code 0.

## Tests and linting

```bash
bundle exec rspec
bundle exec rubocop
```

- **Unit tests** (`spec/woven_monopoly/`) cover each class, using small
  hand-made boards so they don't depend on the sample files and prove the code
  works with any board size and any colour group size.
- **Integration tests** (`spec/integration/`) run the real `bin/woven_monopoly`
  command against `board.json` with all three rolls files, including the
  hand-predicted `rolls_3.json`, and check the full output.
- **Shared helpers** (`spec/support/`) are loaded into every spec: `TestBoard`
  builds a fresh four-space board, and `fixture(name)` returns the path to a
  file in `spec/fixtures/`.

## Design

### How the pieces fit together

```
bin/woven_monopoly
  └─> CLI                reads arguments, picks the output format
       ├─> BoardLoader   board.json  → Board (a list of Spaces)
       ├─> RollsLoader   rolls.json  → list of numbers
       │    └─> JsonFile both loaders read and parse files through this
       └─> Game          takes turns until bankruptcy or the rolls run out
            ├─> Player   money and position
            ├─> Rules    passing GO, buying, rent, doubled rent
            └─> Result   winners and final state
                 └─> Formatters (JSON or text)
```

### Decisions

- **The rules live in one class, separate from the game loop.** `Game` only
  handles turn order, movement and when the game ends. Everything about money
  (the GO bonus, buying, rent and the full-set multiplier) is in `Rules`. The
  brief says the rules will change, so a rule change should touch one place
  without touching the turn logic.
- **Rule values are named constants.** `GO_BONUS`, `FULL_SET_RENT_MULTIPLIER`
  and `STARTING_MONEY` make the rules easy to find and change.
- **Nothing about the sample files is hard-coded.** Board size, space names,
  prices and colour groups all come from the board file. Movement wraps using
  the board's size, and the full-set check works for colour groups of any size.
- **Dependencies are passed in.** `Game` accepts its players and rules as
  optional arguments. Tests use this to set up special cases (for example a
  player who starts with $1), and it makes it easy to plug in different rules
  or players later.
- **Data is separate from presentation.** `Result#to_h` builds the output data
  once. The JSON and text formatters only decide how it looks, so adding a new
  format means adding one formatter. It includes a `bankrupt` flag for each
  player (the brief allows extra fields), so the formatters never repeat the
  bankruptcy rule. Changing what counts as bankrupt means changing only
  `Player#bankrupt?`.
- **Clear errors for bad input.** Both loaders read files through `JsonFile`,
  which turns a missing or unreadable file or invalid JSON into an
  `InputError` with a readable message. Both loaders then check the contents
  the same way: `BoardLoader` names the space that's wrong (for example a
  property with no price), and `RollsLoader` rejects invalid rolls. The CLI
  prints these errors. Real bugs are not caught, so they still fail loudly.
- **Errors go to standard error.** This keeps the `--json` output valid JSON.
- **Ownership is stored on the board's spaces.** This keeps the model simple,
  but it means a board object belongs to one game. The CLI loads a fresh board
  for every run.

## ASSUMPTIONS

1. **Rent equals the property's price.** The board only gives a price, and the
   rules don't define rent separately.
2. **A player who can't afford a property still buys it** and goes into debt,
   because the rules say "you must buy it."
3. **A player who can't afford rent still pays it in full** and goes into debt,
   and the owner receives the full rent. This keeps the money rules simple and
   consistent with buying.
4. **A player is bankrupt when their money is below $0.** Having exactly $0
   means they have nothing left, not that they owe anything.
5. **The game ends immediately when a player goes bankrupt**, even if rolls
   remain, because the rules decide the winner "once someone is bankrupt."
6. **If the rolls run out before anyone is bankrupt, the game ends** and the
   richest player wins, since the rolls are the only input to the game.
7. **Landing exactly on GO counts as passing it** and earns $1, because the
   player has completed a full lap.
8. **A roll that goes round the board more than once earns $1 for every lap.**
   On a board with fewer spaces than the roll, the player passes GO each time
   round, so each pass is paid.
9. **The GO bonus is paid before the landing is resolved.** A player passing GO
   collects $1 before buying or paying rent, as in standard Monopoly.
10. **Everyone tied on the most money is a winner**, which is why `winners` is
    a list. Tied winners are listed in turn order.
11. **Bankrupt players are never winners.**
12. **Owning every property in a colour group doubles the rent, whatever the
    group's size**, including a group with only one property, so the rule
    behaves the same on any board.
13. **Landing on your own property does nothing.**
14. **Rolls are used one per turn, in player order**: Peter, Billy, Charlotte,
    Sweedal, then back to Peter.
15. **GO is the first space on the board**, since everyone "starts on GO." A
    board that doesn't start with GO is rejected with an error rather than
    played from the wrong starting space.
16. **Rolls must be whole numbers above 0.** Anything else is rejected with an
    error rather than guessed at. An empty rolls file is allowed: nobody moves,
    and everyone ties on $16.
17. **Landing on a space of any type other than `property` does nothing.** The
    board format only defines GO and properties, so a new type has no rule to
    follow yet. Ignoring it lets the board still load and play, rather than
    rejecting it.
18. **A bankrupt player's money is reported as a negative number**, not
    rounded up to $0, because it shows how much they owe. The JSON output also
    marks them with `"bankrupt": true`.

## rolls_3.json

**What it tests:** Each player completes one colour set, then doubled rent
drains everyone. Peter lands exactly on GO and collects $1. Billy, with $4
left, lands on Peter's Massizim, pays doubled rent of $8 and goes bankrupt.
The game must stop immediately, leaving the last two rolls unused.

This covers buying, full-set doubled rent, passing GO, landing exactly on GO,
bankruptcy from rent, stopping as soon as a player is bankrupt, and a bankrupt
player not winning.

**Expected result, worked out by hand before running the program:**

- Winner: Peter
- Peter: $40 on GO
- Billy: -$4 on Massizim (bankrupt)
- Charlotte: $2 on Gami Chicken
- Sweedal: $8 on Massizim


| Turn | Player    | Roll | Lands on            | What happens                     |
| ---- | --------- | ---- | ------------------- | -------------------------------- |
| 1    | Peter     | 7    | Gami Chicken        | Buys ($4)                        |
| 2    | Billy     | 3    | The Grand Tofu      | Buys ($2)                        |
| 3    | Charlotte | 5    | Betty's Burgers     | Buys ($3)                        |
| 4    | Sweedal   | 1    | The Burvale         | Buys ($1)                        |
| 5    | Peter     | 1    | Massizim            | Buys ($4), completes Blue        |
| 6    | Billy     | 1    | Lanzhou Beef Noodle | Buys ($2), completes Red         |
| 7    | Charlotte | 1    | YOMG                | Buys ($3), completes Green       |
| 8    | Sweedal   | 1    | Fast Kebabs         | Buys ($1), completes Brown       |
| 9    | Peter     | 2    | The Burvale         | Passes GO (+$1), pays Sweedal $2 |
| 10   | Billy     | 3    | Gami Chicken        | Pays Peter $8                    |
| 11   | Charlotte | 1    | Gami Chicken        | Pays Peter $8                    |
| 12   | Sweedal   | 6    | Massizim            | Pays Peter $8                    |
| 13   | Peter     | 8    | GO                  | Lands exactly on GO (+$1)        |
| 14   | Billy     | 1    | Massizim            | Pays Peter$8, bankrupt at -$4    |

**Actual result:** Matched the prediction exactly.

```
Winner: Peter

Peter      $40             GO
Billy      -$4 (bankrupt)  Massizim
Charlotte  $2              Gami Chicken
Sweedal    $8              Massizim
```

The first run didn't match, because `rolls_3.json` still contained an earlier
practice set of rolls. I recognised the output as that practice game's result,
replaced the file with the designed rolls, and the output then matched. The
integration test now checks this result automatically.

## Results

### rolls_1.json

Charlotte went bankrupt, ending the game. Peter had the most money.

```
Winner: Peter

Peter      $40             Massizim
Billy      $14             GO
Charlotte  -$1 (bankrupt)  Gami Chicken
Sweedal    $1              Gami Chicken
```

```json
{
  "winners": [
    "Peter"
  ],
  "players": [
    {
      "name": "Peter",
      "money": 40,
      "space": "Massizim",
      "bankrupt": false
    },
    {
      "name": "Billy",
      "money": 14,
      "space": "GO",
      "bankrupt": false
    },
    {
      "name": "Charlotte",
      "money": -1,
      "space": "Gami Chicken",
      "bankrupt": true
    },
    {
      "name": "Sweedal",
      "money": 1,
      "space": "Gami Chicken",
      "bankrupt": false
    }
  ]
}
```

### rolls_2.json

Sweedal went bankrupt, ending the game. Charlotte had the most money.

```
Winner: Charlotte

Peter      $5              Lanzhou Beef Noodle
Billy      $20             Fast Kebabs
Charlotte  $31             GO
Sweedal    -$2 (bankrupt)  Massizim
```

```json
{
  "winners": [
    "Charlotte"
  ],
  "players": [
    {
      "name": "Peter",
      "money": 5,
      "space": "Lanzhou Beef Noodle",
      "bankrupt": false
    },
    {
      "name": "Billy",
      "money": 20,
      "space": "Fast Kebabs",
      "bankrupt": false
    },
    {
      "name": "Charlotte",
      "money": 31,
      "space": "GO",
      "bankrupt": false
    },
    {
      "name": "Sweedal",
      "money": -2,
      "space": "Massizim",
      "bankrupt": true
    }
  ]
}
```

## What I would do next

- **Make space types their own classes** (for example `GoSpace` and
  `PropertySpace`), so new types like a tax space can add their own landing
  behaviour without growing `Rules`.
- **Make the players and starting money configurable** through command-line
  options or a config file.

## AI usage

See [AI_USAGE.md](AI_USAGE.md). Exported Claude Code sessions are in
`ai-sessions/`.
