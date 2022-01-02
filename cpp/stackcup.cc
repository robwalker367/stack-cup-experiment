#include "table.hh"
#include "helpers.hh"
#include <unistd.h>
#include <sys/time.h>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cmath>
#include <vector>
#include <thread>
#include <chrono>

stack_table* main_table;

static long nrunning = 0;

static unsigned long delay;

void cup_thread(stack_cup* c) {
  ++nrunning;

  while (true) {
    int mval = c->move();
    if (mval > 0) {
      // Cup successfully moved; wait `delay` to move it again
      if (delay > 0) {
        usleep(delay);
      }
    } else if (mval < 0) {
      // Cup destroyed
      break;
    }
  }

  delete c;
  --nrunning;
}


static bool is_tty;
__attribute__((no_sanitize("thread")))
void print_handler(int);

static void usage() {
  fprintf(stderr,
    "Usage: ./stackcup [-p NPLAYERS] [-c NCUPS] [-m NMIDDLES] [-d MOVEDELAY] [-P PRINTTIMER].\n");
  exit(1);
}

int main(int argc, char** argv) {
  // Print information on receiving a signal
  {
    is_tty = isatty(STDOUT_FILENO);
    struct sigaction sa;
    sa.sa_handler = print_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    int r = sigaction(SIGUSR1, &sa, nullptr);
    assert(r == 0);
    r = sigaction(SIGALRM, &sa, nullptr);
    assert(r == 0);
  }

  // Parse arguments and check invariants
  int nplayers = 6, ncups = 2, nmiddles = 10;
  long print_interval = 0;
  int ch;
  while ((ch = getopt(argc, argv, "P:p:c:m")) != -1) {
    if (ch == 'p' && is_integer_string(optarg)) {
      nplayers = strtol(optarg, nullptr, 10);
    } else if (ch == 'c' && is_integer_string(optarg)) {
      ncups = strtol(optarg, nullptr, 10);
    } else if (ch == 'm' && is_integer_string(optarg)) {
      nmiddles = strtol(optarg, nullptr, 10);
    } else if (ch == 'd' && is_real_string(optarg)) {
      delay = (unsigned long)(strtod(optarg, nullptr) * 1000000);
    } else if (ch == 'P' && is_real_string(optarg)) {
      print_interval = (long)(strtod(optarg, nullptr) * 1000000);
    } else {
      usage();
    }
  }
  if (optind != argc
      || nplayers < 3
      || nplayers <= ncups
      || ncups < 2
      || nmiddles == 0) {
    usage();
  }

  // Set up interval timer to print board
  if (print_interval > 0) {
    struct itimerval it;
    it.it_interval.tv_sec = print_interval / 1000000;
    it.it_interval.tv_usec = print_interval % 1000000;
    it.it_value = it.it_interval;
    int r = setitimer(ITIMER_REAL, &it, nullptr);
    assert(r == 0);
  }

  // Create table
  stack_table table(nplayers, nmiddles);
  main_table = &table;

  // Place cups
  double current_player = 0, player_interval = (double) nplayers / ncups;
  assert(player_interval >= 1.0);
  std::vector<stack_cup*> cups;
  for (int i = 0; i < ncups; ++i) {
    stack_cup* c = new stack_cup(table);
    table.players[std::floor(current_player)].cup = c;
    cups.push_back(c);
    current_player += player_interval;
  }

  // Create cup threads
  for (auto c : cups) {
    std::thread t(cup_thread, c);
    t.detach();
  }

  // Main thread blocks forever
  while (true) {
    select(0, nullptr, nullptr, nullptr, nullptr);
  }
}


__attribute__((no_sanitize("thread")))
void print_handler(int) {
  char buf[8192];
  simple_printer sp(buf, sizeof(buf));

  if (main_table) {
    if (is_tty) {
      // Clear screen
      sp << "\x1B[H\x1B[J" << spflush(STDOUT_FILENO);
    }

    // Print cups and players
    int nplayers = main_table->players.size();
    int half_nplayers = (nplayers - 1) / 2;
    for (int i = 0, n = nplayers; i < n; ++i) {
      // Get player
      int pos = (i <= half_nplayers ? i : nplayers - i + half_nplayers);
      stack_player& p = main_table->players[pos];

      if (auto c = p.cup) {
        // Print cup
        int color = (reinterpret_cast<uintptr_t>(c) / 131) % 6;
        if (is_tty) {
          sp.snprintf("\x1B[%dmC\x1B[m ", 31 + color);
        } else {
          sp << "C ";
        }
      } else {
        // Print player
        sp << ". ";
      }

      // Print middle cups
      if (i == half_nplayers) {
        sp << '\n' << spflush(STDOUT_FILENO);
        for (int j = 0; j < half_nplayers; ++j) {
          sp << ' ';
        }
        if (is_tty) {
          sp.snprintf("\x1B[97;104m%d\x1B[m ", main_table->middle_cups);
        } else {
          sp << (char)((char) main_table->middle_cups + '0');
        }
        sp << '\n' << spflush(STDOUT_FILENO);
      }
    }
    sp << '\n' << spflush(STDOUT_FILENO);
  }
}
