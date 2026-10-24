# Woven Monopoly

```bash
bin/woven_monopoly board.json rolls_1.json --json
```

A command-line program that plays Woven Monopoly, a version of Monopoly where
the dice rolls are fixed in advance, so every game is deterministic.

## Requirements

- Ruby 3.1 (the exact version is in `.ruby-version`). The code avoids Ruby 3.2+
  features, so it should also run on JRuby.
- Bundler

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
  command against `board.json` with each rolls file and check the full output.

## Design

### How the pieces fit together

```
bin/woven_monopoly
  └─> CLI                reads arguments, picks the output format
       ├─> BoardLoader   board.json  → Board (a list of Spaces)
       ├─> RollsLoader   rolls.json  → list of numbers
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
  format means adding one formatter.
- **Clear errors for bad input.** The loaders turn missing files, invalid JSON
  and invalid rolls into an `InputError` with a readable message, which the CLI
  prints. Real bugs are not caught, so they still fail loudly.
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
8. **The GO bonus is paid before the landing is resolved.** A player passing GO
   collects $1 before buying or paying rent, as in standard Monopoly.
9. **Everyone tied on the most money is a winner**, which is why `winners` is
   a list. Tied winners are listed in turn order.
10. **Bankrupt players are never winners.**
11. **Owning every property in a colour group doubles the rent, whatever the
    group's size**, including a group with only one property, so the rule
    behaves the same on any board.
12. **Landing on your own property does nothing.**
13. **Rolls are used one per turn, in player order**: Peter, Billy, Charlotte,
    Sweedal, then back to Peter.
14. **GO is the first space on the board**, since everyone "starts on GO."
15. **Rolls must be whole numbers above 0.** Anything else is rejected with an
    error rather than guessed at. An empty rolls file is allowed: nobody moves,
    and everyone ties on $16.

## rolls_3.json

**What it tests:** TODO, one or two sentences describing the situation.

**Expected result, worked out by hand before running the program:**

- Winner: TODO
- Peter: $TODO on TODO
- Billy: $TODO on TODO
- Charlotte: $TODO on TODO
- Sweedal: $TODO on TODO

**Actual result:** TODO. Either "matched the prediction," or what differed and
why.

## Results

### rolls_1.json

```
TODO: paste the output of bin/woven_monopoly board.json rolls_1.json
```

```json
TODO: paste the output of bin/woven_monopoly board.json rolls_1.json --json
```

### rolls_2.json

```
TODO: paste the output of bin/woven_monopoly board.json rolls_2.json
```

```json
TODO: paste the output of bin/woven_monopoly board.json rolls_2.json --json
```

## What I would do next

- **Extract the shared file-reading code** in `BoardLoader` and `RollsLoader`
  into one helper, since both read JSON and handle the same errors.
- **Validate the board more strictly**: check that GO is the first space and
  that every property has a price and a colour, with a clear error if not.
- **Make space types their own classes** (for example `GoSpace` and
  `PropertySpace`), so new types like a tax space can add their own landing
  behaviour without growing `Rules`.
- **Make the players and starting money configurable** through command-line
  options or a config file.
- **Run the test suite on JRuby in CI**, since that's the production runtime.

## AI usage

See [AI_USAGE.md](AI_USAGE.md). Exported sessions are in `ai-sessions/`.