# Targets
all: poker

poker: poker.cpp card.o hand.o
	c++ -o poker poker.cpp card.o hand.o

card.o: card.cpp card.h
	c++ -c card.cpp

hand.o: hand.cpp hand.h card.h
	c++ -c hand.cpp

clean:
	rm -f *.o poker