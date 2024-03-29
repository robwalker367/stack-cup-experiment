#include <cstddef>
#include <sys/types.h>

// random_int(min, max)
//    Return a random integer between [min, max], inclusive.
//    This function is thread-safe.
int random_int(int min, int max);

// is_integer_string, is_real_string
//    Check whether `s` is a correctly-formatted decimal integer or
//    real number.
bool is_integer_string(const char* s);
bool is_real_string(const char* s);

struct spflush {
    int fd_;

    spflush(int fd)
        : fd_(fd) {
    }
};

// simple_printer
//    Signal-safe printing functions.
struct simple_printer {
    char* buf_;
    char* s_;
    char* end_;

    simple_printer(char* buf, size_t sz)
        : buf_(buf), s_(buf), end_(buf + sz) {
    }

    char* data() const {
        return buf_;
    }
    size_t length() const {
        return s_ - buf_;
    }
    size_t space() const {
        return end_ - s_;
    }

    simple_printer& operator<<(char ch);
    simple_printer& operator<<(const char* s);
    simple_printer& operator<<(unsigned long i);
    simple_printer& operator<<(long i);
    simple_printer& operator<<(spflush flush);

    simple_printer& snprintf(const char* fmt, ...);

    ssize_t flush(int fd);
};
