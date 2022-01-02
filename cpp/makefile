all: stackcup

stackcup: helpers.hh table.hh
	g++ -O2 -o stackcup -std=c++17 -Wc++17-extensions -Wc++11-extensions -W -Wall -Wshadow\
		stackcup.cc table.cc helpers.cc 

clean:
	rm -rf stackcup
