all: stackcup

stackcup: helpers.hh table.hh
	g++ -O2 -o stackcup -std=c++17 -W -Wall -Wshadow -Wc++17-extensions -Wc++11-extensions\
		stackcup.cc table.cc helpers.cc 

clean:
	rm -rf stackcup
