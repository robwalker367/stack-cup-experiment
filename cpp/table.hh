#include <vector>

struct stack_player;
struct stack_cup;

struct stack_table {
  int middle_cups;
  std::vector<stack_player> players;

  stack_table(int _player_count, int _middle_cups);
  ~stack_table();
};

struct stack_player {
  stack_cup* cup = nullptr;
};

struct stack_cup {
  stack_table& table;
  int position = 0;
  bool stopped = false;

  stack_cup(stack_table& _table)
    : table(_table) {
  }

  int move();
};
