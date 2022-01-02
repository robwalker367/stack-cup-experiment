#include "table.hh"

stack_table::stack_table(int _player_count, int _middle_cups)
  : middle_cups(_middle_cups), players(_player_count, stack_player()) {
}

stack_table::~stack_table() {
}

int stack_cup::move() {
  return 0;
}
