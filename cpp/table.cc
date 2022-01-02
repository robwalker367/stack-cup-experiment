#include "table.hh"
#include "helpers.hh"
#include <cstdlib>

stack_table::stack_table(int _player_count, int _middle_cups)
  : player_count(_player_count), middle_cups(_middle_cups),
    players(_player_count, stack_player()) {
}

stack_table::~stack_table() {
}

stack_player* stack_table::player(int position) {
  return &this->players[position % this->player_count];
}

int stack_cup::move() {
  this->table.mutex.lock();
  bool made_shot = random_int(0, 1);
  if (made_shot) {
    stack_player* next_player = this->table.player(this->position + 1);
    if (next_player->cup) {
      // Stack the cup onto the next player's cup
      this->player()->cup = nullptr;
      next_player->cup->stacks += this->stacks;

      // Next player passes stacked cup to next player without a cup
      int i = this->position + 2;
      while (this->table.player(i)->cup) {
        ++i;
      }
      assert(!this->table.player(i)->cup);
      this->table.player(i)->cup = next_player->cup;
      this->table.player(i)->cup->position = i % this->table.player_count;
      next_player->cup = nullptr;

      // Next player takes a cup from the middle
      --this->table.middle_cups;
      if (this->table.middle_cups <= 0) {
        // Game ends
        exit(0);
      }
      next_player->cup = this;
      ++this->position;
      this->stacks = 1;
      this->table.mutex.unlock();
      return -1;
    } else {
      // Pass cup to next player
      this->player()->cup = nullptr;
      next_player->cup = this;
      ++this->position;
      this->table.mutex.unlock();
      return 1;
    }
  } else {
    this->table.mutex.unlock();
    return 0;
  }
}

stack_player* stack_cup::player() {
  return this->table.player(this->position);
}
