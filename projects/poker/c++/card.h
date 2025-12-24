#ifndef CARD_H
#define CARD_H

#include <string>
using namespace std;

class Card
{
	public:
		string rank;
		string suit;

		Card();
		Card(string r, string s);

		string toString() const;
		int rankValue() const;   
		int suitValue() const;   
		bool operator==(const Card& other) const;
};

#endif

