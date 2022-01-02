#include <vector>
#include <mutex>

struct stack_player;
struct stack_cup;

struct stack_table {
  std::mutex mutex;
  int player_count;
  int middle_cups;
  std::vector<stack_player> players;

  stack_table(int _player_count, int _middle_cups);
  ~stack_table();

  stack_player* player(int position);
};

struct stack_player {
  stack_cup* cup = nullptr;
  bool is_first_shot = true;
};

struct stack_cup {
  stack_table& table;
  int position = 0;
  int stacks = 1;
  bool stopped = false;

  stack_cup(stack_table& _table, int _position)
    : table(_table), position(_position) {
  }

  stack_player* player();

  int move();
};
