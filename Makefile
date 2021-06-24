all: scanner.l parser.y main.cpp
	flex -o scanner.cpp scanner.l
	bison -d -o parser.cpp parser.y
	g++ main.cpp parser.cpp scanner.cpp -o parser

clean:
	rm parser.cpp 
	rm parser.hpp
	rm scanner.cpp
	rm parser