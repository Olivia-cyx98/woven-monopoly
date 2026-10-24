# Woven coding test
 
Your task is to write a program that plays the game of Woven Monopoly.
 
In Woven Monopoly the dice rolls are set ahead of time, so the game is deterministic.
 
## Game rules
 
* There are four players who take turns in the following order:
  * Peter
  * Billy
  * Charlotte
  * Sweedal
* Each player starts with $16
* Everybody starts on GO
* You get $1 when you pass GO (this excludes your starting move)
* If you land on a property, you must buy it
* If you land on an owned property, you must pay rent to the owner
* If the same owner owns all property of the same colour, the rent is doubled
* Once someone is bankrupt, whoever has the most money remaining is the winner
* There are no chance cards, jail or stations
* The board wraps around (when you reach the last space, the next space is the first space)
 
## What to build
 
* Load the board from `board.json`
* Implement the game logic as per the rules
* Load the dice rolls from `rolls_1.json` and `rolls_2.json` and simulate each game. For each game, report:
  * Who wins
  * How much money each player ends up with
  * Which space each player finishes on
 
## How we will run your program
 
We will run your program ourselves, including against boards and roll files you haven't seen. They follow the same formats as the files in this pack, but boards can have a different number of spaces and colour groups of different sizes, and roll files can be any length. Please don't hard-code anything about the sample files.
 
Your program must:
 
* Take the path to a board file and the path to a rolls file as its two arguments
* Accept a `--json` flag that prints the result to standard output in this shape (extra fields are fine):
 
```json
{
  "winners": ["Peter"],
  "players": [
    { "name": "Peter", "money": 20, "space": "Massizim" },
    { "name": "Billy", "money": 12, "space": "GO" },
    { "name": "Charlotte", "money": 9, "space": "YOMG" },
    { "name": "Sweedal", "money": 3, "space": "The Burvale" }
  ]
}
```
 
`winners` is a list so that you can report a tie. The numbers above are an example of the format, not the answer.
 
Put the exact command to run it at the top of your README, for example `bin/woven_monopoly board.json rolls_1.json --json`. Without `--json`, print whatever human-readable summary you think is most useful.
 
## Gaps in the rules
 
The rules leave some situations open. Real requirements usually do, so this is on purpose. Where you find a gap, make a sensible decision, implement it consistently, and record it in an **ASSUMPTIONS** section of your README with a sentence on why you chose it.
 
If you would rather ask than assume, email [contact email]. Asking questions never counts against you.
 
## Using AI
 
We expect you to use AI tools and we encourage it. We are interested in how you direct them and how you check their work, so we won't mark you down for the amount of code an AI wrote.
 
Please include an `AI_USAGE.md` file that covers:
 
* Which tools you used, and what you used each one for
* At least two places where a tool was wrong, unhelpful or over-complicated things, how you noticed, and what you did about it
* Something you decided to write or rewrite yourself, and why
 
If your tool can export its sessions or chat history (Cursor and Claude Code both can), include the exports in an `ai-sessions/` folder. Remove anything personal first.
 
## Design your own test game
 
Add a `rolls_3.json` file that you have designed by hand to produce a particular situation in the game. In your README, explain what it tests and what result you expect, worked out before you ran your program. Keep it short: 10 to 30 rolls is plenty.
 
## Language
 
We are a Ruby team (we run JRuby in production, so code compatible with Ruby 3.1 is ideal). Ruby is preferred. If you choose another language, tell us why in your README.
 
## Scope and time
 
* Plan on 2 to 3 hours. If you go over, stop and note in your README what you would do next
* This is a command-line program: no user interface, database or web framework
* Keep third-party dependencies to testing and linting tools
 
## What we are looking for
 
* Code that is well thought out and tested
* Clean and readable code
* Extensibility, since the rules will change
* A git history with small changes committed often, so we can see your approach
 
Please approach this as you would a production problem, using whatever approach to coding and testing you think is appropriate.
 
## What to submit
 
* Your source code, including the `.git` folder (a zip of the repository or a link to it)
* A README with:
  * How to install dependencies, run the tests and run the program
  * Your design decisions
  * Your ASSUMPTIONS section
  * The output of your program for `rolls_1.json` and `rolls_2.json`
* `AI_USAGE.md`, and `ai-sessions/` if you have exports
* `rolls_3.json`, with its explanation in your README
 
## What happens next
 
If we progress with your application, we will book a 60-minute session with you. You will walk us through your code, make a small change to it, and extend it with a new rule using your usual tools, including AI. Part of the session is without AI assistance, so make sure you are comfortable explaining and changing your own code. Please have your development environment ready to share your screen.
# woven-monopoly