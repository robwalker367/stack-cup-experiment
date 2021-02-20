# Stack Cup Experiment

Simulates stack cup for finding the expected number of round until someone drinks. Clone this repo and run `ruby stack_cup_game.rb` to execute.

### Stack cup rules

See [here](https://letmegooglethat.com/?q=Stack+cup+rules) for the full rules of stack cup. A brief summary follows.

_n_ players stand in a circle around a table. _c_ cups with ping pong balls (the ping pong balls always stay with the cups) are distributed as equally as possible among the players (usually _c_ is 2, but for large games can be 3). A game is won by a player "stacking" one of the cups into another players cup. The game is divided into rounds, and each round each player with a cup tries to bounce their ping pong ball off of the table and into their cup. If the ball lands in their cup, three things can happen:
1. If the player-who-made-the-shot is to the left of the player who has another cup, then the player-who-made-the-shot can stack their cup in the cup of the player to their right. The game ends.
2. If it was the player-who-made-the-shot's first time shooting the ball into the cup after having received the cup, then the player-who-made-the-shot can pass their cup to any player they choose.
3. Otherwise, the player-who-made-the-shot passes the cup to the player to their right.
Once the game is over, the player whose cup was stacked must drink some ginger ale :).

### Experiment

I was curious about the expected number of rounds until one player drinks. While I believe that (in very non-precise terms) this can be modelled as a one-dimensional random walk along an integer line `0,...,floor(n/2)` 'with jumps' (i.e., when the player makes their first shot) and where each integer represents the distance between the two cups, I thought it'd be fun to actually program it out!

I make the following assumptions about the game:
- Each player has an equal skill level (i.e., their probability of making a shot)
- The skill level of each player stays constant no matter how many games are played -- in real stack cup games, skill level usually decreases the longer the game is played (due to the carbonation in the ginger ale, which makes the participants physically lighter and thus throws off their game due to unexpected weight shifts).
- If the player-who-made-the-shot made the shot on their first try, they always pass their cup directly to the left of the closest player-with-a-cup on their right (anecdotally, this is consistent with most stack cup strategies used in the wild, since it gives the (unproven) highest chance that the game ends and someone drinks!)
- Two cups are used (this assumption can be removed by a probably easy implementation change, but this depends on my willingness to spend any more time (brief as it may be) on this weird experiment)

### Results

I have the following results so far:

| expected rounds | total players (>3) | player skill (0 < p < 1) |
|-----------------|--------------------|--------------------------|
| 11              | 6                  | 0.5                      |

### A minor note

I was moving quickly and this was purely for fun, so please don't judge my code too much :)
