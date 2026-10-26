# AI usage

## Tools

- **Claude (claude.ai chat):** I used it throughout the project for:
  - **Planning:** breaking the brief into steps, listing the gaps in the rules
    that needed assumptions, and choosing a project structure.
  - **Learning Ruby:** I'm new to Ruby (my background is TypeScript), so I used
    it to explain Ruby conventions, RSpec and RuboCop as I went.
  - **Drafting code and specs:** one class at a time. For each class I added
    the spec first, ran it to see it fail, then added the code and ran RSpec
    and RuboCop before committing.
  - **Refactoring:** extracting the duplicated JSON file reading from the two
    loaders into a shared `JsonFile` helper.
  - **Checking my work:** reviewing my README and project structure, and
    helping design `rolls_3.json` and check the turn-by-turn table.

## How I checked the AI's work

- **Tests first.** Every class has specs, and I ran each spec before writing
  the code to make sure it actually failed for the right reason.
- **RuboCop with default settings.** I treated lint failures as signals about
  the code rather than turning rules off.
- **Hand-traced games.** For the CLI tests and for `rolls_3.json`, the expected
  results were worked out turn by turn in a table before running the program.
- **Integration tests on the real command.** These run `bin/woven_monopoly`
  exactly as a reviewer would, so mistakes in wiring or files show up.
- **Refactors must not change the specs.** When the shared `JsonFile` helper
  was added, all the existing loader specs passed without any changes, which
  showed the behaviour was the same. I also ran the program with a missing
  file to confirm the error message was still clear.

## Where the AI was wrong or unhelpful

### 1. A config that didn't work, which turned out to be the wrong Ruby

The AI's first `.rubocop.yml` used `plugins:`, which failed with
"unrecognized cop or department plugins." It suggested switching to the older
`require:` setting. That made the error go away but hid the real problem.

Later, `bundle exec rubocop` said none of the gems were installed. The lock
file showed RuboCop 1.50, which was much older than expected. That pointed to
the real cause: my first `bundle install` had run on macOS's built-in Ruby 2.6
rather than the Ruby 3.1.7 I had installed with rbenv, because rbenv wasn't
connected to my shell yet. I fixed the shell setup, confirmed it with
`ruby -v` and `which ruby`, deleted `Gemfile.lock`, reinstalled the gems, and
went back to `plugins:`.

**What I learned:** a workaround that makes an error disappear isn't the same
as a fix. Checking the actual versions installed found the real cause.

### 2. Generated code that didn't pass the project's own lint rules

Several pieces of AI-written code failed RuboCop:

- `CLI#run` was too complex (`Metrics/AbcSize`). I moved the game-playing part
  into a separate `play_game` method. That also made `run` easier to read: it
  now just checks the arguments, plays the game and prints the result.
- A Result spec example was too long (`RSpec/ExampleLength`). I moved the
  expected hash into a `let` rather than raising the limit.
- The first spec files were placed directly in `spec/` instead of mirroring
  `lib/` (`RSpec/SpecFilePathFormat`). I moved them into `spec/woven_monopoly/`.

I kept RuboCop's defaults and changed the code instead. The only rule I turned
off was `RSpec/DescribeClass`, and only for the integration tests, because
they describe the whole program rather than one class.

### 3. Instructions that were easy to misread

Some of the AI's instructions were ambiguous, which caused mistakes:

- It showed the contents of the `Gemfile` without saying clearly that it was a
  file, so I pasted it into the terminal, which failed with a shell error.
- It labelled two lines with comments meaning "this one goes in the first test
  and this one in the second." I put both into the same test. RuboCop caught it
  (`RSpec/MultipleExpectations`), and the test was also wrong, since it expected
  the rolls_1 winner in the rolls_2 game.
- It split adding `Game#result` across a later step that was easy to miss. The
  CLI tests failed with `undefined method 'result'`, which showed exactly
  what was missing.

**What I learned:** run the tests and linter after every change, because they
catch these mistakes immediately, whoever made them.

### 4. Results the AI couldn't know

For the integration tests, the AI couldn't know the real game results, so it
left `TODO` placeholders. I ran the program and filled them in. A test that
only copies the program's output proves nothing if the program is wrong, so
the results also need checking against a hand calculation.

This mattered for `rolls_3.json`: the first run didn't match my prediction. I
recognised the output as the result of an earlier practice game. The file still
contained the practice rolls rather than the designed ones. After replacing
them, the output matched the prediction exactly.

### 5. A file name that didn't match its class

While reviewing the folder structure, I noticed the rules were in `rule.rb`,
but the class inside is `Rules`. Ruby convention is that the file name matches
the class, so I renamed it to `rules.rb`. Nothing broke, because the
`require_relative` line matched the old name, but it was the kind of
inconsistency that would confuse someone reading the code later.

## Decisions I made myself

- **Choosing Ruby.** The brief said Ruby was preferred but not required. I'm
  stronger in TypeScript, but chose to learn enough Ruby to do the task in the
  team's language.
- **Keeping `Player` simple.** The AI suggested replacing `attr_accessor
  :position` with a `move_to` method, for consistency with `pay` and `receive`.
  I decided to keep the simpler version, since it was clear and the extra
  method didn't add much for this task.
- **Keeping a flat folder structure.** I considered moving the loaders into
  their own folder because `lib/woven_monopoly/` looked busy. I decided against
  it: with only two loaders, a new module and folder would mean renaming
  classes and moving specs for little benefit. I'd group them if more loaders
  were added, the same way the formatters are grouped.
- **Leaving my git history honest.** I considered squashing a mistaken README
  commit and its fix, but decided to leave the history as it was rather than
  rewrite commits that were already pushed.

## What I wrote or rewrote myself, and why

### 1. Showing bankrupt players clearly

I changed the text output so bankrupt players are shown as `-$4 (bankrupt)`
instead of `$-4`. I wrote the code and tests myself. I asked the AI only for
hints on where to start, not for code.

**What I changed:** I added a `[money_label]` method to `TextFormatter` that
returns the normal `$17` style for zero or positive money, and puts the minus
sign before the dollar sign plus `(bankrupt)` for negative money. `row` now
uses it. [I also widened the money column so the table still lines up.]

**How I tested it:** I wrote a new spec,
`spec/woven_monopoly/formatters/text_formatter_spec.rb`, first and watched it
fail. It checks that a bankrupt player shows `-$4 (bankrupt)` and that a
player with money still shows `$17`. Then I wrote the code, ran the full test
suite and RuboCop, and checked the real output for `rolls_3.json`, where Billy
goes bankrupt. The JSON output didn't change, so the integration tests were
unaffected.

**Why I chose this one:** it's a small, self-contained change to existing
code, similar to what I might be asked to do in the interview, so it was a
good way to check I could change the code confidently on my own. It also
makes the output clearer: `$-4` is easy to misread, while `-$4 (bankrupt)`
says what happened.

### 2. Using one shared board in the specs

Four specs built their own test board inline: the board, game and rules specs
each copied the same four spaces, and the result spec used a two-space
version. The AI added a `TestBoard` helper in `spec/support/test_board.rb`,
loaded through `spec_helper.rb`, but didn't change any specs to use it.

**What I changed:** I replaced the inline boards in `board_spec.rb`,
`game_spec.rb` and `result_spec.rb` with calls to `test_spaces`. The helper
builds new spaces on every call, so each test still gets its own board and a
property bought in one test can't carry into the next.

**How I tested it:** the full test suite and RuboCop both pass. The result
spec now uses the four-space board instead of its two-space one, and its tests
still pass, which shows they didn't depend on the board's size.

**Why:** the test board is now defined in one place, so changing it means
editing one file, and each spec is shorter and focused on what it tests. The
trade-off is that a reader has to open `test_board.rb` to see which spaces the
board has.
