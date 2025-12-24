#include "card.h"
#include <iostream>

Card::Card() // default Card constructor
{
	rank = "";
	suit = "";
}

Card::Card(string r, string s) // parameterized constructor
{
	rank = r;
	suit = s;
}

string Card::toString() const 
{
	return rank + suit;
}

int Card::rankValue() const // returns rank value of face cards
{
	if (rank == "A") // A is the highest so it returns 14 rather than 1
		return 14;
	if (rank == "K") 
		return 13;
	if (rank == "Q") 
		return 12;
	if (rank == "J") 
		return 11;
	if (rank == "10") 
		return 10;
	return stoi(rank);
}

int Card::suitValue() const // assigns suit value to the four suits
{
	if (suit == "D") 
		return 1;
	if (suit == "C") 
		return 2;
	if (suit == "H") 
		return 3;
	if (suit == "S") 
		return 4;
	return 0;
}

bool Card::operator==(const Card& other) const // operator overloaded method to check if cards are the same
{
	return (rank == other.rank && suit == other.suit);
}

